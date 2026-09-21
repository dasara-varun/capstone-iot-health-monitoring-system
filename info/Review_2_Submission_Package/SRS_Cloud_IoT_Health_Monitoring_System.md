# Software Requirements Specification (SRS)

## 1. Document control

**System:** Cloud-Based IoT Health Monitoring System  
**Refined direction:** Secure, Offline-Resilient, Noise-Aware and Explainable Edge–Cloud Anomaly Detection Framework  
**Project code:** 23IE4053A / Capstone Project 4  
**Version:** Review–2 baseline, September 2026  
**Team:** Palanati Kushal (2300031426), Y. Kishan (2300030979), D. Varun (2300030156), Dirishala Gopi Krishna (2300030916)  
**Guide:** Vijay Raja, Assistant Professor, EmpID 9523

## 2. Purpose and scope

This SRS defines a capstone-scale system that collects selected physiological and environmental observations at a Raspberry Pi edge node, performs quality-aware local processing, stores evidence during connectivity loss, and synchronizes records to an authenticated cloud service for history and caregiver-facing visualization. The system is a monitoring and decision-support prototype. It is not a clinical diagnostic device and shall not prescribe treatment or replace professional interpretation.

The minimum scope is one edge gateway, one monitored subject or test subject at a time, one physiological sensor such as a MAX30102-class heart-rate/SpO₂ sensor, one temperature sensor, local SQLite persistence, a quality-aware decision path, and a documented cloud ingestion contract. Dashboard, notifications, multi-device operation, FHIR exchange, and advanced models are extension scope.

## 3. Stakeholders and user needs

| Stakeholder | Need |
|---|---|
| Project team | A reproducible, testable artifact that can be demonstrated within capstone constraints |
| Guide and review panel | Traceable requirements, justified architecture, evidence of partial implementation, and clear limitations |
| Caregiver demonstrator | Understandable trends, alert severity, confidence, quality status, and synchronization state |
| Device operator | Safe configuration, visible device state, and recovery instructions |
| Future researcher | Stable event IDs, provenance, modular interfaces, and reproducible test artifacts |
| Monitored person | Protection of data and a clear statement that outputs are not diagnoses |

## 4. System context

The sensing plane produces normalized samples. The edge plane validates and filters samples, computes baseline/rule evidence, optionally applies Isolation Forest, creates an explanation, and writes the observation locally. The cloud plane receives authenticated batches, stores unique event IDs, and exposes history/status. The security plane spans the whole system. The evaluation plane injects controlled noise, network outages, retries, malformed payloads, and resource measurements.

## 5. Functional requirements

| ID | Requirement | Priority | Verification |
|---|---|---:|---|
| FR-01 | The collector shall read supported sensor channels at a configurable interval. | Must | Test T-01 |
| FR-02 | The collector shall assign a stable event ID and capture device ID and event time before transmission. | Must | T-02 |
| FR-03 | Each accepted observation shall include sensor type, value, unit, quality status, quality score, processing version, and synchronization status. | Must | T-03 |
| FR-04 | Missing, non-finite, stale, or out-of-range samples shall be marked invalid or low quality and shall not become high-confidence alerts. | Must | T-04 |
| FR-05 | The edge shall calculate a processed value using a documented short-window filter without overwriting the raw value. | Must | T-05 |
| FR-06 | The edge shall calculate baseline deviation and configurable rule evidence. | Must | T-06 |
| FR-07 | The optional model layer shall use compact features and shall not override an invalid quality status. | Should | T-07 |
| FR-08 | A decision record shall include severity, confidence, reason codes, and an explanation generated from the decision path. | Must | T-08 |
| FR-09 | The observation shall be committed to SQLite before synchronization is attempted. | Must | T-09 |
| FR-10 | The edge shall continue local collection when the network is unavailable. | Must | T-10 |
| FR-11 | The synchronizer shall send pending records in event-time order and retain original event timestamps. | Must | T-11 |
| FR-12 | The cloud shall treat event ID as a unique key and return accepted, already-present, retryable, or rejected IDs. | Must | T-12 |
| FR-13 | The edge shall mark only accepted or already-present records as synchronized. | Must | T-13 |
| FR-14 | Authentication, schema, timeout, and unexpected failures shall be categorized and audited without leaking secrets. | Must | T-14 |
| FR-15 | A dashboard or query endpoint shall expose observations, alerts, queue depth, operating state, and synchronization history. | Should | T-15 |
| FR-16 | The system shall display a non-diagnostic monitoring disclaimer. | Must | Inspection |

## 6. Non-functional requirements

| ID | Requirement | Acceptance indication |
|---|---|---|
| NFR-01 | Resource feasibility | Edge path runs on Raspberry Pi-class hardware without a high-end GPU |
| NFR-02 | Reliability | Controlled network outage does not erase locally committed records |
| NFR-03 | Integrity | Retry does not create duplicate cloud rows when event IDs are honored |
| NFR-04 | Explainability | Every alert contains reasons, quality, baseline/deviation, severity, confidence, and time |
| NFR-05 | Security | Unique device identity, protected credentials, authenticated transport, and access control are documented |
| NFR-06 | Maintainability | Sensor, detector, store, and synchronizer are replaceable through interfaces |
| NFR-07 | Reproducibility | Runs record hardware, software versions, configuration, seed, trace, and network condition |
| NFR-08 | Safety of interpretation | Engineering scores are never labelled as disease probabilities or diagnoses |

## 7. Hardware and software requirements

The minimum hardware is a Raspberry Pi 4 or comparable single-board computer, local microSD/external storage, MAX30102-class heart-rate/SpO₂ sensor if vital-sign claims are retained, temperature sensor, optional environmental sensor, stable power, Wi-Fi, and safe wiring. The planned software stack is Linux, Python, SQLite with WAL, optional NumPy/scikit-learn, a versioned REST/HTTPS API, and a simple dashboard or query interface. Credentials shall be supplied through environment variables or protected configuration, not committed to a repository.

