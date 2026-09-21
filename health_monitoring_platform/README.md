# Cloud-Based IoT Health Monitoring Platform

**Direction:** Secure, Offline-Resilient, Noise-Aware, and Explainable Edge–Cloud Anomaly Detection Framework  
**Course / Code:** 23IE4053A / Capstone Project 4 (Review–2 Submission)  
**Guide:** Vijay Raja, Assistant Professor, EmpID: 9523  
**Team:**
- Palanati Kushal (2300031426) — Edge Sensor Hardware & MAX30102 Adapter
- Y. Kishan (2300030979) — Edge Processing, Quality Gate, Median Filter & SQLite LocalStore
- D. Varun (2300030156) — FastAPI Cloud Backend, Authentication & Idempotent Ingestion
- Dirishala Gopi Krishna (2300030916) — Single-Codebase Flutter Cross-Platform Client & Integration

---

## 1. System Architecture

```text
               One Flutter Codebase (Web / Windows / Android)
        ┌─────────────────────┬─────────────────────┬─────────────────────┐
        │                     │                     │                     │
    Flutter Web         Flutter Windows       Flutter Android       Shared Models
        │                     │                     │                     │
        └─────────────────────┴──────────┬──────────┴─────────────────────┘
                                         │ HTTPS / REST JSON
                                         ▼
                              FastAPI Cloud Backend
                                         │
                             Cloud SQLite / PostgreSQL
                                         ▲
                                         │ Authenticated Batch Sync (JSON)
                         Python Raspberry Pi Edge Service
                                         │
                             SQLite WAL Local-First Store
                                         ▲
                                         │ Driver / Adapter Pipeline
                         MAX30102 Pulse Oximeter & Temp Sensors
```

---

## 2. Key Engineering Properties

1. **Write-First Local Durability**:
   Every sensor sample is evaluated, assigned a unique `event_id`, and committed to a local SQLite database in WAL mode before network transmission is attempted. No data is lost during connectivity outages.
2. **Noise Awareness & Quality Gating**:
   Readings with missing values, out-of-range bounds (e.g. SpO₂ < 50% or > 100%), or high short-window instability are classified as `INVALID` or `LOW` quality and filtered out, preventing false alarms.
3. **Idempotent Cloud Ingestion**:
   The cloud ingestion contract checks `event_id` uniqueness and returns `accepted`, `already_present`, `retryable`, and `rejected` sets, preventing duplicate rows during retry reconciliation.
4. **Explainable Anomaly Alerts**:
   Alerts provide explicit reason codes (`deviation_from_baseline`, `short_window_instability`), baseline comparison, deviation, and natural language explanations.
5. **Non-Diagnostic Prototype**:
   All user interfaces and APIs explicitly display the required non-diagnostic research disclaimer.

---

## 3. Directory Structure

- **`backend_api/`**: FastAPI REST service with JWT authentication, idempotent batch ingestion, query endpoints, and test fixtures.
- **`edge_service/`**: Raspberry Pi Python service with sensor adapters, quality gate, median filter, baseline deviation detector, SQLite store, and synchronizer.
- **`flutter_app/`**: Single Flutter codebase supporting Web (Chrome), Windows Desktop, and Android.

---

## 4. Running the System

### A. Run Cloud Backend
```bash
cd backend_api
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```
Interactive OpenAPI documentation is available at `http://127.0.0.1:8000/docs`.

### B. Run Edge Daemon
```bash
cd edge_service
python -m main --interval 2.0
```
To run offline accumulation mode:
```bash
python -m main --offline
```
To run with a specific fixture scenario:
```bash
python -m main --fixture spo2_drop
```

### C. Run Flutter App
```bash
cd flutter_app
# Run on Chrome Web:
flutter run -d chrome

# Run on Windows Desktop:
flutter run -d windows
```

---

## 5. Automated Tests

- **Backend API Tests**: `python -m unittest discover -s backend_api/tests -t .`
- **Edge Service Tests**: `python -m unittest discover -s edge_service/tests -t .`
- **Flutter Widget Tests**: `cd flutter_app && flutter test`
