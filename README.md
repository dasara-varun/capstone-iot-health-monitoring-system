# Cloud-Based IoT Health Monitoring System

A secure, offline-resilient, noise-aware, and explainable edge-to-cloud anomaly detection framework for continuous health monitoring using IoT sensors.

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FLUTTER CROSS-PLATFORM CLIENT                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Flutter    │  │   Flutter    │  │   Flutter    │  │   Shared     │    │
│  │    Web       │  │   Windows    │  │   Android    │  │   Models     │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
└─────────┼─────────────────┼─────────────────┼─────────────────┼────────────┘
          │                 │                 │                 │
          └─────────────────┴────────┬────────┴─────────────────┘
                                     │ HTTPS / REST JSON
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FASTAPI CLOUD BACKEND                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │  Auth (JWT)  │  │  Ingestion   │  │   Queries    │  │  Alerts API  │    │
│  │   Service    │  │   Service    │  │   Service    │  │              │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
└─────────┼─────────────────┼─────────────────┼─────────────────┼────────────┘
          │                 │                 │                 │
          └─────────────────┴────────┬────────┴─────────────────┘
                                     │
                                     ▼
                        ┌──────────────────────┐
                        │  Cloud SQLite /      │
                        │  PostgreSQL Database │
                        └──────────┬───────────┘
                                   │
                        Authenticated Batch Sync (JSON)
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        PYTHON EDGE SERVICE (Raspberry Pi)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Sensor     │  │   Quality    │  │   Anomaly    │  │   Local      │    │
│  │   Adapters   │  │   Gate       │  │   Detector   │  │   SQLite     │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
└─────────┼─────────────────┼─────────────────┼─────────────────┼────────────┘
          │                 │                 │                 │
          └─────────────────┴────────┬────────┴─────────────────┘
                                     │
                                     ▼
                        ┌──────────────────────┐
                        │  MAX30102 Pulse      │
                        │  Oximeter & Temp     │
                        │  Sensors (I2C)       │
                        └──────────────────────┘
```

## ✨ Key Features

### 🔒 **Write-First Local Durability**
Every sensor sample is evaluated, assigned a unique `event_id`, and committed to a local SQLite database in WAL mode before network transmission. No data is lost during connectivity outages.

### 📊 **Noise Awareness & Quality Gating**
Readings with missing values, out-of-range bounds (SpO₂ < 50% or > 100%), or high short-window instability are classified as `INVALID` or `LOW` quality and filtered out, preventing false alarms.

### ♻️ **Idempotent Cloud Ingestion**
Cloud ingestion contract checks `event_id` uniqueness and returns `accepted`, `already_present`, `retryable`, and `rejected` sets, preventing duplicate rows during retry reconciliation.

### 🎯 **Explainable Anomaly Alerts**
Alerts provide explicit reason codes (`deviation_from_baseline`, `short_window_instability`), baseline comparison, deviation values, and natural language explanations.

### ⚠️ **Non-Diagnostic Prototype**
All user interfaces and APIs explicitly display the required non-diagnostic research disclaimer.

### 🔐 **Secure Authentication**
JWT-based authentication with token refresh, role-based access control, and secure credential storage.

## 📁 Project Structure

```
iot-health-monitoring/
├── README.md                          # This file
├── health_monitoring_platform/        # Main application code
│   ├── backend_api/                   # FastAPI cloud backend
│   │   ├── app/
│   │   │   ├── api/                   # REST endpoints
│   │   │   ├── models/                # DB models & Pydantic schemas
│   │   │   ├── services/              # Business logic
│   │   │   ├── config.py              # Configuration
│   │   │   ├── database.py            # Database setup
│   │   │   └── main.py                # FastAPI app entry
│   │   ├── requirements.txt
│   │   └── tests/
│   ├── edge_service/                  # Raspberry Pi edge service
│   │   ├── edge/
│   │   │   ├── detector.py            # Anomaly detection
│   │   │   ├── filtering.py           # Median filter
│   │   │   ├── quality.py             # Quality gate
│   │   │   ├── service.py             # Edge service orchestrator
│   │   │   ├── store.py               # SQLite WAL store
│   │   │   └── sync.py                # Cloud synchronization
│   │   ├── sensors/
│   │   │   ├── base.py                # Sensor interface
│   │   │   ├── fixture.py             # Test fixtures
│   │   │   ├── max30102_adapter.py    # MAX30102 driver
│   │   │   └── temperature_adapter.py # Temperature sensor
│   │   ├── requirements.txt
│   │   ├── main.py                    # Edge service entry
│   │   └── tests/
│   └── flutter_app/                   # Cross-platform Flutter client
│       ├── lib/
│       │   ├── core/                  # Theme, config, widgets
│       │   ├── features/              # Feature modules
│       │   ├── models/                # Data models
│       │   ├── services/              # API client
│       │   └── state/                 # App state management
│       ├── pubspec.yaml
│       └── test/
├── architecture/                      # Architecture documentation
│   ├── architecture/                  # Documentation files
│   │   ├── diagrams/                  # System diagrams
│   │   ├── *.md                       # Technical specifications
├── info/                              # Review & submission documents
└── health_cloud.db                    # Local database (dev)
```

## 🚀 Quick Start

### Prerequisites
- Python 3.10+
- Flutter 3.16+
- Raspberry Pi 4 (for edge service with hardware sensors)
- SQLite / PostgreSQL

### 1. Cloud Backend
```bash
cd health_monitoring_platform/backend_api

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run server
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
API docs: `http://localhost:8000/docs`