## 8. Data model

### Observation

`event_id` (unique), `device_id`, `event_time`, `created_at`, `sensor`, `raw_value`, `processed_value`, `unit`, `quality_status`, `quality_score`, `baseline`, `deviation`, `severity`, `confidence`, `anomaly_score`, `reason_codes`, `explanation`, `processing_version`, and `sync_status`.

### Synchronization attempt

`attempt_id`, `attempted_at`, `batch_size`, `result`, and redacted `error_category`.

### Alert

`alert_id`, `event_id`, `severity`, `confidence`, `reason_codes`, `model_score`, `explanation`, `delivery_state`, and `created_at`.

## 9. API contract

### Request envelope

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
      "severity": "NORMAL",
      "confidence": "HIGH",
      "reason_codes": [],
      "explanation": "Processed value is within the current baseline."
    }
  ]
}
```

### Response envelope

```json
{
  "accepted": ["edge-device-01-20260921T100000Z-a1b2c3d4"],
  "already_present": [],
  "retryable": [],
  "rejected": [],
  "server_time": "2026-09-21T10:00:01Z"
}
```

## 10. Operating states

- **NORMAL:** collection and synchronization are available.
- **DEGRADED:** local collection continues but cloud synchronization is unavailable.
- **RECOVERING:** connectivity has returned and pending records are being reconciled.
- **SAFE-STOP:** a critical sensor, configuration, or storage fault prevents trustworthy operation; the cause is recorded and confident alerts are disabled.

## 11. Algorithm specification

The quality gate checks missingness, finiteness, configured plausibility, quality hints, and short-window instability. The filter computes a median over the recent window. Baseline deviation is `d_t = x_t - b_t`. Optional normalized deviation is `z_t = (x_t - b_t)/(s_t + ε)`. Rules may use deviation, rate-of-change, and persistence. The optional hybrid score is `A_t = w_r R_t + w_m M_t + w_p P_t`, where the weights are documented engineering parameters and sum to one. Severity and confidence are separate: poor quality may reduce confidence even when deviation is large.

## 12. Security and privacy requirements

The device shall have a unique logical identifier. Credentials shall not be hard-coded or committed. Data in transit shall use authenticated TLS or an equivalent protected channel. The API shall authorize devices and validate schema. Logs shall redact secrets and unnecessary health data. Local retention and storage-pressure behavior shall be documented. Development shall prefer synthetic, public, or consented non-identifying data. The interface shall state that alerts require human review and are not diagnoses. The design aligns its capstone-scale controls with NIST IoT device identity, configuration, and data-protection capabilities.[1]

## 13. Acceptance criteria

The Review–2 minimum acceptance baseline is satisfied when the team can show: a normalized sample path; a quality-aware decision; local persistence; a pending queue; an explanation record; a documented API contract; a network-outage state transition; and a smoke test that executes without syntax failure. Full acceptance for the later project requires physical sensor acquisition, authenticated cloud ingestion, duplicate-safe reconciliation, dashboard visibility, controlled test runs, and measured metrics.

## 14. Traceability

| Objective | Requirements | Evidence |
|---|---|---|
| Collect physiological/environmental readings | FR-01–FR-03 | Sensor/fixture logs and observation schema |
| Reduce noise and identify unreliable data | FR-04–FR-06 | Quality and filter test cases |
| Combine rules and lightweight ML | FR-06–FR-08 | Decision records and model configuration |
| Secure transfer | FR-12, FR-14, NFR-05 | API contract, credential and TLS configuration |
| Preserve data during outages | FR-09–FR-13, NFR-02–NFR-03 | Outage/retry/idempotency tests |
| Provide understandable dashboard alerts | FR-08, FR-15–FR-16, NFR-04, NFR-08 | Alert record and dashboard inspection |

## 15. Review–2 test matrix

| Test ID | Scenario | Expected result | Owner |
|---|---|---|---|
| T-01 | Sensor/fixture sample acquisition | Normalized sample contains value, unit, sensor, and timestamp | Kushal |
| T-02 | Event ID creation | Event ID exists before any sync attempt | Kishan |
| T-03 | SQLite insertion | Observation is locally durable and queryable | Kishan |
| T-04 | Missing/out-of-range sample | INVALID or LOW status; no high-confidence alert | Kishan |
| T-05 | Isolated spike | Processed value and reason code show filtering/instability behavior | Kishan |
| T-06 | Baseline deviation | Deviation and rule reason are recorded | Kishan |
| T-07 | Optional model path | Model score is logged and invalid quality blocks confident scoring | Kishan/Varun |
| T-08 | Explanation fidelity | Reason code matches changed input condition | Gopi |
| T-09 | Write-before-send | Local record exists when sender raises timeout | Kishan/Varun |
| T-10 | Network outage | Queue remains pending; state becomes DEGRADED | Varun |
| T-11 | Reconnection | Pending records drain in event-time order | Varun |
| T-12 | Duplicate retry | Already-present event is not inserted twice | Varun |
| T-13 | Auth/schema failure | Record remains local; failure is categorized and audited | Varun |
| T-14 | Resource run | CPU, memory, latency, and queue depth are recorded | Gopi |
| T-15 | Disclaimer and dashboard | User sees status, reasons, and non-diagnostic scope | Gopi |

## References

[1]: https://doi.org/10.6028/NIST.IR.8259A "NISTIR 8259A IoT Device Cybersecurity Capability Core Baseline"
[2]: https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html "scikit-learn IsolationForest API Reference"
[3]: https://hl7.org/fhir/ "HL7 FHIR Release 5 Specification"
