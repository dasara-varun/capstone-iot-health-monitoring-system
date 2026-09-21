# Health Monitoring Platform — Complete Software Specification

## 1. Document purpose

This specification defines the software platform to be built for the capstone project **Cloud-Based IoT Health Monitoring System**. The platform shall run through a web browser, as an Android application, and as a desktop application. It shall be able to connect to a Raspberry Pi edge device and health sensors later without requiring a redesign of the user interface, data model, or synchronization rules.

The project’s refined direction is:

> **A secure, offline-resilient, noise-aware, and explainable edge–cloud anomaly-detection framework for low-cost health monitoring.**

The platform is a **monitoring and decision-support prototype**. It is not a certified medical device, does not diagnose disease, does not prescribe treatment, and does not replace professional clinical judgment.

This document is intended to be used as the build specification for the software team. It describes what should be built, how the components should behave, how hardware will be added later, and what evidence must be produced for the capstone review.

## 2. Current project status

The project is not starting from zero. The team has already completed the following design and research work:

- A project direction was developed from a generic cloud-based IoT health-monitoring concept into a local-first edge–cloud system.
- The current design emphasizes sensor-quality handling, local persistence during connectivity loss, explainable decisions, and secure synchronization.
- A formal SRS has been prepared with functional requirements, non-functional requirements, hardware requirements, an API contract, security requirements, acceptance criteria, traceability, and a test matrix.
- An architecture diagram, data-lifecycle diagram, system-state diagram, and processing workflow have been prepared.
- An archived `edge_monitor.py` module demonstrates a hardware-independent core containing samples, decisions, quality checks, local SQLite persistence, pending records, event identifiers, and synchronization interfaces.
- A smoke test was performed on the archived edge core. It demonstrated local pending observations and Python compilation. It did not demonstrate completed physical sensor integration, cloud deployment, dashboard deployment, or measured model accuracy.
- A public MAX30102 and Flask project was identified as the closest health-sensor software base: [shillehbean/max30102-shilleh](https://github.com/shillehbean/max30102-shilleh).
- A public Raspberry Pi Flask dashboard project, [Vishnusimha/pipulse](https://github.com/Vishnusimha/pipulse), provides useful patterns for API routes, dashboard structure, anomaly modules, and systemd deployment, but it monitors Raspberry Pi system health rather than physiological health.

The next step is to turn these design artifacts into one coherent software platform. The team should not copy a public repository unchanged or claim its behavior as the team’s implementation. Public code may be used as an attributed reference or starting point after checking its license.

## 3. Product goals

The platform shall provide one consistent monitoring experience across web, Android, and desktop. It shall show current readings, historical observations, sensor quality, explainable review alerts, device state, and synchronization state.

The Raspberry Pi edge node shall remain useful when the internet is unavailable. It shall collect readings, process them locally, store them durably, and synchronize them when connectivity returns.

The platform shall preserve raw observations and derived decisions separately. It shall never silently replace raw sensor values with filtered values. Every decision shall be traceable to its input, processing version, reason codes, and event identifier.

The platform shall support the current project’s minimum prototype while leaving a clean path for additional temperature sensors, environmental sensors, more than one device, cloud hosting, and future interoperability.

## 4. Product boundary

### Included in the capstone platform

The first complete platform shall support one Raspberry Pi edge device and one monitored subject or test subject at a time. It shall collect MAX30102-class heart-rate and SpO₂ data when the hardware is available. It shall support at least one additional temperature or environmental channel, either from hardware or a deterministic fixture. It shall process observations at the edge, store them in SQLite, synchronize them to a cloud API, and display them in all three client forms.

The platform shall support controlled test data when the physical sensor is unavailable. Fixture data are necessary for reproducible software testing and shall be visibly labelled as simulated or fixture-generated.

### Excluded from the capstone baseline

The baseline shall not include medical diagnosis, treatment recommendations, clinical triage, automatic emergency dispatch, patient identity verification, hospital-record integration, or claims of clinical accuracy. These exclusions shall be visible in the user interface and documentation.

FHIR mapping, multi-tenant production hosting, advanced notifications, predictive disease models, and large-scale device management may be described as future work but shall not be required for Review–2 completion.

## 5. Recommended technology stack

The recommended stack uses one TypeScript client codebase with platform wrappers, a Python backend, and a Python edge service.

| Layer | Technology | Reason |
|---|---|---|
| Web client | React, TypeScript, Vite, responsive CSS | Fast development, reusable components, browser support |
| Android client | Capacitor wrapping the React application | Reuses the web client while producing an Android application |
| Desktop client | Tauri wrapping the same React application | Lightweight desktop packaging and reuse of the client code |
| Client data fetching | TanStack Query or equivalent | Caching, loading states, retry control, and API synchronization |
| Charts | Lightweight chart library | Historical trends and status visualization without large resource cost |
| Backend API | FastAPI, Python, Pydantic | Typed REST contract, validation, automatic OpenAPI documentation |
| Edge service | Python, SQLite, systemd | Matches Raspberry Pi hardware and the archived edge module |
| Cloud database | PostgreSQL | Reliable shared storage, constraints, indexes, and future scaling |
| Local database | SQLite with WAL mode | Durable offline queue on Raspberry Pi |
| Authentication | Short-lived access tokens plus refresh-token rotation | Separate authorized users and devices |
| Device authentication | Per-device credential or certificate | Prevents an unknown device from sending observations |
| Transport | HTTPS/TLS | Protects data in transit |
| Deployment | Docker Compose for development; managed Linux service or container for deployment | Reproducible environments and clear service boundaries |
| Source control | GitHub with branches, issues, pull requests, and attribution records | Teamwork evidence and reproducible history |

This stack is a recommendation, not a requirement to add unnecessary complexity. If the team has limited time, the web client may initially be the only user-facing client, while the Android and desktop packages reuse the same client after the API and responsive UI are stable.

## 6. High-level architecture

The platform shall be divided into five planes.

### 6.1 Sensing plane

The sensing plane contains the MAX30102 heart-rate/SpO₂ sensor and any temperature or environmental sensors. It shall provide a driver-specific adapter rather than exposing I²C details to the rest of the application.

### 6.2 Edge plane

The edge plane runs on the Raspberry Pi. It contains sensor adapters, sample normalization, quality checking, filtering, baseline and rule evaluation, optional machine learning, explanation generation, SQLite persistence, and synchronization.

### 6.3 Cloud plane

The cloud plane contains the authenticated ingestion API, PostgreSQL database, device registry, user access control, query endpoints, and optional notification adapters. The cloud shall accept retries safely through unique event identifiers.

### 6.4 Client plane

The client plane contains the browser, Android, and desktop interfaces. The clients shall not connect directly to the Raspberry Pi database. They shall communicate with the backend API. A local client cache may be used for responsiveness, but it shall not be treated as the authoritative observation store.

### 6.5 Security and evaluation planes

The security plane spans all components. It includes device identity, credential protection, TLS, authorization, audit logging, and retention behavior. The evaluation plane contains deterministic fixtures and tests for noisy data, network outages, duplicate submissions, malformed payloads, authentication failures, and resource use.

## 7. Platform behavior

### 7.1 Normal data path

1. The sensor adapter reads a raw measurement.
2. The edge service creates a normalized sample with a device identifier and event timestamp.
3. The quality gate checks missingness, finiteness, plausibility, and signal stability.
4. The filtering step calculates a processed value without deleting the raw value.
5. The detector computes baseline deviation, rule evidence, and optional model evidence.
6. The explanation generator creates reason codes and a human-readable explanation.
7. The complete observation is committed to SQLite.
8. The synchronization worker sends pending records to the cloud when connectivity is available.
9. The cloud validates and stores the event using `event_id` as a unique key.
10. The clients query the backend and display readings, history, state, and explanations.

### 7.2 Offline behavior

When the edge device cannot reach the cloud, it shall continue local collection and decision processing. It shall mark new records as `PENDING`. The device state shall become `DEGRADED`, and the dashboard shall display the queue depth and last successful synchronization time.

When connectivity returns, the synchronization worker shall send pending records in event-time order. A record shall become `SYNCHRONIZED` only after the cloud returns `accepted` or `already_present`. A timeout, server-unavailable response, or retryable error shall leave the record pending. Authentication and schema errors shall be recorded and shall not trigger unlimited retries.

### 7.3 Safe-stop behavior

The device shall enter `SAFE_STOP` when it cannot trust the sensor, cannot write to storage, or has an unrecoverable configuration error. It shall preserve the error category, disable confident alerts, and present an operator-facing recovery message. It shall not silently continue as if readings were valid.

## 8. Client applications

### 8.1 Shared navigation

All clients shall expose the same logical sections:

- **Overview:** current readings, quality, state, last synchronization, and active review alerts.
- **History:** time-filtered observations and trends.
- **Alerts:** severity, confidence, reason codes, explanation, event time, and acknowledgement state.
- **Devices:** device identity, online/offline state, software version, storage status, and last contact.
- **Tests:** fixture controls and test-result access for authorized project users.
- **Settings:** thresholds, sampling interval, retention configuration, and user profile, subject to authorization.

### 8.2 Overview screen

The overview shall show the latest heart rate, SpO₂, temperature, and any available environmental value. Each value shall include its unit, event time, quality state, and whether it is real sensor data or fixture data.

The overview shall contain a prominent system-state badge with one of `NORMAL`, `DEGRADED`, `RECOVERING`, or `SAFE_STOP`. It shall also show pending queue count, last successful synchronization, and processing version.

### 8.3 Alert screen

An alert is an engineering review event. The alert screen shall show the value, processed value, baseline, deviation, quality status, severity, confidence, reason codes, explanation, and event time. The screen shall not use language such as “disease detected,” “patient is safe,” or “treatment required.”

### 8.4 History screen

The history screen shall support a time range, sensor selection, severity filter, quality filter, and synchronization filter. A chart shall show raw and processed values using distinguishable lines. A table shall provide exact values and event identifiers.

### 8.5 Desktop and Android behavior

The desktop application shall be suitable for a project demonstration on Windows, Linux, or macOS after packaging. The Android application shall support the same API-based behavior and shall display a connection-state message when it cannot reach the backend.

The clients shall not require direct Bluetooth or USB access for the baseline. The Raspberry Pi is the hardware gateway. Direct mobile-to-sensor communication may be future scope.

## 9. Backend service specification

### 9.1 Authentication

The backend shall support at least two roles:

- **Project operator:** may view data, configure a test device, run fixture tests, and review synchronization results.
- **Viewer:** may view observations and alerts but may not change device configuration or run tests.

Device requests shall use device credentials separate from human user credentials. Access tokens shall expire. Passwords shall not be stored in plain text. All authentication failures shall be logged without storing secrets.

### 9.2 Required API routes

| Route | Method | Purpose |
|---|---|---|
| `/api/v1/auth/login` | POST | Authenticate a user |
| `/api/v1/auth/refresh` | POST | Rotate an access token |
| `/api/v1/overview` | GET | Return current values, state, queue, and last sync |
| `/api/v1/observations` | GET | Return paginated observations with filters |
| `/api/v1/alerts` | GET | Return explainable review alerts |
| `/api/v1/devices` | GET | List devices visible to the user |
| `/api/v1/devices/{device_id}` | GET | Return device status and metadata |
| `/api/v1/devices/{device_id}/config` | PATCH | Change authorized device configuration |
| `/api/v1/ingest` | POST | Accept authenticated edge batches |
| `/api/v1/sync/{device_id}/status` | GET | Return last sync and queue state |
| `/api/v1/tests/fixtures` | POST | Submit controlled test samples |
| `/api/v1/health` | GET | Return service health without private data |

### 9.3 Ingestion request

```json
{
  "schema_version": "1.0",
  "device_id": "edge-device-01",
  "client_batch_id": "batch-2026-09-21T10:00:00Z",
  "observations": [
    {
      "event_id": "edge-device-01-20260921T100000Z-a1b2c3d4",
      "event_time": "2026-09-21T10:00:00Z",
      "sensor": "spo2",
      "raw_value": 97.0,
      "processed_value": 97.0,
      "unit": "%",
      "quality_status": "ACCEPTABLE",
      "quality_score": 0.95,
      "baseline": 96.4,
      "deviation": 0.6,
      "severity": "NORMAL",
      "confidence": "HIGH",
      "anomaly_score": 0.0,
      "reason_codes": [],
      "explanation": "Processed value is within the current baseline.",
      "processing_version": "edge-0.1.0"
    }
  ]
}
```

### 9.4 Ingestion response

```json
{
  "accepted": ["edge-device-01-20260921T100000Z-a1b2c3d4"],
  "already_present": [],
  "retryable": [],
  "rejected": [],
  "server_time": "2026-09-21T10:00:01Z"
}
```

The backend shall treat the event identifier as a unique key. It shall return `already_present` when the same valid event is submitted again. This behavior allows the edge device to retry without creating duplicates.

## 10. Data model

### 10.1 Device

Fields shall include `device_id`, display name, hardware model, software version, registration state, last contact time, last successful synchronization time, operating state, and storage status.

### 10.2 Observation

Fields shall include `event_id`, `device_id`, `event_time`, `created_at`, sensor name, raw value, processed value, unit, quality status, quality score, baseline, deviation, severity, confidence, anomaly score, reason codes, explanation, processing version, and synchronization metadata.

### 10.3 Alert

An alert shall reference an observation and contain `alert_id`, severity, confidence, reason codes, explanation, acknowledgement state, created time, and acknowledgement time.

### 10.4 Audit event

An audit event shall contain actor or device identifier, action category, event time, success/failure, and a redacted reason. It shall not contain passwords, tokens, or unnecessary raw health data.

## 11. Edge software specification

### 11.1 Sensor adapter interface

All hardware drivers shall implement an interface equivalent to:

```python
class SensorAdapter:
    def start(self) -> None: ...
    def read(self) -> list[dict]: ...
    def health(self) -> dict: ...
    def stop(self) -> None: ...
```

The MAX30102 adapter may wrap the imported `HeartRateMonitor` and `max30102.py` code from the public reference repository. It shall convert the monitor’s in-memory BPM and SpO₂ values into normalized samples. It shall preserve validity flags and expose sensor errors rather than converting them to zero values without explanation.

### 11.2 Sample model

```python
@dataclass
class Sample:
    event_id: str
    device_id: str
    event_time: datetime
    sensor: str
    value: float | None
    unit: str
    quality_hint: float | None
    source: str
```

### 11.3 Quality gate

The quality gate shall check whether the value exists, is finite, falls within a configured engineering range, and is stable enough for processing. It shall identify at least `MISSING`, `NON_FINITE`, `OUT_OF_RANGE`, `UNSTABLE`, `LOW_SIGNAL`, and `ACCEPTABLE` conditions.

Quality status shall influence confidence. A low-quality measurement shall not become a high-confidence review alert solely because its numeric deviation is large.

### 11.4 Filtering and baseline

The edge service shall use a documented short-window median or equivalent robust filter. The raw value shall remain available for audit. The baseline shall be initialized from a documented calibration or warm-up policy and updated only when the quality is acceptable and the system is not currently treating the sample as a persistent deviation.

### 11.5 Decision and explanation

A decision shall contain severity, confidence, reason codes, baseline, deviation, optional anomaly score, and explanation. The explanation shall be generated from the same decision inputs that produced the severity.

Example reason codes include:

- `missing_value`
- `non_finite_value`
- `out_of_range`
- `low_signal_quality`
- `deviation_from_baseline`
- `rapid_change`
- `persistent_deviation`
- `model_anomaly`
- `network_unavailable`
- `storage_pressure`

### 11.6 Optional model

Isolation Forest may be added after the rules and quality gate are working. It shall use a documented feature order, seed, training trace, contamination policy, and model version. Its output shall be engineering evidence only. The project shall not describe it as a disease classifier.

### 11.7 Local store

SQLite shall run in WAL mode. The store shall insert an observation before synchronization is attempted. The `event_id` shall be unique. A transaction shall update synchronization status only after the corresponding cloud response is understood.

### 11.8 Synchronization worker

The synchronization worker shall use a bounded batch size, exponential backoff, request timeout, and maximum retry interval. It shall distinguish retryable errors from rejected events. It shall expose queue depth and last synchronization result to the dashboard.

## 12. Security requirements

The system shall use HTTPS/TLS between edge, backend, and clients. Each edge device shall have a unique identity and credential. Secrets shall be supplied through environment variables, a protected configuration file, or a secret manager. Secrets shall not be committed to GitHub.

The backend shall validate all request schemas and enforce authorization. It shall reject unknown device identifiers and malformed timestamps. The dashboard shall not expose private data to unauthenticated users.

The camera route from the public reference repository shall be disabled by default. If used for a demonstration, the team shall obtain consent, avoid recording by default, restrict access, and explain why the camera is required. Camera functionality is not part of the minimum health-monitoring platform.

The project shall align its engineering controls with the NIST IoT baseline concepts of device identity, authorized configuration, data protection, and cybersecurity capability.[1]

## 13. Repository and project structure

The team should create a new GitHub repository with this structure:

```text
health-monitoring-platform/
├── apps/
│   ├── client/                    # React web app, Capacitor, Tauri
│   └── api/                       # FastAPI backend
├── edge/
│   ├── sensor/
│   ├── processing/
│   ├── storage/
│   ├── sync/
│   └── service.py
├── packages/
│   ├── api-contracts/
│   └── shared-types/
├── infra/
│   ├── docker-compose.yml
│   └── migrations/
├── tests/
│   ├── integration/
│   └── fixtures/
├── docs/
│   ├── SRS.md
│   ├── architecture.md
│   ├── threat-model.md
│   └── third-party-notices.md
├── diagrams/
├── .env.example
├── README.md
└── LICENSE
```

The public sensor repository shall not be used as the team’s final repository name. The new repository shall include a `THIRD_PARTY_NOTICES.md` file identifying the imported repository, its URL, license, imported files, and modifications.

## 14. Build phases

### Phase 1 — Platform skeleton

Build the FastAPI service, PostgreSQL schema, React client, authentication shell, OpenAPI contract, and Docker Compose development environment. Add a fixture endpoint so that the UI can be demonstrated without hardware.

**Exit condition:** A user can log in, view fixture observations, open history, and see the disclaimer.

### Phase 2 — Edge core

Port or align the archived `edge_monitor.py` behavior with the new shared schema. Add SQLite WAL mode, event identifiers, quality states, filtering, baseline decisions, explanations, and a local status endpoint.

**Exit condition:** The edge fixture generates observations, stores them locally, and exposes pending queue status.

### Phase 3 — Cloud synchronization

Build the authenticated ingestion endpoint, idempotent event handling, acknowledgement response, retry policy, device registry, and synchronization status.

**Exit condition:** A controlled network outage leaves records pending, and a later reconnection synchronizes them without duplicates.

### Phase 4 — Physical sensor integration

Adapt the MAX30102 code from the public reference repository behind the sensor interface. Add hardware configuration, sensor-health reporting, temperature integration if available, and safe shutdown.

**Exit condition:** A real sensor or approved fixture produces normalized observations through the same pipeline.

### Phase 5 — Cross-platform packaging

Make the responsive web application stable. Package the same client with Capacitor for Android and Tauri for desktop. Test login, overview, history, alerts, device state, and offline client behavior on each target.

**Exit condition:** Web, Android, and desktop show the same backend data and handle connection loss clearly.

### Phase 6 — Evaluation and presentation evidence

Run the test matrix. Record actual results, environment, configuration, event identifiers, logs, screenshots, and responsible team member. Update the SRS traceability matrix and present only measured results.

**Exit condition:** Every claimed capability has a reproducible evidence artifact.

## 15. Review–2 minimum demonstration

For the immediate review, the team should demonstrate the following sequence:

1. Open the web client and show the non-diagnostic disclaimer.
2. Submit a deterministic fixture sample.
3. Show raw value, processed value, quality state, baseline, severity, confidence, and explanation.
4. Show that the observation is written to the local SQLite store.
5. Disable network access or simulate a sender timeout.
6. Show the device entering `DEGRADED` and the observation remaining pending.
7. Restore connectivity.
8. Show an accepted or already-present response and the local record becoming synchronized.
9. Submit the same event again and show that no duplicate is created.
10. Explain which pieces are already verified and which pieces remain planned.

If physical hardware is unavailable, use a clearly labelled fixture. Do not claim that fixture results are physical sensor results.

## 16. Acceptance criteria

The complete software platform shall be considered ready for the capstone baseline when all of the following are true:

- The web application, Android application, and desktop application can authenticate and display the same backend data.
- The edge service can produce normalized samples from a fixture and later from the MAX30102 adapter.
- The system retains raw values and produces processed decision records.
- Invalid, missing, unstable, and out-of-range samples are visibly marked.
- Every review alert contains severity, confidence, reason codes, and explanation.
- The edge commits observations locally before network transmission.
- Network outage does not stop local collection or erase observations.
- Reconnection synchronizes pending records without duplicates.
- The backend authenticates devices and validates request schemas.
- The dashboard displays state, queue depth, last synchronization, and disclaimer.
- Tests exist for the quality gate, local store, synchronization, duplicate handling, authentication failure, and UI behavior.
- Public code is attributed and the team’s modifications are visible in Git history.

## 17. Team implementation ownership

| Member | Primary ownership | Review evidence |
|---|---|---|
| Palanati Kushal — 2300031426 | MAX30102 and future sensor adapters, Raspberry Pi setup, device health | Hardware wiring, sensor log, adapter walkthrough |
| Y. Kishan — 2300030979 | Edge quality, filtering, baseline, detector, SQLite store | Unit tests, database query, decision JSON |
| D. Varun — 2300030156 | FastAPI ingestion, authentication, PostgreSQL, sync worker | API contract, acknowledgement test, outage/retry log |
| Dirishala Gopi Krishna — 2300030916 | Client integration, dashboard, documentation, testing, architecture | Screenshots, traceability, test register, presentation |

The team may redistribute tasks, but the final repository and presentation shall identify the actual contribution of each member.

## 18. Risks and mitigations

| Risk | Mitigation |
|---|---|
| MAX30102 values are unstable during movement | Preserve quality status, require stable fixture demonstrations, and avoid clinical claims |
| Raspberry Pi loses power before synchronization | Use SQLite write-before-send and a stable power source during testing |
| Cloud API is unavailable | Continue local operation and show queue state |
| Public repository is outdated or incompatible | Isolate imported code behind adapters and use deterministic fixtures |
| Cross-platform packaging consumes too much time | Stabilize the responsive web client first, then package it with Capacitor and Tauri |
| Team claims unmeasured performance | Use the test register and label unexecuted tests as pending |
| Credentials are exposed in GitHub | Use `.env.example`, protected secrets, and pre-commit checks |
| Camera creates privacy concerns | Disable camera by default and exclude it from the minimum platform |

## 19. Final build instruction

Build the system as a **platform around a stable edge and API contract**, not as a dashboard directly coupled to one sensor script. The public MAX30102 project should supply the hardware-acquisition reference. The archived edge module should supply the local decision and persistence concepts. The new platform should own the data contracts, authentication, synchronization, UI, tests, and documentation.

The correct implementation order is:

> **Contracts → fixture pipeline → edge persistence → cloud ingestion → web client → hardware adapter → Android packaging → desktop packaging → measured evaluation.**

This order allows the team to demonstrate meaningful software behavior before the physical hardware is fully integrated and prevents the UI, cloud, and edge modules from becoming incompatible.

## References

[1]: https://doi.org/10.6028/NIST.IR.8259A "NISTIR 8259A IoT Device Cybersecurity Capability Core Baseline"
[2]: https://github.com/shillehbean/max30102-shilleh "MAX30102 Flask Raspberry Pi health-monitoring reference project"
[3]: https://github.com/Vishnusimha/pipulse "PiPulse Raspberry Pi Flask dashboard and anomaly-detection reference project"
[4]: https://github.com/HassanMahmoodKhan/Remote-Health-Monitoring-With-IoT "Remote Health Monitoring With IoT reference project"
[5]: https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html "scikit-learn IsolationForest API Reference"
[6]: https://hl7.org/fhir/ "HL7 FHIR Specification"
