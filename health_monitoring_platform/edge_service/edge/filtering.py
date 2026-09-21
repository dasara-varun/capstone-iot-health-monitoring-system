"""Transparent median filtering over sliding windows."""
from statistics import median
from typing import List, Optional

class MedianFilter:
    def __init__(self, window_size: int = 5):
        self.window_size = window_size

    def compute(self, raw_value: Optional[float], history: List[float]) -> Optional[float]:
        if raw_value is None:
            return None
        combined = (history + [raw_value])[-self.window_size:]
        return round(float(median(combined)), 2)
