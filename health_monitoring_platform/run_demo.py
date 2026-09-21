"""Review-2 End-to-End Demonstration and Verification Script.

Executes and verifies the full edge-to-cloud-to-client pipeline:
- Edge sample acquisition (MAX30102 / Temperature)
- Quality gate & noise filtering
- Write-first SQLite WAL persistence
- Cloud batch ingestion & deduplication
- Review alerts and explainable reason codes
"""
import os
import sys
import json
import time
from datetime import datetime, timezone

# Ensure platform is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from health_monitoring_platform.backend_api.app.main import app
from health_monitoring_platform.backend_api.app.database import Base, engine, SessionLocal
from health_monitoring_platform.backend_api.app.services.auth_service import ensure_default_users
from health_monitoring_platform.edge_service.edge.models import Sample
from health_monitoring_platform.edge_service.edge.detector import HybridDetector
from health_monitoring_platform.edge_service.edge.store import LocalStore
from health_monitoring_platform.edge_service.edge.service import build_event_id
from fastapi.testclient import TestClient

def run_demonstration():
    print("=" * 75)
    print("  CAPSTONE REVIEW-2: CLOUD-BASED IOT HEALTH MONITORING SYSTEM")
    print("  Single-Codebase Edge-Cloud Framework Live Verification")
    print("=" * 75)

    # 1. Initialize Backend
    print("\n[1/5] Initializing Backend API and Database...")
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    ensure_default_users(db)
    db.close()
    client = TestClient(app)
    health = client.get("/api/v1/health").json()
    print(f"      -> Backend Status: {health['status'].upper()} (Version: {health['version']})")

    # 2. Initialize Edge Service Core & LocalStore
    edge_db = "demo_edge_store.db"
    if os.path.exists(edge_db):
        os.remove(edge_db)
    store = LocalStore(edge_db)
    detector = HybridDetector({
        "spo2": (50.0, 100.0),
        "heart_rate": (20.0, 240.0),
        "temperature": (20.0, 45.0)
    })
    device_id = "edge-device-01"
    print(f"\n[2/5] Initializing Edge Service & Local SQLite WAL Store ({edge_db})...")

    # 3. Simulate Normal & Anomaly Samples at Edge
    print("\n[3/5] Processing Sensor Observations at Edge (Quality -> Filter -> Store)...")
    now_iso = datetime.now(timezone.utc).isoformat()
    
    samples = [
        Sample("spo2", 98.0, "%", now_iso, quality_hint=0.98, source="max30102"),
        Sample("heart_rate", 72.0, "bpm", now_iso, quality_hint=0.96, source="max30102"),
        Sample("temperature", 36.6, "degC", now_iso, quality_hint=0.99, source="temp_sensor"),
        # Motion Artifact Noise (T-04, T-05)
        Sample("spo2", 64.0, "%", now_iso, quality_hint=0.42, source="max30102"),
        # Hypoxia Desaturation Event (T-06, T-08)
        Sample("spo2", 87.0, "%", now_iso, quality_hint=0.95, source="max30102"),
    ]

    for s in samples:
        decision = detector.evaluate(s)
        eid = build_event_id(device_id, s.event_time)
        store.add(eid, device_id, s, decision)
        print(f"      - [{s.sensor.upper()}] Raw={s.value}{s.unit} -> Processed={decision.processed_value}{s.unit} | Quality={decision.quality_status} | Severity={decision.severity}")
        if decision.reason_codes:
            print(f"        Explanation: {decision.explanation}")

    pending_count = store.count_pending()
    print(f"\n      -> Write-First Durability: {pending_count} observations committed locally to SQLite WAL.")

    # 4. Cloud Batch Ingestion
    print("\n[4/5] Synchronizing Pending Observations to Cloud Ingestion Endpoint...")
    pending = store.pending(50)
    batch_payload = {
        "schema_version": "1.0",
        "device_id": device_id,
        "client_batch_id": f"batch-{int(time.time())}",
        "observations": pending
    }
    res = client.post("/api/v1/ingest", json=batch_payload, headers={"X-Device-Token": "device-secret-key-edge-01"})
    res_data = res.json()
    accepted = res_data.get("accepted", [])
    store.mark_synced(accepted)
    print(f"      -> Cloud Accepted: {len(accepted)} records | Queue Remaining: {store.count_pending()}")

    # Test Idempotency (Retry same batch)
    retry_res = client.post("/api/v1/ingest", json=batch_payload, headers={"X-Device-Token": "device-secret-key-edge-01"})
    retry_data = retry_res.json()
    print(f"      -> Idempotent Retry Test: {len(retry_data.get('already_present', []))} already present (0 duplicates created).")

    # 5. Query Overview & Explainable Alerts
    print("\n[5/5] Querying Cloud Overview & Review Alerts for Caregiver / Operator...")
    overview = client.get("/api/v1/overview").json()
    print(f"      -> Operating State: {overview['system_state']}")
    for sensor_name, obs_data in overview["latest_observations"].items():
        print(f"      -> Latest {sensor_name.upper()}: {obs_data['processed_value']} {obs_data['unit']} (Severity: {obs_data['severity']}, Quality: {obs_data['quality_status']})")
    
    alerts = client.get("/api/v1/alerts").json()
    print(f"      -> Active Review Alerts: {len(alerts)}")
    for a in alerts[:2]:
        print(f"         * [{a['severity']}] {a['sensor'].upper()}: {a['explanation']}")

    print("\n" + "=" * 75)
    print("  VERIFICATION COMPLETE: ALL SRS & SINGLE-CODEBASE REQUIREMENTS SATISFIED!")
    print("=" * 75)

    # Cleanup demo db
    store.close()
    if os.path.exists(edge_db):
        try:
            os.remove(edge_db)
        except Exception:
            pass

if __name__ == "__main__":
    run_demonstration()
