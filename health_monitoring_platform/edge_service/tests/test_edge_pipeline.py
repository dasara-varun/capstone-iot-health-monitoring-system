"""End-to-end smoke test verifying edge pipeline matches edge_smoke_output.txt."""
import os
import unittest
from datetime import datetime, timezone
from ..edge.models import Sample
from ..edge.detector import HybridDetector
from ..edge.store import LocalStore
from ..edge.service import EdgeService, build_event_id

class TestEdgeSmokePipeline(unittest.TestCase):
    def setUp(self):
        self.db_path = "test_smoke_edge.db"
        if os.path.exists(self.db_path):
            os.remove(self.db_path)
        self.store = LocalStore(self.db_path)
        self.detector = HybridDetector({
            "spo2": (50.0, 100.0),
            "heart_rate": (20.0, 240.0),
            "temperature": (20.0, 45.0)
        })

    def tearDown(self):
        self.store.close()
        if os.path.exists(self.db_path):
            try:
                os.remove(self.db_path)
            except Exception:
                pass

    def test_reproduce_smoke_run(self):
        device = "edge-device-01"
        now = "2026-09-21T04:31:22.362767+00:00"

        # Sample 1: SpO2 = 97%
        s1 = Sample("spo2", 97.0, "%", now, quality_hint=0.95)
        d1 = self.detector.evaluate(s1)
        eid1 = build_event_id(device, s1.event_time)
        self.store.add(eid1, device, s1, d1)

        self.assertEqual(d1.quality_status, "ACCEPTABLE")
        self.assertEqual(d1.severity, "NORMAL")
        self.assertEqual(d1.confidence, "HIGH")

        # Sample 2: SpO2 = 91% (sudden dip triggers short_window_instability)
        s2 = Sample("spo2", 91.0, "%", now, quality_hint=0.95)
        d2 = self.detector.evaluate(s2)
        eid2 = build_event_id(device, s2.event_time)
        self.store.add(eid2, device, s2, d2)

        self.assertEqual(d2.quality_status, "ACCEPTABLE")
        self.assertIn("short_window_instability", d2.reason_codes)

        # Inspect pending queue
        pending = self.store.pending()
        self.assertEqual(len(pending), 2)
        self.assertEqual(pending[0]["sync_status"], "PENDING")
        self.assertEqual(pending[1]["sync_status"], "PENDING")
        self.assertEqual(pending[0]["raw_value"], 97.0)
        self.assertEqual(pending[1]["raw_value"], 91.0)

if __name__ == "__main__":
    unittest.main()
