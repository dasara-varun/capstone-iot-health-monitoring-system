"""Unit tests for SQLite LocalStore (FR-08, FR-09, Test T-03)."""
import os
import unittest
from ..edge.models import Sample, Decision
from ..edge.store import LocalStore

class TestLocalStore(unittest.TestCase):
    def setUp(self):
        self.db_path = "test_edge_temp.db"
        if os.path.exists(self.db_path):
            os.remove(self.db_path)
        self.store = LocalStore(self.db_path)

    def tearDown(self):
        self.store.close()
        if os.path.exists(self.db_path):
            try:
                os.remove(self.db_path)
            except Exception:
                pass

    def test_write_and_pending_retrieval(self):
        sample = Sample("spo2", 97.0, "%", "2026-09-21T10:00:00Z")
        decision = Decision("ACCEPTABLE", 0.95, 97.0, 97.0, 0.0, "NORMAL", "HIGH", 0.0, [], "Normal")
        
        self.store.add("evt-001", "edge-dev-01", sample, decision)
        
        pending = self.store.pending()
        self.assertEqual(len(pending), 1)
        self.assertEqual(pending[0]["event_id"], "evt-001")
        self.assertEqual(pending[0]["sync_status"], "PENDING")
        self.assertEqual(pending[0]["raw_value"], 97.0)

    def test_idempotent_insert_or_ignore(self):
        sample = Sample("spo2", 97.0, "%", "2026-09-21T10:00:00Z")
        decision = Decision("ACCEPTABLE", 0.95, 97.0, 97.0, 0.0, "NORMAL", "HIGH", 0.0, [], "Normal")

        # Insert once
        self.store.add("evt-dup-01", "edge-dev-01", sample, decision)
        # Insert duplicate event_id
        self.store.add("evt-dup-01", "edge-dev-01", sample, decision)

        self.assertEqual(self.store.count_total(), 1)

    def test_mark_synced(self):
        sample = Sample("spo2", 97.0, "%", "2026-09-21T10:00:00Z")
        decision = Decision("ACCEPTABLE", 0.95, 97.0, 97.0, 0.0, "NORMAL", "HIGH", 0.0, [], "Normal")

        self.store.add("evt-sync-01", "edge-dev-01", sample, decision)
        self.assertEqual(self.store.count_pending(), 1)

        self.store.mark_synced(["evt-sync-01"])
        self.assertEqual(self.store.count_pending(), 0)

if __name__ == "__main__":
    unittest.main()
