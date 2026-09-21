"""Ingestion service implementing the idempotent batch synchronization contract."""
import json
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from ..models.db_models import ObservationDB, DeviceDB, SyncAuditDB
from ..models.schemas import IngestBatchRequest, IngestBatchResponse

def process_batch_ingest(batch: IngestBatchRequest, db: Session) -> IngestBatchResponse:
    now_iso = datetime.now(timezone.utc).isoformat()
    accepted: list[str] = []
    already_present: list[str] = []
    rejected: list[str] = []
    retryable: list[str] = []

    # Ensure device exists in registry
    device = db.query(DeviceDB).filter(DeviceDB.device_id == batch.device_id).first()
    if not device:
        device = DeviceDB(
            device_id=batch.device_id,
            name=f"Edge Node ({batch.device_id})",
            operating_state="NORMAL",
            software_version="1.0.0",
            last_contact=now_iso,
            last_sync=now_iso,
            queue_depth=0,
            storage_condition="OK",
            sampling_interval_sec=1.0
        )
        db.add(device)
    else:
        device.last_contact = now_iso
        device.last_sync = now_iso
        device.operating_state = "NORMAL"

    for obs in batch.observations:
        # Check event_id
        if not obs.event_id or not obs.sensor:
            rejected.append(obs.event_id or "unknown")
            continue

        existing = db.query(ObservationDB).filter(ObservationDB.event_id == obs.event_id).first()
        if existing:
            already_present.append(obs.event_id)
            continue

        try:
            db_obs = ObservationDB(
                event_id=obs.event_id,
                device_id=batch.device_id,
                event_time=obs.event_time,
                sensor=obs.sensor,
                raw_value=obs.raw_value,
                processed_value=obs.processed_value,
                unit=obs.unit,
                quality_status=obs.quality_status,
                quality_score=obs.quality_score,
                baseline=obs.baseline,
                deviation=obs.deviation,
                severity=obs.severity,
                confidence=obs.confidence,
                anomaly_score=obs.anomaly_score,
                reason_codes=json.dumps(obs.reason_codes),
                explanation=obs.explanation,
                sync_status="SYNCHRONIZED",
                created_at=now_iso,
                is_fixture=obs.is_fixture
            )
            db.add(db_obs)
            accepted.append(obs.event_id)
        except Exception:
            retryable.append(obs.event_id)

    # Record sync audit
    audit = SyncAuditDB(
        device_id=batch.device_id,
        client_batch_id=batch.client_batch_id,
        received_at=now_iso,
        accepted_count=len(accepted),
        already_present_count=len(already_present),
        rejected_count=len(rejected),
        error_category=None if not retryable else "db_error"
    )
    db.add(audit)
    db.commit()

    return IngestBatchResponse(
        accepted=accepted,
        already_present=already_present,
        retryable=retryable,
        rejected=rejected,
        server_time=now_iso
    )
