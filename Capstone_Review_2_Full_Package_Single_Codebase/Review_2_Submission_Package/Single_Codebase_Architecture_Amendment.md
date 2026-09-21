# Single-Codebase Architecture Amendment

## Cloud-Based IoT Health Monitoring System

**Project direction:** Secure, Offline-Resilient, Noise-Aware and Explainable Edge–Cloud Anomaly Detection Framework  
**Guide:** Vijay Raja, Assistant Professor, EmpID 9523  
**Team:** Palanati Kushal (2300031426), Y. Kishan (2300030979), D. Varun (2300030156), Dirishala Gopi Krishna (2300030916)

## 1. Decision

Use **Flutter and Dart for one shared user-facing application codebase**. The same Flutter project shall produce:

- A web application that runs in Chrome or another modern browser.
- An Android application.
- A desktop application for Windows, Linux, or macOS.

The application shall communicate with the same versioned backend API on every platform. It shall not contain separate web, Android, and desktop implementations of the dashboard, history, alerts, device status, or settings screens.

The Raspberry Pi sensor service and cloud API remain separate runtime services. This is still a single client codebase, which is the part that must be reused across web, Android, and desktop. Forcing the sensor driver, cloud server, and cross-platform UI into one programming language would reduce reliability and make MAX30102 hardware integration less practical.

> **Final stack:** Flutter/Dart client + FastAPI/Python cloud backend + Python Raspberry Pi edge service + PostgreSQL cloud database + SQLite edge database.

## 2. Why Flutter is the best fit

Flutter supports Android, web, Windows, macOS, and Linux from one Dart application structure. Its widgets, routing, validation, state management, API client, charts, and screens can be shared across platforms. Platform-specific code can be isolated behind small services only when required.

Flutter is more appropriate than separate React, Capacitor, and Tauri applications for this project because the project explicitly requires one cross-platform application codebase. It is also more straightforward than trying to give the Raspberry Pi sensor driver a browser or desktop runtime.

The project shall prioritize a responsive web layout for the Review–2 demonstration. The Android and desktop targets shall reuse the same screens and API models.

## 3. Correct system boundary

```text
                     One Flutter codebase
       ┌──────────────┬──────────────┬──────────────┐
       │              │              │              │
   Flutter Web    Flutter Android  Flutter Desktop  Shared Dart packages
       │              │              │              │
       └──────────────┴──────┬───────┴──────────────┘
                             │ HTTPS/JSON
                             v
                    FastAPI cloud backend
                             │
                    PostgreSQL cloud database
                             ^
                             │ HTTPS/JSON sync
                   Python Raspberry Pi edge service
                             │
                  SQLite local-first database
                             │
                  MAX30102 and other sensors
```

The Flutter application shall never read the Raspberry Pi SQLite file directly. It shall obtain observations, alerts, device status, and synchronization status through the backend API. The edge service shall continue working when the backend cannot be reached.

## 4. Flutter project structure

Create one Flutter repository with this layout:

```text
health_monitoring_platform/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── config/
│   │   ├── errors/
│   │   ├── routing/
│   │   ├── theme/
│   │   └── widgets/
│   ├── models/
│   │   ├── observation.dart
│   │   ├── decision.dart
│   │   ├── alert.dart
│   │   ├── device.dart
│   │   └── sync_status.dart
│   ├── services/
│   │   ├── api_client.dart
│   │   ├── auth_service.dart
│   │   ├── device_service.dart
│   │   └── fixture_service.dart
│   ├── repositories/
│   │   ├── observation_repository.dart
│   │   ├── alert_repository.dart
│   │   └── device_repository.dart
│   ├── features/
│   │   ├── auth/
│   │   ├── overview/
│   │   ├── history/
│   │   ├── alerts/
│   │   ├── devices/
│   │   ├── tests/
│   │   └── settings/
│   └── state/
│       ├── auth_state.dart
│       ├── overview_state.dart
│       ├── history_state.dart
│       └── device_state.dart
├── test/
├── web/
├── android/
├── windows/
├── linux/
├── macos/
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── THIRD_PARTY_NOTICES.md
```

The `lib/` directory contains the shared application logic. The platform folders contain generated or minimal platform wrappers. The team should not create separate dashboard implementations inside `web/`, `android/`, or `windows/`.

## 5. Flutter packages

Use only packages that are necessary and compatible with all target platforms.

| Need | Suggested package type | Rule |
|---|---|---|
| Routing | `go_router` or equivalent | Routes must work on web and packaged applications |
| API requests | `dio` or `http` | Use one API client abstraction |
| State management | Riverpod, Bloc, or Provider | Choose one and use it consistently |
| JSON models | `json_serializable` or manual models | Keep model fields aligned with the API contract |
| Charts | A Flutter chart package | Charts must support mobile, web, and desktop |
| Secure tokens | Platform-compatible secure storage | Do not put credentials in source code |
| Local client cache | Optional SQLite/shared preferences package | Cache is for usability, not edge authority |
| Testing | Flutter unit, widget, and integration tests | Run tests for every supported target where practical |

