"""Pydantic schemas matching the SRS and Single-Codebase API contracts."""
from __future__ import annotations
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field

# ----------------- Auth Schemas -----------------
class LoginRequest(BaseModel):
    username: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
    username: str

class RefreshTokenRequest(BaseModel):
    refresh_token: Optional[str] = None

class UserResponse(BaseModel):
    username: str
    role: str

# ----------------- Observation Schemas -----------------
class ObservationCreate(BaseModel):
    event_id: str
    event_time: str
    sensor: str
    raw_value: Optional[float] = None
    processed_value: Optional[float] = None
    unit: str
    quality_status: str  # ACCEPTABLE, LOW, INVALID
    quality_score: float = 1.0
    baseline: Optional[float] = None
    deviation: Optional[float] = None
    severity: str  # NORMAL, OBSERVE, REVIEW
    confidence: str  # HIGH, MEDIUM, LOW
    anomaly_score: Optional[float] = None
    reason_codes: List[str] = Field(default_factory=list)
    explanation: str
    is_fixture: bool = False

class ObservationResponse(BaseModel):
    event_id: str
    device_id: str
    event_time: str
    sensor: str
    raw_value: Optional[float] = None
    processed_value: Optional[float] = None
    unit: str
    quality_status: str
    quality_score: float
    baseline: Optional[float] = None
    deviation: Optional[float] = None
    severity: str
    confidence: str
    anomaly_score: Optional[float] = None
    reason_codes: List[str]
    explanation: str
    sync_status: str
    created_at: str
    is_fixture: bool

    class Config:
        from_attributes = True

# ----------------- Ingestion Batch Schemas -----------------
class IngestBatchRequest(BaseModel):
    schema_version: str = "1.0"
    device_id: str
    client_batch_id: str
    observations: List[ObservationCreate]

class IngestBatchResponse(BaseModel):
    accepted: List[str]
    already_present: List[str]
    retryable: List[str]
    rejected: List[str]
    server_time: str

# ----------------- Overview Schemas -----------------
class OverviewResponse(BaseModel):
    system_state: str  # NORMAL, DEGRADED, RECOVERING, SAFE_STOP
    latest_observations: Dict[str, ObservationResponse]
    pending_queue_count: int
    last_successful_sync: Optional[str] = None
    processing_version: str = "1.0.0"
    disclaimer: str = (
        "NON-DIAGNOSTIC PROTOTYPE: This system is a research and engineering decision-support "
        "prototype. It does not diagnose medical conditions, provide clinical advice, or replace "
        "professional healthcare assessment."
    )

# ----------------- Alert Schemas -----------------
class AlertResponse(BaseModel):
    event_id: str
    device_id: str
    event_time: str
    sensor: str
    raw_value: Optional[float] = None
    processed_value: Optional[float] = None
    unit: str
    baseline: Optional[float] = None
    deviation: Optional[float] = None
    severity: str
    confidence: str
    quality_status: str
    reason_codes: List[str]
    explanation: str
    is_fixture: bool

# ----------------- Device Schemas -----------------
class DeviceResponse(BaseModel):
    device_id: str
    name: str
    operating_state: str
    software_version: str
    last_contact: str
    last_sync: Optional[str] = None
    queue_depth: int
    storage_condition: str
    sampling_interval_sec: float

    class Config:
        from_attributes = True

class DeviceConfigUpdate(BaseModel):
    sampling_interval_sec: Optional[float] = None
    operating_state: Optional[str] = None

class SyncStatusResponse(BaseModel):
    device_id: str
    last_sync: Optional[str] = None
    queue_depth: int
    operating_state: str
    storage_condition: str

# ----------------- Test Fixture Schemas -----------------
class FixtureRequest(BaseModel):
    device_id: str = "edge-device-01"
    scenario: str  # e.g., 'normal', 'spo2_drop', 'tachycardia', 'noise_spike', 'sensor_fault'
    count: int = 1
