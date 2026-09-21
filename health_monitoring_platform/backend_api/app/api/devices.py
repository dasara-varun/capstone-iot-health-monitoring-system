"""Device registry and configuration endpoints."""
from typing import List
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.db_models import DeviceDB
from ..models.schemas import DeviceResponse, DeviceConfigUpdate
from ..services.auth_service import get_current_user, require_operator_role

router = APIRouter(prefix="/devices", tags=["Devices"])

@router.get("", response_model=List[DeviceResponse])
def list_devices(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    devices = db.query(DeviceDB).all()
    if not devices:
        # Register default device if none exists
        now_iso = datetime.now(timezone.utc).isoformat()
        default_device = DeviceDB(
            device_id="edge-device-01",
            name="Raspberry Pi 4 Edge Gateway",
            operating_state="NORMAL",
            software_version="1.0.0",
            last_contact=now_iso,
            last_sync=now_iso,
            queue_depth=0,
            storage_condition="OK",
            sampling_interval_sec=1.0
        )
        db.add(default_device)
        db.commit()
        db.refresh(default_device)
        return [default_device]
    return devices

@router.get("/{device_id}", response_model=DeviceResponse)
def get_device(device_id: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    device = db.query(DeviceDB).filter(DeviceDB.device_id == device_id).first()
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    return device

@router.patch("/{device_id}/config", response_model=DeviceResponse)
def update_device_config(
    device_id: str,
    update: DeviceConfigUpdate,
    db: Session = Depends(get_db),
    operator: dict = Depends(require_operator_role)
):
    device = db.query(DeviceDB).filter(DeviceDB.device_id == device_id).first()
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    if update.sampling_interval_sec is not None:
        device.sampling_interval_sec = update.sampling_interval_sec
    if update.operating_state is not None:
        device.operating_state = update.operating_state

    db.commit()
    db.refresh(device)
    return device
