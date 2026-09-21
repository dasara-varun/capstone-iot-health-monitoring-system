"""Test fixture endpoints for evaluating anomaly detection scenarios under controlled conditions."""
import uuid
from datetime import datetime, timezone
from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.schemas import FixtureRequest, IngestBatchRequest, ObservationCreate, IngestBatchResponse
from ..services.auth_service import require_operator_role
from ..services.ingest_service import process_batch_ingest

router = APIRouter(prefix="/tests", tags=["Tests & Fixtures"])

@router.post("/fixtures", response_model=IngestBatchResponse)
def inject_test_fixture(
    req: FixtureRequest,
    db: Session = Depends(get_db),
    operator: dict = Depends(require_operator_role)
):
    """
    Injects reproducible simulated physiological test scenarios into the backend.
    All records generated through this endpoint are explicitly marked with is_fixture=True.
    """
    now = datetime.now(timezone.utc)
    observations: List[ObservationCreate] = []

    def make_event_id(sensor_name: str) -> str:
        return f"{req.device_id}-fixture-{now.strftime('%Y%m%d%H%M%S')}-{sensor_name}-{uuid.uuid4().hex[:6]}"

    if req.scenario == "spo2_drop":
        # SpO2 hypoxia anomaly
        observations.append(ObservationCreate(
            event_id=make_event_id("spo2"),
            event_time=now.isoformat(),
            sensor="spo2",
            raw_value=88.0,
            processed_value=88.5,
            unit="%",
            quality_status="ACCEPTABLE",
            quality_score=0.92,
            baseline=97.0,
            deviation=-8.5,
            severity="REVIEW",
            confidence="HIGH",
            anomaly_score=0.85,
            reason_codes=["deviation_from_baseline", "sustained_hypoxia_pattern"],
            explanation="SpO2 deviation of -8.5% below baseline detected. Engineering review required.",
            is_fixture=True
        ))
    elif req.scenario == "tachycardia":
        # Elevated heart rate anomaly
        observations.append(ObservationCreate(
            event_id=make_event_id("heart_rate"),
            event_time=now.isoformat(),
            sensor="heart_rate",
            raw_value=138.0,
            processed_value=135.0,
            unit="bpm",
            quality_status="ACCEPTABLE",
            quality_score=0.95,
            baseline=74.0,
            deviation=61.0,
            severity="REVIEW",
            confidence="HIGH",
            anomaly_score=0.90,
            reason_codes=["deviation_from_baseline", "elevated_pulse_rate"],
            explanation="Heart rate reading of 135 bpm deviates +61 bpm from baseline.",
            is_fixture=True
        ))
    elif req.scenario == "noise_spike":
        # Motion artifact noise
        observations.append(ObservationCreate(
            event_id=make_event_id("spo2"),
            event_time=now.isoformat(),
            sensor="spo2",
            raw_value=62.0,
            processed_value=93.0,
            unit="%",
            quality_status="LOW",
            quality_score=0.45,
            baseline=96.0,
            deviation=-3.0,
            severity="OBSERVE",
            confidence="LOW",
            anomaly_score=0.20,
            reason_codes=["short_window_instability", "low_quality_signal"],
            explanation="Sensor signal unstable; filtered median applied without high-confidence alert.",
            is_fixture=True
        ))
    elif req.scenario == "sensor_fault":
        # Out of bounds / unplugged
        observations.append(ObservationCreate(
            event_id=make_event_id("temperature"),
            event_time=now.isoformat(),
            sensor="temperature",
            raw_value=999.0,
            processed_value=None,
            unit="degC",
            quality_status="INVALID",
            quality_score=0.0,
            baseline=36.6,
            deviation=None,
            severity="OBSERVE",
            confidence="LOW",
            anomaly_score=0.0,
            reason_codes=["outside_configured_range", "hardware_fault"],
            explanation="Reading outside physically plausible physiological range (20-45 C).",
            is_fixture=True
        ))
    else:
        # Default normal readings
        observations.extend([
            ObservationCreate(
                event_id=make_event_id("spo2"),
                event_time=now.isoformat(),
                sensor="spo2",
                raw_value=98.0,
                processed_value=98.0,
                unit="%",
                quality_status="ACCEPTABLE",
                quality_score=0.98,
                baseline=98.0,
                deviation=0.0,
                severity="NORMAL",
                confidence="HIGH",
                anomaly_score=0.0,
                reason_codes=[],
                explanation="Processed value is within the current baseline.",
                is_fixture=True
            ),
            ObservationCreate(
                event_id=make_event_id("heart_rate"),
                event_time=now.isoformat(),
                sensor="heart_rate",
                raw_value=72.0,
                processed_value=72.0,
                unit="bpm",
                quality_status="ACCEPTABLE",
                quality_score=0.96,
                baseline=72.0,
                deviation=0.0,
                severity="NORMAL",
                confidence="HIGH",
                anomaly_score=0.0,
                reason_codes=[],
                explanation="Heart rate normal and within baseline range.",
                is_fixture=True
            ),
            ObservationCreate(
                event_id=make_event_id("temperature"),
                event_time=now.isoformat(),
                sensor="temperature",
                raw_value=36.6,
                processed_value=36.6,
                unit="degC",
                quality_status="ACCEPTABLE",
                quality_score=0.99,
                baseline=36.6,
                deviation=0.0,
                severity="NORMAL",
                confidence="HIGH",
                anomaly_score=0.0,
                reason_codes=[],
                explanation="Body temperature steady within normal range.",
                is_fixture=True
            )
        ])

    batch = IngestBatchRequest(
        schema_version="1.0",
        device_id=req.device_id,
        client_batch_id=f"fixture-batch-{now.strftime('%Y%m%d%H%M%S')}",
        observations=observations
    )

    return process_batch_ingest(batch, db)