### 2. Edge Service (Raspberry Pi)
```bash
cd health_monitoring_platform/edge_service

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run with hardware sensors
python -m main --interval 2.0

# Run offline mode (local storage only)
python -m main --offline

# Run with test fixture
python -m main --fixture spo2_drop
```

### 3. Flutter App (Web/Desktop/Mobile)
```bash
cd health_monitoring_platform/flutter_app

# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on Windows
flutter run -d windows

# Run on Android (device/emulator)
flutter run -d android
```

## 🧪 Running Tests

```bash
# Backend API tests
cd health_monitoring_platform/backend_api
python -m unittest discover -s tests -t .

# Edge service tests
cd health_monitoring_platform/edge_service
python -m unittest discover -s tests -t .

# Flutter tests
cd health_monitoring_platform/flutter_app
flutter test
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [Architecture Specification](architecture/architecture/Health_Monitoring_Platform_Specification.md) | Complete system specification |
| [SRS Document](architecture/architecture/SRS_Cloud_IoT_Health_Monitoring_System.md) | Software Requirements Specification |
| [Single Codebase Amendment](architecture/architecture/Single_Codebase_Architecture_Amendment.md) | Cross-platform architecture details |
| [Software Adaptation Blueprint](architecture/architecture/Software_Adaptation_Blueprint.md) | Adaptation patterns |
| [System Diagrams](architecture/architecture/diagrams/) | Architecture, data flow, processing workflow |
| [Review 2 Master Pack](info/Review_2_Submission_Package/Review_2_Master_Pack.md) | Review submission summary |
| [Individual Contributions](info/Review_2_Submission_Package/Individual_Contributions_and_Test_Sheet.md) | Team contributions & test log |
| [Review Presentation (PDF)](info/Review_2_Submission_Package/Capstone_Project_Review-2_-_Cloud-Based_IoT_Health_Monitoring_System.pdf) | Project presentation slides |
| [Review Presentation (PPTX)](info/Review_2_Submission_Package/Capstone_Project_Review-2_-_Cloud-Based_IoT_Health_Monitoring_System.pptx) | Editable presentation file |

## 🔧 Configuration

### Environment Variables

**Backend API** (`.env`):
```env
DATABASE_URL=sqlite:///./health_cloud.db
SECRET_KEY=your-secret-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

**Edge Service** (`config.py`):
```python
CLOUD_API_URL = "http://localhost:8000"
SYNC_INTERVAL_SECONDS = 30
LOCAL_DB_PATH = "edge_data.db"
```

## 📦 Deployment

### Docker (Backend)
```bash
cd health_monitoring_platform/backend_api
docker build -t health-monitor-backend .
docker run -p 8000:8000 health-monitor-backend
```

### Flutter Web Build
```bash
cd health_monitoring_platform/flutter_app
flutter build web --release
# Deploy build/web/ to any static hosting
```

## 👥 Team

| Member | Role | Contributions |
|--------|------|---------------|
| Palanati Kushal (2300031426) | Edge Hardware | MAX30102 adapter, sensor integration |
| Y. Kishan (2300030979) | Edge Processing | Quality gate, median filter, SQLite store |
| D. Varun (2300030156) | Cloud Backend | FastAPI, auth, idempotent ingestion |
| Dirishala Gopi Krishna (2300030916) | Flutter Client | Cross-platform app, integration |

**Guide:** Vijay Raja, Assistant Professor (EmpID: 9523)

## 📄 License

This is a capstone project for academic purposes (Course: 23IE4053A). Non-diagnostic prototype - not for clinical use.

## ⚠️ Disclaimer

**This system is a research prototype for educational purposes only. It is not a medical device and must not be used for clinical diagnosis or treatment decisions. Always consult qualified healthcare professionals for medical concerns.**