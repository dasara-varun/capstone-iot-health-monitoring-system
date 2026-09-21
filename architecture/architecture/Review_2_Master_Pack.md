# Capstone Project Review–2 Master Pack

## Cloud-Based IoT Health Monitoring System

**Review:** Capstone Project Review–2 — System Design & Partial Implementation  
**Review window:** 22–24 September 2026  
**Specialization:** Cloud and Edge Computing  
**Course/project code:** 23IE4053A / Capstone Project 4  
**Academic year:** 2026  
**Guide:** Vijay Raja, Assistant Professor, **EmpID: 9523**

> **Scope boundary:** This project is a monitoring and decision-support prototype. It is not a certified medical device, does not diagnose disease, and must not be presented as a replacement for clinical judgment.

## 1. Team and individual responsibilities

| Student | Registration ID | Review–2 responsibility | Evidence to explain individually |
|---|---:|---|---|
| Palanati Kushal | 2300031426 | Edge hardware integration | Raspberry Pi setup, sensor wiring/interface, sampling, device/network readiness, hardware limitations |
| Y. Kishan | 2300030979 | Edge software and decision module | Python collector, SQLite local store, filtering, quality checks, baseline/rule decision path |
| D. Varun | 2300030156 | Cloud platform and API | Authenticated ingestion contract, cloud storage/dashboard plan, acknowledgement semantics, sync states |
| Dirishala Gopi Krishna | 2300030916 | System integration and project lead | Architecture integration, test matrix, traceability, documentation, review coordination |

The archive explicitly identifies the four students and guide in the final seminar and journal papers and lists the four functional roles in the original abstract. The mapping above follows the team order in the Review–1 presentation and the four roles in the proposal. If the guide has approved a different allocation, update this table before submission.

## 2. Project evolution and current direction

### 2.1 Original direction

The first abstract and proposal described a generic **cloud-based IoT health-monitoring system**. The initial aim was to collect physiological and environmental data using a Raspberry Pi, perform preliminary edge processing, upload filtered data to AWS/Azure or another cloud service, and provide long-term storage and a caregiver dashboard. The early hardware list included a Raspberry Pi 4, temperature/humidity/gas sensors, a camera module, local storage, Wi-Fi, power backup, and a free-tier cloud service. The original plan was divided into Capstone-1 hardware/networking/cloud setup and Capstone-2 edge analytics, cloud integration, dashboard development, testing, and deployment.

### 2.2 Direction refined after Review–1

The Review–1 presentation correctly identified that a dashboard alone was not a sufficiently strong capstone contribution. The project therefore moved toward a **secure, offline-resilient, noise-aware, and explainable edge–cloud anomaly-detection framework**. The revised direction adds five engineering properties that were under-specified in the original plan:

1. **Noise awareness:** invalid, unstable, or implausible readings are marked and filtered rather than being treated as trustworthy anomalies.
2. **Edge-first decisions:** the Raspberry Pi performs local preprocessing and first-level prioritization without waiting for the cloud.
3. **Offline resilience:** observations are committed to a local SQLite queue before network transmission and synchronized after reconnection.
4. **Explainability:** each decision stores quality status, baseline, deviation, reason codes, severity, confidence, and optional model contribution.
5. **Security:** device identity, protected secrets, authenticated transport, access control, and audit events are part of the design.

### 2.3 Current project statement

> **How can a low-cost edge–cloud IoT health-monitoring prototype continue collecting and preserving data during connectivity loss, reduce the influence of noisy measurements, produce explainable anomaly alerts, and protect device-to-cloud communication without making unsupported clinical claims?**

The minimum defensible Review–2 artifact is one Raspberry Pi-class edge node, one or two sensors, the local processing path, durable SQLite storage, a documented cloud/API contract, and controlled evidence that the core module executes. A full dashboard, notifications, multi-patient scaling, FHIR exchange, and advanced machine learning are extensions rather than prerequisites for claiming a coherent Review–2 design.

