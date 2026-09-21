"""Quality gate for noise awareness, missingness, and range validation."""
import math
from statistics import median, pstdev
from typing import List, Tuple, Optional
from .models import Sample

class QualityGate:
    def __init__(self, ranges: dict[str, Tuple[float, float]]):
        self.ranges = ranges

    def evaluate(self, sample: Sample, history: List[float]) -> Tuple[str, float, List[str]]:
        """
        Evaluates sample quality.
        Returns:
            (quality_status, quality_score, reason_codes)
        """
        reasons: List[str] = []

        # Check 1: Missing or non-finite
        if sample.value is None or not math.isfinite(sample.value):
            return "INVALID", 0.0, ["missing_or_nonfinite"]

        # Check 2: Plausibility range
        low, high = self.ranges.get(sample.sensor, (-math.inf, math.inf))
        if sample.value < low or sample.value > high:
            return "INVALID", 0.0, ["outside_configured_range"]

        # Check 3: Sensor quality hint
        score = sample.quality_hint if sample.quality_hint is not None else 1.0

        # Check 4: Short-window standard deviation instability / spikes
        if history:
            med_val = median(history)
            dev_limit = max(5.0, 3.0 * (pstdev(history) if len(history) > 1 else 1.0))
            if abs(sample.value - med_val) > dev_limit:
                score *= 0.6
                reasons.append("short_window_instability")

        if score < 0.5:
            return "LOW", round(score, 2), reasons + ["low_quality_signal"]

        return "ACCEPTABLE", round(min(score, 1.0), 2), reasons
