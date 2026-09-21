"""Configuration settings for the Cloud-Based IoT Health Monitoring backend API."""
import os
from pydantic import BaseModel

class Settings(BaseModel):
    APP_NAME: str = "Cloud-Based IoT Health Monitoring Backend API"
    VERSION: str = "1.0.0"
    API_V1_PREFIX: str = "/api/v1"
    
    # Security
    JWT_SECRET: str = os.getenv("JWT_SECRET", "iot-health-secret-key-change-in-prod-2026")
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours
    DEVICE_API_KEY: str = os.getenv("DEVICE_API_KEY", "device-secret-key-edge-01")
    
    # Database (defaults to SQLite, supports PostgreSQL via env)
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./health_cloud.db")
    
    # CORS
    CORS_ORIGINS: list[str] = ["*"]

settings = Settings()