## 3. Review–2 readiness mapped to the department rubric

| Review–2 criterion | What must be shown | Current evidence from the archive | Review–2 response |
|---|---|---|---|
| System requirements and functional specifications | Complete, unambiguous, traceable requirements | Final seminar paper Sections 3–4 define functional, non-functional, boundary, ethics, and acceptance requirements | Use the attached SRS; show requirement IDs and traceability to objectives/tests |
| System design and architecture | Architecture, ER/data model, workflow, state transitions, design rationale | `architecture.mmd`, `data_lifecycle.mmd`, `system_states.mmd`, `seminar_workflow.mmd`; final papers define layers and queue semantics | Present sensing, edge, cloud, security, and evaluation planes; emphasize write-before-send and idempotent event IDs |
| Initial implementation/prototype | Working core functionality aligned with design | `edge_monitor.py` contains Sample, Decision, LocalStore, HybridDetector, event IDs, local queue, and sync stub | Demonstrate the archived core module only if your team can reproduce it; do not claim a full cloud deployment that is not present in the archive |
| Tools and technologies | Appropriate modern tools, correctly justified | Python, SQLite/WAL, Raspberry Pi, Linux, REST/HTTPS/TLS plan, optional scikit-learn Isolation Forest, Mermaid diagrams, GitHub workflow | Explain why local persistence and lightweight models fit Raspberry Pi constraints |
| Teamwork and Agile practice | Iteration, roles, milestones, contribution evidence | Review–1 presentation, six-month plan, four role definitions, research notes, revised seminar/journal papers | Show Review–1 improvements, role allocation, sprint evidence, individual test sheet, and next sprint backlog |

## 4. System requirements summary

### Functional requirements

- **FR-01:** The system shall acquire configurable time-stamped measurements from supported physiological and environmental sensors.
- **FR-02:** Each observation shall receive a stable event ID, device ID, event time, sensor type, value, unit, quality status, and synchronization status.
- **FR-03:** The edge node shall detect missing, non-finite, stale, or physically implausible values and record them as invalid or low quality.
- **FR-04:** The edge node shall apply a transparent short-window filter while preserving the raw value.
- **FR-05:** The decision module shall calculate a baseline deviation and apply configurable rule evidence.
- **FR-06:** When enough training data exist, the system may add an Isolation Forest contribution; model output shall not override an invalid quality status.
- **FR-07:** Every decision or alert shall include an explanation generated from the same reason codes used in the decision.
- **FR-08:** The edge shall commit the observation locally before attempting cloud synchronization.
- **FR-09:** During network failure, the edge shall retain pending observations and continue local collection.
- **FR-10:** After reconnection, the synchronizer shall submit pending batches and mark only accepted or already-present event IDs as synchronized.
- **FR-11:** The cloud ingestion endpoint shall validate schema, authenticate the device, and enforce event-ID uniqueness.
- **FR-12:** The system shall record synchronization success, retryable failure, authentication failure, malformed payloads, and storage pressure.

### Non-functional requirements

The prototype shall be feasible on Raspberry Pi-class hardware, modular, reproducible, auditable, and safe in its wording. It shall degrade visibly rather than silently losing evidence. It shall avoid treating engineering anomaly scores as disease probabilities. It shall protect stored and transmitted data using the controls feasible at capstone scale. It shall preserve original event times during delayed synchronization and avoid duplicate records on retries.

### Hardware requirements

| Item | Minimum requirement | Purpose |
|---|---|---|
| Raspberry Pi 4 or comparable SBC | 1 | Edge collector, local processing, SQLite, synchronization worker |
| MAX30102-class heart-rate/SpO₂ sensor | 1 if vital-sign claims are retained | Physiological sensing over I²C or compatible interface |
| Temperature sensor | 1 | Additional observation channel and environmental context |
| Optional environmental sensor | 1 | Demonstration of multi-sensor acquisition; not required for minimum path |
| microSD or external storage | 32–64 GB | OS, code, logs, SQLite queue |
| Wi-Fi/network access | 1 | Cloud synchronization when available |
| Stable power supply or power bank | 1 | Edge operation and controlled short outage demonstration |
| Jumper wires, breadboard, resistors, cooling | As required | Safe physical interfacing |

