"""Authenticated ingestion endpoint for edge device batches."""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.schemas import IngestBatchRequest, IngestBatchResponse
from ..services.auth_service import verify_device_token
from ..services.ingest_service import process_batch_ingest

router = APIRouter(tags=["Ingestion"])

@router.post("/ingest", response_model=IngestBatchResponse)
def ingest_batch(
    batch: IngestBatchRequest,
    db: Session = Depends(get_db),
    authorized: bool = Depends(verify_device_token)
):
    """
    Accepts an authenticated batch of observations from an edge device.
    Enforces idempotent ingestion by checking event_id uniqueness.
    """
    return process_batch_ingest(batch, db)
