"""Unit tests for the edge quality gate (FR-03, FR-04, Test T-04)."""
import unittest
from ..edge.models import Sample
from ..edge.quality import QualityGate

class TestQualityGate(unittest.TestCase):
    def setUp(self):
        self.gate = QualityGate({
            "spo2": (50.0, 100.0),
            "heart_rate": (20.0, 240.0),
            "temperature": (20.0, 45.0)
        })

    def test_acceptable_sample(self):
        sample = Sample(sensor="spo2", value=98.0, unit="%", event_time="2026-09-21T10:00:00Z", quality_hint=0.95)
        status, score, reasons = self.gate.evaluate(sample, [97.0, 98.0, 97.5])
        self.assertEqual(status, "ACCEPTABLE")
        self.assertGreaterEqual(score, 0.9)
        self.assertEqual(len(reasons), 0)

    def test_missing_or_none_value(self):
        sample = Sample(sensor="spo2", value=None, unit="%", event_time="2026-09-21T10:00:00Z")
        status, score, reasons = self.gate.evaluate(sample, [97.0])
        self.assertEqual(status, "INVALID")
        self.assertEqual(score, 0.0)
        self.assertIn("missing_or_nonfinite", reasons)

    def test_outside_configured_range(self):
        sample = Sample(sensor="spo2", value=115.0, unit="%", event_time="2026-09-21T10:00:00Z")
        status, score, reasons = self.gate.evaluate(sample, [97.0])
        self.assertEqual(status, "INVALID")
        self.assertIn("outside_configured_range", reasons)

    def test_short_window_instability(self):
        # Established history around 97.0, sudden drop to 82.0
        history = [97.0, 98.0, 97.0, 97.5]
        sample = Sample(sensor="spo2", value=82.0, unit="%", event_time="2026-09-21T10:00:00Z", quality_hint=0.95)
        status, score, reasons = self.gate.evaluate(sample, history)
        self.assertIn("short_window_instability", reasons)

if __name__ == "__main__":
    unittest.main()
