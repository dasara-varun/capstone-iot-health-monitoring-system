"""Cloud synchronization worker for authenticated batch ingestion with backoff."""
import uuid
from datetime import datetime, timezone
from typing import Tuple
import requests
from .store import LocalStore

class CloudSynchronizer:
    def __init__(self, store: LocalStore, cloud_url: str, device_id: str, device_api_key: str):
        self.store = store
        self.cloud_url = cloud_url
        self.device_id = device_id
        self.device_api_key = device_api_key

    def sync_batch(self, batch_size: int = 50) -> Tuple[str, int]:
        """
        Drains pending records from local store and pushes to cloud ingestion API.
        Returns:
            (status_code: "OK" | "DEGRADED" | "AUTH_ERROR" | "EMPTY", acknowledged_count: int)
        """
        batch = self.store.pending(batch_size)
        if not batch:
            return "EMPTY", 0

        client_batch_id = f"batch-{self.device_id}-{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')}-{uuid.uuid4().hex[:6]}"

        payload = {
            "schema_version": "1.0",
            "device_id": self.device_id,
            "client_batch_id": client_batch_id,
            "observations": [
                {
                    "event_id": row["event_id"],
                    "event_time": row["event_time"],
                    "sensor": row["sensor"],
                    "raw_value": row["raw_value"],
                    "processed_value": row["processed_value"],
                    "unit": row["unit"],
                    "quality_status": row["quality_status"],
                    "quality_score": row["quality_score"],
                    "baseline": row["baseline"],
                    "deviation": row["deviation"],
                    "severity": row["severity"],
                    "confidence": row["confidence"],
                    "anomaly_score": row["anomaly_score"],
                    "reason_codes": row["reason_codes"],
                    "explanation": row["explanation"],
                    "is_fixture": row["is_fixture"]
                }
                for row in batch
            ]
        }

        headers = {
            "Content-Type": "application/json",
            "X-Device-Token": self.device_api_key
        }

        try:
            resp = requests.post(self.cloud_url, json=payload, headers=headers, timeout=5.0)

            if resp.status_code == 200:
                data = resp.json()
                acknowledged = data.get("accepted", []) + data.get("already_present", [])
                if acknowledged:
                    self.store.mark_synced(acknowledged)
                self.store.record_sync(len(batch), "OK")
                return "OK", len(acknowledged)
            elif resp.status_code in (401, 403):
                self.store.record_sync(len(batch), "STOP", "authentication_failure")
                return "AUTH_ERROR", 0
            else:
                self.store.record_sync(len(batch), "RETRY", f"http_{resp.status_code}")
                return "DEGRADED", 0

        except requests.exceptions.Timeout:
            self.store.record_sync(len(batch), "RETRY", "timeout")
            return "DEGRADED", 0
        except requests.exceptions.ConnectionError:
            self.store.record_sync(len(batch), "RETRY", "connection_refused")
            return "DEGRADED", 0
        except Exception as ex:
            self.store.record_sync(len(batch), "RETRY", str(type(ex).__name__))
            return "DEGRADED", 0
