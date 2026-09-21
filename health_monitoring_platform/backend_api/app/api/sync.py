"""Synchronization status endpoints for device monitoring."""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.db_models import DeviceDB
from ..models.schemas import SyncStatusResponse
from ..services.auth_service import get_current_user

router = APIRouter(prefix="/sync", tags=["Synchronization"])

@router.get("/{device_id}/status", response_model=SyncStatusResponse)
def get_sync_status(device_id: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    device = db.query(DeviceDB).filter(DeviceDB.device_id == device_id).first()
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    return SyncStatusResponse(
        device_id=device.device_id,
        last_sync=device.last_sync,
        queue_depth=device.queue_depth,
        operating_state=device.operating_state,
        storage_condition=device.storage_condition
    )
