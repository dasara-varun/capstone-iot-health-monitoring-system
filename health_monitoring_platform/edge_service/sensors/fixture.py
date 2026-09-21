"""Deterministic test fixtures for Review-2 rubric evaluation."""
from datetime import datetime, timezone
from typing import List
from .base import BaseSensor
from ..edge.models import Sample

class FixtureGenerator(BaseSensor):
    def __init__(self, scenario: str = "normal"):
        self.scenario = scenario

    def is_hardware_present(self) -> bool:
        return False

    def read_samples(self) -> List[Sample]:
        now_iso = datetime.now(timezone.utc).isoformat()

        if self.scenario == "spo2_drop":
            return [
                Sample(sensor="spo2", value=88.0, unit="%", event_time=now_iso, quality_hint=0.95, source="fixture"),
                Sample(sensor="heart_rate", value=92.0, unit="bpm", event_time=now_iso, quality_hint=0.95, source="fixture")
            ]
        elif self.scenario == "noise_spike":
            return [
                Sample(sensor="spo2", value=62.0, unit="%", event_time=now_iso, quality_hint=0.40, source="fixture"),
                Sample(sensor="heart_rate", value=74.0, unit="bpm", event_time=now_iso, quality_hint=0.90, source="fixture")
            ]
        elif self.scenario == "tachycardia":
            return [
                Sample(sensor="spo2", value=97.0, unit="%", event_time=now_iso, quality_hint=0.98, source="fixture"),
                Sample(sensor="heart_rate", value=142.0, unit="bpm", event_time=now_iso, quality_hint=0.96, source="fixture")
            ]
        elif self.scenario == "sensor_fault":
            return [
                Sample(sensor="spo2", value=None, unit="%", event_time=now_iso, quality_hint=0.0, source="fixture"),
                Sample(sensor="heart_rate", value=999.0, unit="bpm", event_time=now_iso, quality_hint=0.0, source="fixture")
            ]
        else:
            return [
                Sample(sensor="spo2", value=98.0, unit="%", event_time=now_iso, quality_hint=0.98, source="fixture"),
                Sample(sensor="heart_rate", value=72.0, unit="bpm", event_time=now_iso, quality_hint=0.97, source="fixture"),
                Sample(sensor="temperature", value=36.6, unit="degC", event_time=now_iso, quality_hint=0.99, source="fixture")
            ]
