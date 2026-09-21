# Software Adaptation Blueprint

## Cloud-Based IoT Health Monitoring System

**Review target:** Capstone Project Review–2 — System Design & Partial Implementation  
**Refined project direction:** Secure, Offline-Resilient, Noise-Aware and Explainable Edge–Cloud Anomaly Detection Framework  
**Guide:** Vijay Raja, Assistant Professor, EmpID 9523  
**Team:** Palanati Kushal (2300031426), Y. Kishan (2300030979), D. Varun (2300030156), Dirishala Gopi Krishna (2300030916)

> This document is an engineering adaptation plan. It does not claim that the public repository already satisfies the project requirements. The team must reproduce, modify, test, and attribute any reused code.

## 1. Recommended public software base

### Primary repository

**[shillehbean/max30102-shilleh](https://github.com/shillehbean/max30102-shilleh)**

This is the nearest single public software project to the team’s target because it already combines the relevant physiological sensor and web stack. Its repository contains a MAX30102 driver, a threaded `HeartRateMonitor`, heart-rate/SpO₂ calculation code, a Flask application, a `/biometric_data` JSON route, a browser page, and optional Raspberry Pi camera streaming. The repository README describes real-time heart-rate and SpO₂ display from a Raspberry Pi using Flask and Picamera2.

The repository file tree includes `max30102.py`, `hrcalc.py`, `heartrate_monitor.py`, `main.py`, `flask_app_camera_and_sensor.py`, and a five-second Flask variant. The current application is a live demonstration: it starts the sensor thread, reads the current BPM/SpO₂ values, and returns them from Flask. It does **not** provide the project’s required durable local queue, quality-aware decision record, event IDs, cloud ingestion contract, idempotent synchronization, authentication, audit trail, or formal evaluation harness.

### Secondary architecture reference

**[Vishnusimha/pipulse](https://github.com/Vishnusimha/pipulse)**

PiPulse is not a health-sensor project, so it should not be used as the primary base. Its software structure is useful: Flask routes, a JSON API, a separated anomaly module, dashboard assets, a requirements file, and a systemd service. Its README states that it provides a Raspberry Pi dashboard, baseline rule-based anomaly checks, live charts, and systemd auto-start. The team can use this organization pattern while retaining the health-sensor code from the primary repository.

### Optional communication reference

**[HassanMahmoodKhan/Remote-Health-Monitoring-With-IoT](https://github.com/HassanMahmoodKhan/Remote-Health-Monitoring-With-IoT)** is a useful reference for Raspberry Pi publisher, MQTT broker/subscriber, gateway processing, machine learning, and cloud storage. It is not the preferred base because its README describes CSV-based subscriber processing and logistic regression rather than your local-first SQLite and explainable decision path.

## 2. Current behavior of the primary base

The public application currently behaves approximately as follows:

1. `MAX30102()` opens the I²C device at address `0x57`, resets it, configures FIFO and SpO₂ mode, and reads red/infrared samples.
2. `HeartRateMonitor.run_sensor()` runs in a thread, collects samples, calls the calculation routine, and stores rolling mean BPM and SpO₂ values in memory.
3. `flask_app_camera_and_sensor.py` starts the camera and sensor thread when the process starts.
4. `/` returns an embedded HTML page.
5. `/biometric_data` returns only the current in-memory `heart_rate` and `spo2` values.
6. `/video_feed` streams MJPEG camera frames.
7. There is no database write, event ID, network-outage queue, cloud sync worker, device authentication, or structured explanation record.

The first adaptation rule is therefore: **retain the hardware driver and sensor thread, but replace the direct in-memory-to-browser path with a sample-normalization, quality, decision, persistence, and synchronization pipeline.**

## 3. Target software architecture

```text
MAX30102 / temperature sensor
            |
            v
      Sensor adapters
            |
            v
  Sample normalizer + event ID
            |
            v
 Quality gate + median filter
            |
            v
 Baseline/rule detector
            |
            +--> optional Isolation Forest
            |
            v
 Explainable Decision record
            |
            v
 SQLite local store (write first)
            |
      +-----+------+
      |            |
 network down   network up
      |            |
 PENDING_SYNC    HTTPS authenticated batch
      |            |
 DEGRADED        cloud ingestion API
                   |
              accepted/already-present
                   |
              SYNCHRONIZED
```

The edge is authoritative for the first durable copy. The cloud is the synchronized shared copy. Both copies are linked by `event_id`, not by arrival order.

## 4. Required repository restructuring

Create a new working repository rather than modifying the public repository in place. Preserve the original repository URL in `THIRD_PARTY_NOTICES.md`, check its license, and keep a commit history that distinguishes imported code from team-authored code.

Recommended structure:

```text
project-root/
├── app.py                         # Flask dashboard and API routes
├── config.py                      # environment-backed configuration
├── requirements.txt
├── sensor/
│   ├── max30102_adapter.py        # wraps imported driver/HeartRateMonitor
│   ├── temperature_adapter.py
│   └── fixture.py                 # deterministic test samples
├── edge/
│   ├── models.py                  # Sample and Decision dataclasses
│   ├── quality.py                 # validity and signal-quality checks
│   ├── filtering.py               # median/moving-window processing
│   ├── detector.py                # baseline and rule evidence
│   ├── optional_model.py          # Isolation Forest, if enabled
│   ├── store.py                   # SQLite schema and transactions
│   ├── sync.py                    # batch sender and retry policy
│   └── service.py                 # sampling loop and state machine
├── cloud/
│   ├── api.py                     # authenticated ingestion endpoint
│   └── schema.py                  # request/response validation
├── templates/
│   └── dashboard.html
├── static/
│   ├── app.js
│   └── style.css
├── tests/
│   ├── test_quality.py
│   ├── test_store.py
│   ├── test_sync.py
│   ├── test_explanation.py
│   └── fixtures/
├── deployment/
│   └── health-monitor.service
├── diagrams/
├── THIRD_PARTY_NOTICES.md
└── README.md
```

## 5. File-by-file change plan

| Public base file | Keep/change | Required adaptation |
|---|---|---|
| `max30102.py` | Keep with audit | Verify Python 3 behavior, I²C address, error handling, and license. Add explicit sensor exception types. |
| `hrcalc.py` | Keep with validation | Preserve calculation, record validity flags, and never treat zero as a confirmed physiological result. |
| `heartrate_monitor.py` | Refactor into adapter | Return timestamped normalized samples rather than only mutable `bpm`/`spo2` fields. Add stop/error state and quality hints. |
| `main.py` | Replace | Start the edge service, not only a timed print loop. Load configuration and start the sync worker. |
| `flask_app_camera_and_sensor.py` | Split into `app.py` and service | Remove long-lived initialization from import time. Use a service lifecycle, API routes, dashboard, and optional camera route. |
| embedded HTML | Replace with template | Display current value, quality, severity, explanation, queue depth, operating state, and disclaimer. |
| direct `/biometric_data` | Preserve as compatibility route | Return a versioned observation/decision response, not only two raw fields. |
| no storage | Add `edge/store.py` | Add SQLite WAL, schema, transactions, unique `event_id`, pending query, sync status, and audit events. |
| no anomaly module | Add `edge/detector.py` | Implement quality gate, median filter, baseline/rules, persistence, and reason codes. |
| no deployment file | Add systemd unit | Start the edge service after network target, use a protected environment file, and log safely. |

## 6. Data contracts

### Normalized sample

```json
{
  "sensor": "spo2",
  "value": 97.0,
  "unit": "%",
  "event_time": "2026-09-21T10:00:00Z",
  "quality_hint": 0.95,
  "source": "max30102"
}
```

### Decision record

```json
{
  "quality_status": "ACCEPTABLE",
  "quality_score": 0.95,
  "processed_value": 97.0,
  "baseline": 96.4,
  "deviation": 0.6,
  "severity": "NORMAL",
  "confidence": "HIGH",
  "anomaly_score": 0.0,
  "reason_codes": [],
  "explanation": "Processed value is within the current baseline."
}
```

### Cloud batch response

```json
{
  "accepted": ["event-001"],
  "already_present": [],
  "retryable": [],
  "rejected": [],
  "server_time": "2026-09-21T10:00:01Z"
}
```

## 7. Database design

Use SQLite on the Raspberry Pi with WAL mode. The minimum schema is:

```sql
CREATE TABLE observations (
    event_id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    event_time TEXT NOT NULL,
    created_at TEXT NOT NULL,
    sensor TEXT NOT NULL,
    raw_value REAL,
    processed_value REAL,
    unit TEXT NOT NULL,
    quality_status TEXT NOT NULL,
    quality_score REAL NOT NULL,
    baseline REAL,
    deviation REAL,
    severity TEXT NOT NULL,
    confidence TEXT NOT NULL,
    anomaly_score REAL,
    reason_codes TEXT NOT NULL,
    explanation TEXT NOT NULL,
    sync_status TEXT NOT NULL DEFAULT 'PENDING'
);

CREATE TABLE sync_attempts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    attempted_at TEXT NOT NULL,
    batch_size INTEGER NOT NULL,
    result TEXT NOT NULL,
    error_category TEXT
);
```

The existing archived `edge_monitor.py` already demonstrates much of this local path. The team should align its field names and module boundaries with this blueprint instead of maintaining two incompatible schemas.

## 8. Decision behavior

The adapted system must distinguish **severity** from **confidence**. For example, an extreme value with poor signal quality can be `severity=OBSERVE` and `confidence=LOW`, with the explanation “Repeat measurement requested because signal quality is low.” A persistent, acceptable-quality deviation may become `severity=REVIEW` with `confidence=HIGH`. Neither state is a medical diagnosis.

Recommended order:

1. Reject missing/non-finite values.
2. Check configured engineering plausibility ranges.
3. Apply a short median filter while retaining raw values.
4. Calculate baseline deviation and persistence.
5. Mark poor signal quality and reduce confidence.
6. Apply rule evidence.
7. Apply Isolation Forest only when trained on a documented normal calibration trace.
8. Generate reason codes and explanation.
9. Write locally before any network request.

## 9. API routes

| Route | Method | Purpose |
|---|---|---|
| `/` | GET | Dashboard with current observation, explanation, state, queue depth, and disclaimer |
| `/api/v1/current` | GET | Latest decision record |
| `/api/v1/observations` | GET | Paginated local/cloud history |
| `/api/v1/alerts` | GET | Explainable alerts and status |
| `/api/v1/status` | GET | Device state, queue depth, last sync, and sensor health |
| `/api/v1/ingest` | POST | Authenticated cloud ingestion endpoint |
| `/api/v1/health` | GET | Service health without secrets or unnecessary patient data |
| `/video_feed` | GET | Optional camera stream; disable unless it is required and consented |

The original `/biometric_data` route may remain temporarily as a compatibility alias, but the new route should return a versioned structured record and should not expose credentials or raw private data unnecessarily.

## 10. Security changes

- Assign a unique `device_id` to the Raspberry Pi.
- Load API credentials from environment variables or a protected systemd environment file.
- Use HTTPS/TLS for cloud transfer.
- Require device authentication at `/api/v1/ingest`.
- Validate schema, timestamps, batch size, and event-ID uniqueness.
- Redact tokens, raw health values, and personal identifiers from logs.
- Avoid enabling the camera in demonstrations unless it is necessary, consented, and protected.
- Restrict dashboard access to the local network or add authentication before exposing it beyond the LAN.
- Record security failures as audit categories, not as raw secrets.
- Document retention and storage-pressure behavior.

These controls match the project’s use of NIST IoT cybersecurity concepts: device identification, authorized configuration, and data protection.[1]

## 11. Optional Isolation Forest integration

The project’s optional model should not replace the transparent decision engine. Train it only on a labelled-as-normal calibration trace and record `n_estimators`, `max_samples`, `contamination`, feature order, random seed, model version, and training trace ID. The quality gate runs first; `INVALID` data cannot be promoted to a confident anomaly by the model. The model contributes evidence to an explanation, not a disease probability.[2]

A minimal feature vector can contain:

```text
filtered_value,
rolling_median,
rolling_std,
first_difference,
baseline_deviation,
quality_score,
missingness_count,
persistence_count
```

## 12. Dashboard behavior

The dashboard should show one current observation area, one alert explanation area, one system-state indicator, one synchronization area, and a history table. At minimum it should expose:

- sensor name, value, unit, event time, and quality status;
- processed value, baseline, deviation, severity, confidence, and reason codes;
- `NORMAL`, `DEGRADED`, `RECOVERING`, or `SAFE-STOP` state;
- pending queue count and last successful synchronization;
- a visible statement: “Monitoring and decision support only; not a medical diagnosis.”

Do not present raw threshold crossings as “disease detected.” Use “review,” “observe,” or “repeat measurement requested.”

## 13. Test plan for the adapted software

| Test | Input | Expected result | Review–2 evidence |
|---|---|---|---|
| Sensor adapter | Real MAX30102 or deterministic fixture | Normalized sample with timestamp and unit | Console/log capture |
| Missing value | `None`/non-finite | `INVALID`, no confident alert | Unit-test output |
| Isolated spike | One injected extreme sample | Filter/quality reason recorded | Before/after trace |
| Low-quality signal | Low quality hint or unstable window | Confidence reduced and repeat requested | Decision JSON |
| Baseline shift | Persistent acceptable-quality deviation | Rule reason and review severity | Event sequence |
| Local commit | Sender timeout after sample | Observation remains locally pending | SQLite query |
| Network outage | Sender unavailable | `DEGRADED`, collection continues | Queue-depth log |
| Reconnection | Sender returns accepted IDs | Pending rows become synchronized | Sync log |
| Duplicate retry | Same event submitted twice | One cloud row; second is already-present | Cloud response |
| Auth failure | Invalid credential | Local record retained; no unbounded retry | Audit record |
| Dashboard | Current/alert/status queries | Values, explanation, state, queue visible | Screenshot |
| Resource run | Fixed sampling interval | CPU, memory, latency, bytes recorded | Metrics file |

Do not fill accuracy, latency, data-loss, or recovery numbers until these runs are actually performed.

## 14. Team software ownership

| Member | Software ownership | Deliverable |
|---|---|---|
| Palanati Kushal | `sensor/` | MAX30102 adapter, fixture, sensor error handling, deployment wiring |
| Y. Kishan | `edge/quality.py`, `filtering.py`, `detector.py`, `store.py` | Decision and local persistence path |
| D. Varun | `cloud/api.py`, `sync.py`, `config.py` | API, authentication, retries, acknowledgements |
| Dirishala Gopi Krishna | `app.py`, dashboard, tests, diagrams, traceability | Integration, evidence, documentation, Review–2 coordination |

## 15. Implementation sequence

### Sprint A — Reproduce and separate

Clone the public repository into a new team repository, verify the license, run the sensor-only and Flask paths, and separate hardware initialization from web imports. Replace embedded HTML with templates and add a configuration file.

### Sprint B — Add local-first edge processing

Wrap the sensor thread with a normalized sample adapter. Add event IDs, quality status, median processing, baseline/rule decisions, explanation fields, and SQLite WAL persistence. Demonstrate the local path with a deterministic fixture if hardware is unavailable.

### Sprint C — Add synchronization and API

Implement a versioned authenticated ingestion endpoint, structured per-event acknowledgement, pending queue selection, bounded retry, duplicate-safe event IDs, and explicit operating states.

### Sprint D — Add dashboard and evaluation

Display current observations, reasons, queue depth, and state. Run the test matrix, record configuration and trace identifiers, capture individual evidence, and report measured results only.

## 16. Attribution and academic-integrity rules

Do not submit the public repository as your own work. Keep the repository URL, author names, license, imported files, and modification history in `THIRD_PARTY_NOTICES.md`. Add a “software provenance” slide to the final project presentation. Team-authored changes should be visible through commits, issue tracking, and a contribution table. Do not copy screenshots or claim the public repository’s behavior as your measured result.

## 17. Related software deliverables already prepared

Use this blueprint together with the existing package:

- **[Review–2 Master Pack](/home/ubuntu/work/capstone_review/Review_2_Master_Pack.md):** project evolution, rubric mapping, member IDs, guide, public repository recommendation, and implementation boundary.
- **[SRS](/home/ubuntu/work/capstone_review/SRS_Cloud_IoT_Health_Monitoring_System.md):** requirements, hardware, API contract, state model, security, algorithm, acceptance criteria, traceability, and test matrix.
- **[Individual Contribution and Test Sheet](/home/ubuntu/work/capstone_review/Individual_Contributions_and_Test_Sheet.md):** member-level ownership, viva prompts, and honest test-status register.
- **[Edge-core smoke evidence](/home/ubuntu/work/capstone_review/edge_smoke_output.txt):** verified execution output from the archived `edge_monitor.py` module.
- **[Review–2 presentation PDF](/home/ubuntu/Capstone_Project_Review–2_—_Cloud-Based_IoT_Health_Monitoring_System.pdf):** presentation covering the Review–2 rubric.

## References

[1]: https://doi.org/10.6028/NIST.IR.8259A "NISTIR 8259A IoT Device Cybersecurity Capability Core Baseline"
[2]: https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html "scikit-learn IsolationForest API Reference"
[3]: https://github.com/shillehbean/max30102-shilleh "MAX30102 Flask Raspberry Pi health-monitoring repository"
[4]: https://github.com/Vishnusimha/pipulse "PiPulse Raspberry Pi Flask dashboard and anomaly-detection repository"
[5]: https://github.com/HassanMahmoodKhan/Remote-Health-Monitoring-With-IoT "Remote Health Monitoring With IoT repository"
