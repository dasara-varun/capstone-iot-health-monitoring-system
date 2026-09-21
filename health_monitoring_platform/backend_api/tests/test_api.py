import unittest
from fastapi.testclient import TestClient
from health_monitoring_platform.backend_api.app.main import app
from health_monitoring_platform.backend_api.app.database import Base, engine, SessionLocal
from health_monitoring_platform.backend_api.app.services.auth_service import ensure_default_users

class TestBackendAPI(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        Base.metadata.create_all(bind=engine)
        db = SessionLocal()
        ensure_default_users(db)
        db.close()
        cls.client = TestClient(app)

    def test_01_health_check(self):
        response = self.client.get("/api/v1/health")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["status"], "healthy")
        self.assertEqual(data["database"], "connected")

    def test_02_login_success(self):
        response = self.client.post("/api/v1/auth/login", json={
            "username": "operator",
            "password": "operator123"
        })
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("access_token", data)
        self.assertEqual(data["role"], "operator")

    def test_03_login_failure(self):
        response = self.client.post("/api/v1/auth/login", json={
            "username": "operator",
            "password": "wrongpassword"
        })
        self.assertEqual(response.status_code, 401)

    def test_04_batch_ingest_and_idempotency(self):
        import uuid
        uid = uuid.uuid4().hex[:8]
        event_id_1 = f"test-device-evt-001-{uid}"
        event_id_2 = f"test-device-evt-002-{uid}"
        batch_payload = {
            "schema_version": "1.0",
            "device_id": "test-edge-01",
            "client_batch_id": "batch-test-01",
            "observations": [
                {
                    "event_id": event_id_1,
                    "event_time": "2026-09-21T10:00:00Z",
                    "sensor": "spo2",
                    "raw_value": 97.0,
                    "processed_value": 97.0,
                    "unit": "%",
                    "quality_status": "ACCEPTABLE",
                    "quality_score": 0.95,
                    "baseline": 97.0,
                    "deviation": 0.0,
                    "severity": "NORMAL",
                    "confidence": "HIGH",
                    "reason_codes": [],
                    "explanation": "Processed value is within the current baseline."
                },
                {
                    "event_id": event_id_2,
                    "event_time": "2026-09-21T10:00:01Z",
                    "sensor": "heart_rate",
                    "raw_value": 75.0,
                    "processed_value": 75.0,
                    "unit": "bpm",
                    "quality_status": "ACCEPTABLE",
                    "quality_score": 0.98,
                    "baseline": 74.0,
                    "deviation": 1.0,
                    "severity": "NORMAL",
                    "confidence": "HIGH",
                    "reason_codes": [],
                    "explanation": "Heart rate is normal."
                }
            ]
        }

        # First ingestion -> should be accepted
        res1 = self.client.post("/api/v1/ingest", json=batch_payload)
        self.assertEqual(res1.status_code, 200)
        data1 = res1.json()
        self.assertIn(event_id_1, data1["accepted"])
        self.assertIn(event_id_2, data1["accepted"])
        self.assertEqual(len(data1["already_present"]), 0)

        # Second ingestion of the exact same batch -> should be already_present (idempotent!)
        res2 = self.client.post("/api/v1/ingest", json=batch_payload)
        self.assertEqual(res2.status_code, 200)
        data2 = res2.json()
        self.assertEqual(len(data2["accepted"]), 0)
        self.assertIn(event_id_1, data2["already_present"])
        self.assertIn(event_id_2, data2["already_present"])

    def test_05_overview_and_disclaimer(self):
        response = self.client.get("/api/v1/overview")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("system_state", data)
        self.assertIn("latest_observations", data)
        self.assertIn("disclaimer", data)
        self.assertIn("NON-DIAGNOSTIC", data["disclaimer"])

    def test_06_observations_filtering(self):
        response = self.client.get("/api/v1/observations?sensor=spo2")
        self.assertEqual(response.status_code, 200)
        items = response.json()
        self.assertIsInstance(items, list)
        for item in items:
            self.assertEqual(item["sensor"], "spo2")

    def test_07_inject_fixture_scenario(self):
        # Inject SpO2 drop fixture
        res = self.client.post("/api/v1/tests/fixtures", json={
            "device_id": "test-edge-01",
            "scenario": "spo2_drop",
            "count": 1
        })
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertGreater(len(data["accepted"]), 0)

        # Verify alerts query returns this new review alert
        alerts_res = self.client.get("/api/v1/alerts?severity=REVIEW")
        self.assertEqual(alerts_res.status_code, 200)
        alerts = alerts_res.json()
        self.assertGreater(len(alerts), 0)
        found_drop = any("deviation_from_baseline" in a["reason_codes"] for a in alerts)
        self.assertTrue(found_drop)

if __name__ == "__main__":
    unittest.main()
