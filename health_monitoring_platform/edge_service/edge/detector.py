"""Hybrid baseline and rule-based anomaly detector with explainable decisions."""
from statistics import mean, pstdev
from typing import Dict, List, Tuple
from .models import Sample, Decision
from .quality import QualityGate
from .filtering import MedianFilter

class HybridDetector:
    def __init__(self, ranges: dict[str, Tuple[float, float]], window_size: int = 5):
        self.quality_gate = QualityGate(ranges)
        self.filter = MedianFilter(window_size)
        self.window_size = window_size
        self.windows: Dict[str, List[float]] = {}
        self.baselines: Dict[str, float] = {}

    def evaluate(self, sample: Sample) -> Decision:
        history = self.windows.setdefault(sample.sensor, [])
        status, qscore, quality_reasons = self.quality_gate.evaluate(sample, history)

        processed = self.filter.compute(sample.value, history)

        if processed is None or status == "INVALID":
            return Decision(
                quality_status=status,
                quality_score=qscore,
                processed_value=None,
                baseline=self.baselines.get(sample.sensor, None),
                deviation=None,
                severity="OBSERVE",
                confidence="LOW",
                anomaly_score=0.0,
                reason_codes=quality_reasons,
                explanation="The sample is missing or invalid; no confident anomaly decision was made."
            )

        baseline = self.baselines.get(sample.sensor, mean(history) if history else processed)
        deviation = round(processed - baseline, 2)
        reasons = list(quality_reasons)
        rule_evidence = 0.0

        std_dev = pstdev(history) if len(history) > 1 else 1.0
        deviation_threshold = max(3.0, 2.5 * std_dev)

        if abs(deviation) > deviation_threshold:
            rule_evidence = min(1.0, round(abs(deviation) / 10.0, 2))
            reasons.append("deviation_from_baseline")

        # Severity assessment
        if status == "LOW":
            severity = "OBSERVE"
        elif rule_evidence >= 0.7:
            severity = "REVIEW"
        elif rule_evidence > 0.0:
            severity = "OBSERVE"
        else:
            severity = "NORMAL"

        # Confidence assessment
        if status == "ACCEPTABLE" and not quality_reasons:
            confidence = "HIGH"
        elif status == "ACCEPTABLE":
            confidence = "MEDIUM"
        else:
            confidence = "LOW"

        # Explanation generation
        if not reasons:
            explanation = "Processed value is within the current baseline."
        else:
            explanation = f"Decision based on: {', '.join(reasons)}."

        # Update sliding history
        history.append(float(sample.value))
        del history[:-self.window_size]

        # Update baseline gradually only on acceptable readings
        if status == "ACCEPTABLE":
            self.baselines[sample.sensor] = round(0.9 * baseline + 0.1 * processed, 2)

        return Decision(
            quality_status=status,
            quality_score=qscore,
            processed_value=processed,
            baseline=round(baseline, 2),
            deviation=deviation,
            severity=severity,
            confidence=confidence,
            anomaly_score=rule_evidence,
            reason_codes=reasons,
            explanation=explanation
        )