The team should choose one state-management solution before implementation and record the decision in the repository README. Do not mix multiple state-management patterns.

## 6. Shared application screens

All platforms shall use the same screen definitions and behavior.

### Login screen

The login screen shall authenticate a project operator or viewer using the backend API. It shall display an error for invalid credentials and shall never show tokens or server secrets.

### Overview screen

The overview screen shall display current heart rate, SpO₂, temperature, and any available environmental values. Each card shall include the unit, event time, quality status, and data origin. The screen shall also display the device state, pending queue count, last successful synchronization, and the non-diagnostic disclaimer.

### History screen

The history screen shall show raw and processed measurements over a selected time range. The user shall be able to filter by sensor, severity, quality status, and synchronization state. The data table shall show the event identifier and exact timestamp.

### Alerts screen

The alerts screen shall show engineering review alerts with severity, confidence, quality status, reason codes, baseline, deviation, and explanation. It shall use wording such as “Review required” or “Repeat measurement requested.” It shall not use medical diagnosis language.

### Devices screen

The devices screen shall show registered devices, software version, last contact, last successful synchronization, queue depth, storage condition, and operating state.

### Test screen

The test screen shall be available only to the project operator. It shall submit labelled fixture observations and display the returned decision. Fixture data shall be visually marked as simulated.

## 7. Responsive design rules

The same Flutter widgets shall adapt to different screen sizes.

- On phones, use a bottom navigation bar and stacked observation cards.
- On tablets and desktop, use a side navigation rail and multi-column cards.
- On the web, make tables horizontally scrollable rather than hiding fields.
- On desktop, allow a wider history table and side-by-side trend and alert panels.
- Do not duplicate screens to achieve responsive behavior.

The visual design shall use dark navy for headings, teal for active and healthy states, amber for offline and review states, light slate cards, and a white background. The disclaimer shall remain visible on the overview and alert screens.

## 8. API models shared conceptually by every target

The Flutter models shall match the backend schemas exactly.

```dart
class Observation {
  final String eventId;
  final String deviceId;
  final DateTime eventTime;
  final String sensor;
  final double? rawValue;
  final double? processedValue;
  final String unit;
  final String qualityStatus;
  final double qualityScore;
  final double? baseline;
  final double? deviation;
  final String severity;
  final String confidence;
  final double? anomalyScore;
  final List<String> reasonCodes;
  final String explanation;
  final String syncStatus;
  final String processingVersion;
}
```

The backend remains the source of truth for cloud data. The Flutter client shall treat missing fields and API errors as explicit states. It shall not invent values or silently convert unavailable readings to zero.

## 9. Edge and backend remain separate services

The single-codebase decision does not mean that the Python edge service and FastAPI backend should be rewritten in Dart.

The edge service must interact with I²C, the MAX30102 driver, Linux processes, SQLite, network recovery, and systemd. Python already matches the available public driver and the archived `edge_monitor.py` core.

The FastAPI service must validate requests, authenticate users and devices, manage PostgreSQL, and provide a stable API. It may later be deployed as a container or Linux service.

The Flutter application communicates with both through defined HTTP APIs. This gives the team one shared client while preserving the correct runtime for each system component.

## 10. Hardware integration path

