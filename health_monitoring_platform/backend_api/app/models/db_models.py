"""SQLAlchemy database models for Cloud Backend."""
from sqlalchemy import Column, String, Float, Integer, Text, Boolean
from ..database import Base

class ObservationDB(Base):
    __tablename__ = "observations"

    event_id = Column(String(100), primary_key=True, index=True)
    device_id = Column(String(50), nullable=False, index=True)
    event_time = Column(String(50), nullable=False, index=True)
    sensor = Column(String(30), nullable=False, index=True)
    raw_value = Column(Float, nullable=True)
    processed_value = Column(Float, nullable=True)
    unit = Column(String(20), nullable=False)
    quality_status = Column(String(20), nullable=False, index=True)
    quality_score = Column(Float, nullable=False, default=1.0)
    baseline = Column(Float, nullable=True)
    deviation = Column(Float, nullable=True)
    severity = Column(String(20), nullable=False, index=True)
    confidence = Column(String(20), nullable=False)
    anomaly_score = Column(Float, nullable=True)
    reason_codes = Column(Text, nullable=False, default="[]")
    explanation = Column(Text, nullable=False)
    sync_status = Column(String(20), nullable=False, default="SYNCHRONIZED")
    created_at = Column(String(50), nullable=False)
    is_fixture = Column(Boolean, nullable=False, default=False)


class DeviceDB(Base):
    __tablename__ = "devices"

    device_id = Column(String(50), primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    operating_state = Column(String(20), nullable=False, default="NORMAL")
    software_version = Column(String(20), nullable=False, default="1.0.0")
    last_contact = Column(String(50), nullable=False)
    last_sync = Column(String(50), nullable=True)
    queue_depth = Column(Integer, nullable=False, default=0)
    storage_condition = Column(String(20), nullable=False, default="OK")
    sampling_interval_sec = Column(Float, nullable=False, default=1.0)


class SyncAuditDB(Base):
    __tablename__ = "sync_audits"

    id = Column(Integer, primary_key=True, autoincrement=True)
    device_id = Column(String(50), nullable=False, index=True)
    client_batch_id = Column(String(100), nullable=False)
    received_at = Column(String(50), nullable=False)
    accepted_count = Column(Integer, nullable=False, default=0)
    already_present_count = Column(Integer, nullable=False, default=0)
    rejected_count = Column(Integer, nullable=False, default=0)
    error_category = Column(String(50), nullable=True)


class UserDB(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    password_hash = Column(String(128), nullable=False)
    role = Column(String(20), nullable=False, default="viewer")
    created_at = Column(String(50), nullable=False)
