import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../models/observation.dart';
import '../models/alert.dart';
import '../models/device.dart';
import '../models/overview_data.dart';

class ApiClient {
  String baseUrl;
  String? authToken;

  ApiClient({String? url}) : baseUrl = url ?? AppConfig.backendUrl;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  Future<bool> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        authToken = data['access_token'];
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<OverviewData> getOverview() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/overview'), headers: _headers);
      if (res.statusCode == 200) {
        return OverviewData.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return _mockOverview();
  }

  Future<List<Observation>> getObservations({String? sensor, String? severity, String? qualityStatus}) async {
    try {
      final uri = Uri.parse('$baseUrl/observations').replace(queryParameters: {
        if (sensor != null && sensor.isNotEmpty && sensor != 'ALL') 'sensor': sensor,
        if (severity != null && severity.isNotEmpty && severity != 'ALL') 'severity': severity,
        if (qualityStatus != null && qualityStatus.isNotEmpty && qualityStatus != 'ALL') 'quality_status': qualityStatus,
      });
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        return list.map((e) => Observation.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return _mockObservations();
  }

  Future<List<AlertItem>> getAlerts({String? severity}) async {
    try {
      final uri = Uri.parse('$baseUrl/alerts').replace(queryParameters: {
        if (severity != null && severity.isNotEmpty && severity != 'ALL') 'severity': severity,
      });
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        return list.map((e) => AlertItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return _mockAlerts();
  }

  Future<List<DeviceItem>> getDevices() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/devices'), headers: _headers);
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        return list.map((e) => DeviceItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [
      DeviceItem(
        deviceId: 'edge-device-01',
        name: 'Raspberry Pi 4 Edge Gateway',
        operatingState: 'NORMAL',
        softwareVersion: '1.0.0',
        lastContact: DateTime.now().toIso8601String(),
        lastSync: DateTime.now().toIso8601String(),
        queueDepth: 0,
        storageCondition: 'OK (WAL Mode)',
        samplingIntervalSec: 2.0,
      )
    ];
  }

  Future<bool> injectFixture(String scenario) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/tests/fixtures'),
        headers: _headers,
        body: jsonEncode({'device_id': 'edge-device-01', 'scenario': scenario, 'count': 1}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // --- Fallback Mocks when backend is initializing ---
  OverviewData _mockOverview() {
    final now = DateTime.now().toIso8601String();
    return OverviewData(
      systemState: 'NORMAL',
      latestObservations: {
        'spo2': Observation(
          eventId: 'edge-dev-01-mock-spo2',
          deviceId: 'edge-device-01',
          eventTime: now,
          sensor: 'spo2',
          rawValue: 98.0,
          processedValue: 98.0,
          unit: '%',
          qualityStatus: 'ACCEPTABLE',
          qualityScore: 0.98,
          baseline: 98.0,
          deviation: 0.0,
          severity: 'NORMAL',
          confidence: 'HIGH',
          reasonCodes: [],
          explanation: 'Processed value is within current baseline.',
          syncStatus: 'SYNCHRONIZED',
          createdAt: now,
          isFixture: true,
        ),
        'heart_rate': Observation(
          eventId: 'edge-dev-01-mock-hr',
          deviceId: 'edge-device-01',
          eventTime: now,
          sensor: 'heart_rate',
          rawValue: 74.0,
          processedValue: 74.0,
          unit: 'bpm',
          qualityStatus: 'ACCEPTABLE',
          qualityScore: 0.96,
          baseline: 73.0,
          deviation: 1.0,
          severity: 'NORMAL',
          confidence: 'HIGH',
          reasonCodes: [],
          explanation: 'Heart rate steady within baseline.',
          syncStatus: 'SYNCHRONIZED',
          createdAt: now,
          isFixture: true,
        ),
        'temperature': Observation(
          eventId: 'edge-dev-01-mock-temp',
          deviceId: 'edge-device-01',
          eventTime: now,
          sensor: 'temperature',
          rawValue: 36.6,
          processedValue: 36.6,
          unit: 'degC',
          qualityStatus: 'ACCEPTABLE',
          qualityScore: 0.99,
          baseline: 36.6,
          deviation: 0.0,
          severity: 'NORMAL',
          confidence: 'HIGH',
          reasonCodes: [],
          explanation: 'Temperature reading normal.',
          syncStatus: 'SYNCHRONIZED',
          createdAt: now,
          isFixture: true,
        ),
      },
      pendingQueueCount: 0,
      lastSuccessfulSync: now,
      processingVersion: '1.0.0',
      disclaimer: AppConfig.disclaimer,
    );
  }

  List<Observation> _mockObservations() {
    final now = DateTime.now();
    return List.generate(5, (i) {
      final t = now.subtract(Duration(seconds: i * 15)).toIso8601String();
      return Observation(
        eventId: 'evt-hist-$i',
        deviceId: 'edge-device-01',
        eventTime: t,
        sensor: i % 2 == 0 ? 'spo2' : 'heart_rate',
        rawValue: i % 2 == 0 ? 97.0 - i : 72.0 + i * 2,
        processedValue: i % 2 == 0 ? 97.0 - i : 72.0 + i * 2,
        unit: i % 2 == 0 ? '%' : 'bpm',
        qualityStatus: 'ACCEPTABLE',
        qualityScore: 0.95,
        baseline: i % 2 == 0 ? 97.0 : 72.0,
        deviation: (i % 2 == 0 ? -i : i * 2).toDouble(),
        severity: i > 2 ? 'OBSERVE' : 'NORMAL',
        confidence: 'HIGH',
        reasonCodes: i > 2 ? ['deviation_from_baseline'] : [],
        explanation: i > 2 ? 'Decision based on: deviation_from_baseline.' : 'Processed value is within baseline.',
        syncStatus: 'SYNCHRONIZED',
        createdAt: t,
        isFixture: true,
      );
    });
  }

  List<AlertItem> _mockAlerts() {
    final now = DateTime.now().toIso8601String();
    return [
      AlertItem(
        eventId: 'evt-alert-demo',
        deviceId: 'edge-device-01',
        eventTime: now,
        sensor: 'spo2',
        rawValue: 88.0,
        processedValue: 89.0,
        unit: '%',
        baseline: 97.0,
        deviation: -8.0,
        severity: 'REVIEW',
        confidence: 'HIGH',
        qualityStatus: 'ACCEPTABLE',
        reasonCodes: ['deviation_from_baseline', 'sustained_hypoxia_pattern'],
        explanation: 'SpO2 reading is 8% below baseline. Engineering review recommended.',
        isFixture: true,
      )
    ];
  }
}
