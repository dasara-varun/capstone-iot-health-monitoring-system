"""Edge domain models matching the formal SRS and edge_monitor specification."""
from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional, List

@dataclass
class Sample:
    sensor: str
    value: Optional[float]
    unit: str
    event_time: str
    quality_hint: Optional[float] = None
    source: str = "sensor"  # "max30102", "temperature", "fixture"

@dataclass
class Decision:
    quality_status: str        # "ACCEPTABLE", "LOW", "INVALID"
    quality_score: float       # 0.0 - 1.0
    processed_value: Optional[float]
    baseline: Optional[float]
    deviation: Optional[float]
    severity: str              # "NORMAL", "OBSERVE", "REVIEW"
    confidence: str            # "HIGH", "MEDIUM", "LOW"
    anomaly_score: Optional[float]
    reason_codes: List[str] = field(default_factory=list)
    explanation: str = ""