The original estimate in the archive is approximately ₹12,000–₹17,000 depending on the final physiological sensor selection. This is a planning estimate, not a measured purchase total.

## 5. Architecture and algorithms to present

### 5.1 Layered architecture

The system has five logical planes:

- **Sensing plane:** heart-rate/SpO₂ and temperature/environment sensors.
- **Edge plane:** collector, quality gate, median filter, baseline/rule engine, optional model, SQLite store, and synchronization worker.
- **Cloud plane:** authenticated ingestion API, database, dashboard/history, and optional notification adapter.
- **Security plane:** device identity, protected secrets, TLS, authorization, audit, and retention controls spanning all layers.
- **Evaluation plane:** fixtures, controlled injected spikes, outage scenarios, duplicate retries, malformed payloads, and resource logging.

### 5.2 Decision path

1. Read a sensor sample and assign an event ID and timestamp.
2. Check missingness, finite value, configured plausibility range, and short-window stability.
3. Compute a robust processed value using a short median window.
4. Compare the processed value with the current baseline and calculate deviation.
5. Apply transparent rule evidence and persistence logic.
6. Optionally compute a lightweight Isolation Forest contribution using compact features.
7. Map the evidence to severity and confidence, keeping those concepts separate.
8. Create an explanation with reason codes and commit the record locally.
9. Attempt secure synchronization only after the local commit.

Isolation Forest is suitable as an optional model because it isolates observations using random feature/split selections; anomalous samples tend to have shorter path lengths. The team must document estimator count, sample policy, contamination assumption, feature order, random seed, and training/evaluation separation. The model output is an engineering prioritization score, not a diagnosis.[1]

### 5.3 Offline synchronization contract

Every record is locally durable before transmission. The cloud response must identify `accepted`, `already_present`, `retryable`, and `rejected` event IDs. Accepted and already-present records become `SYNCHRONIZED`. Retryable failures remain pending with bounded backoff. Authentication or schema failures are audited and must not trigger unbounded retry. The cloud must treat `event_id` as a unique key, making retries idempotent.

## 6. Review–1 improvements to state explicitly

The team should present the following as direct responses to the earlier review and research gaps:

- The project moved from a broad dashboard-first proposal to a failure-aware local-first architecture.
- Physiological sensing is now tied to a MAX30102-class sensor rather than unspecified health claims.
- The earlier generic “machine learning” phrase is now an optional, lightweight Isolation Forest layer behind a quality gate and transparent rules.
- Offline operation is now specified through SQLite, write-before-send ordering, pending states, stable event IDs, and duplicate-safe acknowledgements.
- “Secure communication” is expanded into device identity, credential protection, TLS, authorization, audit, and retention assumptions.
- Evaluation now separates engineering anomaly labels from clinical claims and defines outage, noise, duplicate, malformed-request, latency, resource, and explanation tests.
- The research papers now distinguish planned/proposed behavior from measured results and explicitly avoid invented performance numbers.

## 7. Partial implementation status and honest demonstration script

The archive contains `edge_monitor.py`, a hardware-agnostic reference core. It implements:

- `Sample` and `Decision` data structures;
- SQLite local persistence with WAL mode;
- observation fields including event ID, raw/processed value, quality, baseline, deviation, severity, confidence, reasons, explanation, and sync status;
- plausibility and short-window quality checks;
- median processing and baseline adaptation;
- local pending-queue retrieval;
- duplicate-safe local insertion using `INSERT OR IGNORE`;
- a synchronization interface stub that handles accepted/already-present, timeout, permission, and unexpected errors.

