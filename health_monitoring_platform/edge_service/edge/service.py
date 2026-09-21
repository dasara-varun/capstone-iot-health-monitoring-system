"""Edge daemon coordinator with state machine and offline-resilient pipeline."""
import time
import uuid
from datetime import datetime, timezone
from typing import List, Optional
from .models import Sample, Decision
from .detector import HybridDetector
from .store import LocalStore
from .sync import CloudSynchronizer
from ..sensors.base import BaseSensor

def build_event_id(device_id: str, event_time: str) -> str:
    clean_time = event_time.replace(":", "").replace("-", "").replace(".", "")
    return f"{device_id}-{clean_time}-{uuid.uuid4().hex[:8]}"

class EdgeService:
    def __init__(
        self,
        device_id: str,
        sensors: List[BaseSensor],
        detector: HybridDetector,
        store: LocalStore,
        synchronizer: Optional[CloudSynchronizer] = None
    ):
        self.device_id = device_id
        self.sensors = sensors
        self.detector = detector
        self.store = store
        self.synchronizer = synchronizer
        self.operating_state = "NORMAL"  # NORMAL, DEGRADED, RECOVERING, SAFE_STOP
        self.last_sync_time: Optional[str] = None

    def process_sample(self, sample: Sample) -> str:
        """Evaluates sample, generates event_id, commits to local SQLite before sync."""
        decision = self.detector.evaluate(sample)
        event_id = build_event_id(self.device_id, sample.event_time)
        is_fixture = sample.source == "fixture" or "sim" in sample.source
        self.store.add(event_id, self.device_id, sample, decision, is_fixture=is_fixture)
        return event_id

    def step(self) -> dict:
        """Performs one full acquisition, persistence, and synchronization cycle."""
        generated_event_ids: List[str] = []

        try:
            for sensor in self.sensors:
                samples = sensor.read_samples()
                for sample in samples:
                    eid = self.process_sample(sample)
                    generated_event_ids.append(eid)
        except Exception:
            self.operating_state = "SAFE_STOP"
            return {
                "state": self.operating_state,
                "event_ids": generated_event_ids,
                "pending": self.store.count_pending(),
                "synced": 0
            }

        synced_count = 0
        if self.synchronizer:
            status, count = self.synchronizer.sync_batch()
            synced_count = count
            pending_count = self.store.count_pending()

            if status == "OK":
                self.last_sync_time = datetime.now(timezone.utc).isoformat()
                if pending_count > 0:
                    self.operating_state = "RECOVERING"
                else:
                    self.operating_state = "NORMAL"
            elif status == "DEGRADED":
                self.operating_state = "DEGRADED"
            elif status == "AUTH_ERROR":
                self.operating_state = "SAFE_STOP"
        else:
            pending_count = self.store.count_pending()
            self.operating_state = "DEGRADED"

        return {
            "state": self.operating_state,
            "event_ids": generated_event_ids,
            "pending": self.store.count_pending(),
            "synced": synced_count
        }

    def run_loop(self, interval_sec: float = 2.0, max_iterations: Optional[int] = None):
        """Runs the service loop continuously or for a fixed number of steps."""
        iterations = 0
        while max_iterations is None or iterations < max_iterations:
            self.step()
            iterations += 1
            if max_iterations is None or iterations < max_iterations:
                time.sleep(interval_sec)
