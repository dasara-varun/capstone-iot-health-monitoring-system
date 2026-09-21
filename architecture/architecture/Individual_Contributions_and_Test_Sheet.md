# Individual Contributions and Test-Evidence Sheet

**Project:** Cloud-Based IoT Health Monitoring System  
**Review:** Capstone Project Review–2, 22–24 September 2026  
**Guide:** Vijay Raja, Assistant Professor, EmpID 9523

> Complete the result/evidence columns with the team’s actual hardware or fixture outputs before submission. The archive supports the edge-core smoke test described below, but it does not prove that every physical, cloud, security, or dashboard test has already been executed.

## 1. Individual task distribution

| Member | Assigned module | Review–2 explanation | Evidence to attach |
|---|---|---|---|
| Palanati Kushal — 2300031426 | Raspberry Pi and sensor interface | GPIO/I²C or driver path, sampling interval, wiring, power/network constraints | Wiring photograph, sensor read log, interface configuration |
| Y. Kishan — 2300030979 | Edge processing and local persistence | `Sample`, `Decision`, quality gate, median processing, baseline, SQLite, pending queue | `edge_monitor.py`, terminal output, database query or schema capture |
| D. Varun — 2300030156 | Cloud API and synchronization | Request/response envelope, authentication, accepted/already-present/retryable/rejected semantics | API contract, server/mock response, sync log |
| Dirishala Gopi Krishna — 2300030916 | Integration, evaluation, and documentation | Architecture, traceability, state machine, metrics, risks, Review–1 improvements | SRS, diagrams, test matrix, sprint log, presentation |

## 2. Evidence available from the archive

The archived `paper research/edge_monitor.py` was executed in the sandbox. It produced two pending SpO₂ observations, one processed value, quality status, baseline/deviation fields, reason codes, explanations, and `sync_status: PENDING`. Python compilation passed. This verifies only the hardware-agnostic edge-core path.

**Smoke-test artifact:** [edge_smoke_output.txt](/home/ubuntu/work/capstone_review/edge_smoke_output.txt)

## 3. Test result register

| Test ID | Owner | Result status before final team run | Actual result/evidence to fill |
|---|---|---|---|
| T-01 Sensor/fixture acquisition | Kushal | Not established by archive | ______________________________ |
| T-02 Event ID creation | Kishan | Demonstrated in archived module | ______________________________ |
| T-03 SQLite insertion | Kishan | Demonstrated in archived module | ______________________________ |
| T-04 Invalid/low-quality handling | Kishan | Implemented; execute branch test | ______________________________ |
| T-05 Spike/filter response | Kishan | Implemented; execute controlled trace | ______________________________ |
| T-06 Baseline deviation | Kishan | Demonstrated in smoke output | ______________________________ |
| T-07 Optional Isolation Forest | Kishan/Varun | Proposed/optional; no measured result in archive | ______________________________ |
| T-08 Explanation fidelity | Gopi | Proposed test; no measured result in archive | ______________________________ |
| T-09 Write-before-send timeout | Kishan/Varun | Sync exception handling exists; execute timeout sender | ______________________________ |
| T-10 Network outage | Varun | Architecture specified; no cloud result in archive | ______________________________ |
| T-11 Reconnection drain | Varun | Architecture specified; no cloud result in archive | ______________________________ |
| T-12 Duplicate retry | Varun | Contract specified; no cloud result in archive | ______________________________ |
| T-13 Auth/schema failure | Varun | Error categories exist; execute API test | ______________________________ |
| T-14 Resource metrics | Gopi | Not measured in archive | ______________________________ |
| T-15 Disclaimer/dashboard | Gopi | Dashboard not present in archive | ______________________________ |

## 4. Individual viva prompts

### Palanati Kushal

Explain the sensor interface, why the selected sensor is suitable for a low-cost prototype, how the Raspberry Pi communicates with it, what failure modes can create unreliable readings, and how the system avoids calling low-quality data a diagnosis.

### Y. Kishan

Walk through `Sample → HybridDetector.evaluate() → Decision → LocalStore.add()`. Explain the median window, quality status, baseline deviation, reason codes, WAL mode, event ID, and why local commit occurs before synchronization.

### D. Varun

Explain the cloud request envelope, device authentication, idempotent event IDs, server response categories, and why a generic HTTP 200 response is insufficient for a partial batch.

### Dirishala Gopi Krishna

Explain the architecture, Review–1 improvements, traceability matrix, state machine, test matrix, project limits, and how the team separates engineering anomaly labels from clinical claims.

## 5. Submission checklist

- [ ] Names, IDs, and guide EmpID checked against the final team record.
- [ ] One contribution slide or table is included in the deck.
- [ ] Each member has one named module and one evidence artifact.
- [ ] No unmeasured accuracy, latency, data-loss, or model-performance values are presented.
- [ ] The archived smoke test is labelled as edge-core evidence, not a complete prototype.
- [ ] Any adapted public GitHub code is attributed and license-checked.
- [ ] The dashboard and physical prototype are described as pending unless actually demonstrated.