The public [shillehbean/max30102-shilleh](https://github.com/shillehbean/max30102-shilleh) project shall be adapted inside the separate Python edge service. Its sensor driver and threaded monitor shall be wrapped behind a sensor adapter.

The adapter shall output normalized samples in the following form:

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

The edge service shall then apply quality checks, median filtering, baseline/rule decisions, optional Isolation Forest evidence, explanation generation, local SQLite insertion, and cloud synchronization. Flutter shall not know whether the observation came from real hardware or a fixture; the API shall expose a `source` or `data_origin` field so that the UI can label it accurately.

## 11. API routes required by the Flutter client

| Route | Used by Flutter for |
|---|---|
| `POST /api/v1/auth/login` | Login |
| `POST /api/v1/auth/refresh` | Token refresh |
| `GET /api/v1/overview` | Overview screen |
| `GET /api/v1/observations` | History screen |
| `GET /api/v1/alerts` | Alerts screen |
| `GET /api/v1/devices` | Device list |
| `GET /api/v1/devices/{id}` | Device details |
| `GET /api/v1/sync/{id}/status` | Queue and sync state |
| `POST /api/v1/tests/fixtures` | Controlled test data |
| `GET /api/v1/health` | Service health |

The edge service shall use `POST /api/v1/ingest` with device authentication. Human users and devices shall not share credentials.

## 12. Local client offline behavior

The edge device is responsible for preserving health observations. The Flutter client may cache the last successful response so that the interface remains useful during a short client network interruption, but it shall not present stale values as current.

When the Flutter client cannot reach the backend, it shall display:

- “Connection unavailable.”
- The time of the last successful update.
- A stale-data indicator where applicable.
- A retry control.

The client shall not claim that it is collecting sensor data unless it is connected to an active edge service or the screen is using a clearly labelled fixture.

## 13. Single-codebase commands

The project should be created with a single Flutter application:

```bash
flutter create health_monitoring_platform
cd health_monitoring_platform
flutter config --enable-web
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
flutter run -d chrome
flutter run -d android
flutter run -d windows
```

The exact desktop target depends on the development operating system. The team shall first make the web target stable because it is the easiest Review–2 demonstration target, then verify Android and one desktop target.

The backend and edge services shall be kept in separate directories or repositories, for example:

```text
health-monitoring-platform/
├── flutter_app/       # one shared web/Android/desktop codebase
├── backend_api/       # FastAPI and PostgreSQL
└── edge_service/      # Raspberry Pi Python service and SQLite
```

If the department requires one GitHub repository, use this monorepo structure. If it requires separate repositories, link the three repositories in the README and maintain the same API contract.

## 14. Revised implementation order

### Step 1: Build the API contract first

Create the FastAPI routes, Pydantic models, authentication placeholder, and fixture endpoint. Test the endpoints with sample JSON before starting the Flutter UI.

### Step 2: Create the Flutter application

Build login, overview, history, alerts, devices, and test screens with fixture data. Add responsive layouts and shared models. Do not connect to hardware yet.

### Step 3: Add edge SQLite behavior

Align the archived `edge_monitor.py` with the API model. Verify quality status, decision explanation, event identifiers, local insertion, and pending status.

### Step 4: Add cloud synchronization

Implement authenticated batch ingestion and acknowledgement handling. Test outage, retry, and duplicate behavior.

### Step 5: Integrate the MAX30102 adapter

Wrap the public MAX30102 driver and convert its output to the normalized sample model. Keep all processing after the adapter unchanged.

### Step 6: Package the same Flutter app

Run the same Flutter application on Chrome, Android, and one desktop platform. Fix only platform-specific permissions or window behavior in the platform folders. Do not create separate feature implementations.

## 15. Single-codebase acceptance criteria

The single-codebase requirement is satisfied when:

- There is one `flutter_app/lib/` implementation for all client screens.
- The web, Android, and desktop builds use the same Dart models, API client, repositories, state management, routes, and widgets.
- Platform-specific code is limited to configuration, packaging, permissions, and window behavior.
- The same user can log into all three clients and view the same backend observations.
- The same alert explanation and synchronization state are rendered consistently across platforms.
- The edge service can later be connected through the documented API without changing the Flutter screen structure.
- The UI clearly distinguishes real sensor data from fixture data.
- A physical MAX30102 integration can be added without changing the backend observation schema.

## 16. Revised team ownership

| Member | Ownership |
|---|---|
| Palanati Kushal — 2300031426 | Python edge sensor adapter, Raspberry Pi configuration, MAX30102 integration |
| Y. Kishan — 2300030979 | Edge processing, quality gate, filtering, SQLite, decision records |
| D. Varun — 2300030156 | FastAPI backend, authentication, PostgreSQL, ingestion and synchronization |
| Dirishala Gopi Krishna — 2300030916 | Flutter application integration, responsive screens, testing, documentation, and presentation |

All members should make visible commits and be able to explain their own module during the review.

## 17. Final recommendation

Adopt the following final architecture and do not continue with separate React, Capacitor, and Tauri clients:

> **One Flutter/Dart application for web, Android, and desktop; one FastAPI/Python cloud API; one Python/Raspberry Pi edge service; one shared versioned API contract.**

This gives the team a genuinely shared user-facing codebase while keeping hardware access, local persistence, and cloud operations in runtimes that are suitable for those responsibilities.

## References

[1]: https://docs.flutter.dev/reference/supported-platforms "Flutter supported platforms documentation"
[2]: https://github.com/shillehbean/max30102-shilleh "MAX30102 Flask Raspberry Pi health-monitoring reference project"
[3]: https://github.com/Vishnusimha/pipulse "PiPulse Raspberry Pi Flask dashboard and anomaly-detection reference project"
[4]: https://doi.org/10.6028/NIST.IR.8259A "NISTIR 8259A IoT Device Cybersecurity Capability Core Baseline"
