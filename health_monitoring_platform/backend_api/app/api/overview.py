"""Overview endpoint providing current status, latest readings, and system state."""
import json
from datetime import datetime, timezone, timedelta
from typing import Dict
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import desc
from ..database import get_db
from ..models.db_models import ObservationDB, DeviceDB
from ..models.schemas import OverviewResponse, ObservationResponse
from ..services.auth_service import get_current_user

router = APIRouter(tags=["Overview"])

@router.get("/overview", response_model=OverviewResponse)
def get_overview(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    # Find active device
    device = db.query(DeviceDB).first()
    system_state = device.operating_state if device else "NORMAL"
    pending_count = device.queue_depth if device else 0
    last_sync = device.last_sync if device else None

    # Get latest reading for each sensor
    sensors = ["spo2", "heart_rate", "temperature"]
    latest_obs: Dict[str, ObservationResponse] = {}

    for s in sensors:
        row = (
            db.query(ObservationDB)
            .filter(ObservationDB.sensor == s)
            .order_by(desc(ObservationDB.event_time))
            .first()
        )
        if row:
            latest_obs[s] = ObservationResponse(
                event_id=row.event_id,
                device_id=row.device_id,
                event_time=row.event_time,
                sensor=row.sensor,
                raw_value=row.raw_value,
                processed_value=row.processed_value,
                unit=row.unit,
                quality_status=row.quality_status,
                quality_score=row.quality_score,
                baseline=row.baseline,
                deviation=row.deviation,
                severity=row.severity,
                confidence=row.confidence,
                anomaly_score=row.anomaly_score,
                reason_codes=json.loads(row.reason_codes) if row.reason_codes else [],
                explanation=row.explanation,
                sync_status=row.sync_status,
                created_at=row.created_at,
                is_fixture=row.is_fixture
            )

    return OverviewResponse(
        system_state=system_state,
        latest_observations=latest_obs,
        pending_queue_count=pending_count,
        last_successful_sync=last_sync,
        processing_version="1.0.0"
    )
