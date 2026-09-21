"""Alerts endpoint providing explainable engineering review notifications."""
import json
from typing import Optional, List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc
from ..database import get_db
from ..models.db_models import ObservationDB
from ..models.schemas import AlertResponse
from ..services.auth_service import get_current_user

router = APIRouter(tags=["Alerts"])

@router.get("/alerts", response_model=List[AlertResponse])
def get_alerts(
    severity: Optional[str] = Query(None, description="Filter by severity: REVIEW or OBSERVE"),
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    query = db.query(ObservationDB)
    if severity:
        query = query.filter(ObservationDB.severity == severity)
    else:
        query = query.filter(ObservationDB.severity.in_(["REVIEW", "OBSERVE"]))

    records = query.order_by(desc(ObservationDB.event_time)).limit(limit).all()

    return [
        AlertResponse(
            event_id=row.event_id,
            device_id=row.device_id,
            event_time=row.event_time,
            sensor=row.sensor,
            raw_value=row.raw_value,
            processed_value=row.processed_value,
            unit=row.unit,
            baseline=row.baseline,
            deviation=row.deviation,
            severity=row.severity,
            confidence=row.confidence,
            quality_status=row.quality_status,
            reason_codes=json.loads(row.reason_codes) if row.reason_codes else [],
            explanation=row.explanation,
            is_fixture=row.is_fixture
        )
        for row in records
    ]
