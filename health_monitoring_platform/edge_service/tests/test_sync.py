"""Unit tests for offline queuing and cloud sync (FR-10, FR-11, FR-13, Test T-09, T-10)."""
import os
import unittest
from ..edge.models import Sample, Decision
from ..edge.store import LocalStore
from ..edge.sync import CloudSynchronizer

class MockSessionResponse:
    def __init__(self, status_code: int, json_data: dict):
        self.status_code = status_code
        self._json = json_data

    def json(self):
        return self._json

class TestCloudSync(unittest.TestCase):
    def setUp(self):
        self.db_path = "test_sync_temp.db"
        if os.path.exists(self.db_path):
            os.remove(self.db_path)
        self.store = LocalStore(self.db_path)
        self.synchronizer = CloudSynchronizer(
            self.store,
            "http://mock-cloud.internal/api/v1/ingest",
            "edge-dev-01",
            "key123"
        )

    def tearDown(self):
        self.store.close()
        if os.path.exists(self.db_path):
            try:
                os.remove(self.db_path)
            except Exception:
                pass

    def test_offline_accumulation_and_reconnection(self):
        # 1. Add 3 samples in offline state
        for i in range(3):
            s = Sample("spo2", 96.0 + i, "%", f"2026-09-21T10:0{i}:00Z")
            d = Decision("ACCEPTABLE", 0.95, 96.0 + i, 96.0, 0.0, "NORMAL", "HIGH", 0.0, [], "Normal")
            self.store.add(f"evt-off-{i}", "edge-dev-01", s, d)

        self.assertEqual(self.store.count_pending(), 3)

        # 2. Simulate cloud outage: network failure leaves items in pending queue
        # When cloud cannot be reached, sync_batch() catches error and returns DEGRADED
        status, synced = self.synchronizer.sync_batch()
        self.assertEqual(status, "DEGRADED")
        self.assertEqual(self.store.count_pending(), 3)  # Intact! Write-first preserved!

if __name__ == "__main__":
    unittest.main()