The archive smoke test produced two pending SpO₂ observations, a processed second value, a quality status, a baseline deviation, and `PY_COMPILE=PASS`. This is evidence for the edge-core module only. It is **not** evidence of a completed physical sensor integration, cloud deployment, dashboard, or measured detection accuracy.

### Suggested live explanation

> “Our Review–2 implementation evidence is the edge decision and persistence core. A sensor fixture or driver produces a normalized `Sample`. The detector returns a quality-aware `Decision`. The local store writes the observation before synchronization. The current archive includes the sync interface contract, but the complete physical and cloud integration remains the next implementation step. We therefore present the prototype honestly as a partial edge module rather than claiming a finished medical-monitoring system.”

## 8. Public GitHub reference

### Primary recommendation

**[krtaylor/IoT-Health-Monitor](https://github.com/krtaylor/IoT-Health-Monitor)**

This is the closest starting point for your hardware demonstration because its README explicitly lists a Raspberry Pi 4, a MAX30102 heart-rate and blood-oxygen sensor, Arduino/ESP32 components, and a web-based logging objective. It is a reference repository, not your project’s repository, and its README does not establish that it implements your full offline-first, explainable, secure architecture.

### What to reuse conceptually

Use it as a reference for Raspberry Pi/MAX30102 wiring, sensor acquisition, and basic web logging. Do not copy its claims or submit its code as your own. Check its license and preserve attribution if you adapt any code.

### Required additions for project alignment

Your project still needs to add or preserve: local SQLite write-before-send behavior; stable event IDs; duplicate-safe cloud acknowledgements; quality states; reason-code explanations; authenticated ingestion; explicit outage recovery; and controlled evaluation. A second useful reference is **[HassanMahmoodKhan/Remote-Health-Monitoring-With-IoT](https://github.com/HassanMahmoodKhan/Remote-Health-Monitoring-With-IoT)** for Raspberry Pi-to-gateway MQTT, publisher/subscriber separation, cloud storage, and ML workflow ideas. It should be treated as an architectural reference rather than a direct implementation match.

## 9. Immediate action plan before the review

| Priority | Action | Owner | Evidence for panel |
|---:|---|---|---|
| 1 | Freeze the minimum scope to one edge node, one physiological sensor, local queue, and one decision path | Gopi + all | Signed scope statement and updated architecture |
| 2 | Confirm actual hardware and demonstrate sensor read or fixture input | Kushal | Wiring photo, serial output, or controlled fixture log |
| 3 | Reproduce `edge_monitor.py` smoke run and explain every output field | Kishan | Terminal capture and module walkthrough |
| 4 | Finalize API envelope and acknowledgement semantics | Varun | JSON contract and request/response examples |
| 5 | Run the individual test matrix in the companion sheet | Each member | Named test result and evidence path |
| 6 | Rehearse 10–15 minute presentation plus individual questions | All | One-minute contribution explanation per member |

## References

[1]: https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html "scikit-learn IsolationForest API Reference"
[2]: https://doi.org/10.6028/NIST.IR.8259A "NISTIR 8259A IoT Device Cybersecurity Capability Core Baseline"
[3]: https://hl7.org/fhir/ "HL7 FHIR Release 5 Specification"
[4]: https://www.who.int/health-topics/digital-health "World Health Organization Digital Health"
[5]: https://pmc.ncbi.nlm.nih.gov/articles/PMC9601552/ "IoT-Based Healthcare-Monitoring System towards Improving Quality of Life: A Review"
[6]: https://doi.org/10.3390/fi16090329 "Edge Computing in Healthcare: Innovations, Opportunities, and Challenges"
[7]: https://github.com/krtaylor/IoT-Health-Monitor "IoT Health Monitor public GitHub repository"
[8]: https://github.com/HassanMahmoodKhan/Remote-Health-Monitoring-With-IoT "Remote Health Monitoring With IoT public GitHub repository"
