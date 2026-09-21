"""Body / environmental temperature sensor adapter."""
import random
from datetime import datetime, timezone
from typing import List
from .base import BaseSensor
from ..edge.models import Sample

class TemperatureAdapter(BaseSensor):
    def __init__(self, sensor_path: str = "/sys/bus/w1/devices/"):
        self.sensor_path = sensor_path
        self._hardware_available = False

    def is_hardware_present(self) -> bool:
        return self._hardware_available

    def read_samples(self) -> List[Sample]:
        now_iso = datetime.now(timezone.utc).isoformat()
        temp_val = round(36.5 + random.uniform(-0.15, 0.15), 1)
        return [
            Sample(
                sensor="temperature",
                value=temp_val,
                unit="degC",
                event_time=now_iso,
                quality_hint=0.99,
                source="temp_sensor" if self._hardware_available else "temp_sim"
            )
        ]
