"""Configuration settings for Raspberry Pi Edge Service."""
import os

DEVICE_ID = os.getenv("DEVICE_ID", "edge-device-01")
EDGE_DB_PATH = os.getenv("EDGE_DB_PATH", "edge_monitor.db")
CLOUD_INGEST_URL = os.getenv("CLOUD_INGEST_URL", "http://127.0.0.1:8000/api/v1/ingest")
DEVICE_API_KEY = os.getenv("DEVICE_API_KEY", "device-secret-key-edge-01")

SAMPLING_INTERVAL_SEC = float(os.getenv("SAMPLING_INTERVAL_SEC", "2.0"))
SYNC_BATCH_SIZE = int(os.getenv("SYNC_BATCH_SIZE", "50"))
SYNC_INTERVAL_SEC = float(os.getenv("SYNC_INTERVAL_SEC", "5.0"))

SENSOR_RANGES = {
    "spo2": (50.0, 100.0),        # Blood oxygen percentage
    "heart_rate": (20.0, 240.0),   # Beats per minute
    "temperature": (20.0, 45.0)    # Celsius
}
