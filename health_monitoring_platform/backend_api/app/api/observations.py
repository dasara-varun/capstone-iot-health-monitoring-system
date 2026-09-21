"""Observations endpoint for querying historical physiological data."""
import json
from typing import Optional, List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc
from ..database import get_db
from ..models.db_models import ObservationDB
from ..models.schemas import ObservationResponse
from ..services.auth_service import get_current_user

router = APIRouter(tags=["Observations"])

@router.get("/observations", response_model=List[ObservationResponse])
def get_observations(
    sensor: Optional[str] = Query(None, description="Filter by sensor channel (spo2, heart_rate, temperature)"),
    severity: Optional[str] = Query(None, description="Filter by severity (NORMAL, OBSERVE, REVIEW)"),
    quality_status: Optional[str] = Query(None, description="Filter by quality (ACCEPTABLE, LOW, INVALID)"),
    is_fixture: Optional[bool] = Query(None, description="Filter real vs simulated data"),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    query = db.query(ObservationDB)

    if sensor:
        query = query.filter(ObservationDB.sensor == sensor)
    if severity:
        query = query.filter(ObservationDB.severity == severity)
    if quality_status:
        query = query.filter(ObservationDB.quality_status == quality_status)
    if is_fixture is not None:
        query = query.filter(ObservationDB.is_fixture == is_fixture)

    records = query.order_by(desc(ObservationDB.event_time)).offset(offset).limit(limit).all()

    return [
        ObservationResponse(
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
        for row in records
    ]
