import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../models/observation.dart';
import '../models/alert.dart';
import '../models/device.dart';
import '../models/overview_data.dart';

class AppState extends ChangeNotifier {
  final ApiClient apiClient;

  int _selectedNavIndex = 0;
  int get selectedNavIndex => _selectedNavIndex;

  String _currentUser = 'operator';
  String get currentUser => _currentUser;

  String _userRole = 'operator';
  String get userRole => _userRole;

  bool _isLoggedIn = true;
  bool get isLoggedIn => _isLoggedIn;

  OverviewData? _overview;
  OverviewData? get overview => _overview;

  List<Observation> _observations = [];
  List<Observation> get observations => _observations;

  List<AlertItem> _alerts = [];
  List<AlertItem> get alerts => _alerts;

  List<DeviceItem> _devices = [];
  List<DeviceItem> get devices => _devices;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  String _filterSensor = 'ALL';
  String get filterSensor => _filterSensor;

  String _filterSeverity = 'ALL';
  String get filterSeverity => _filterSeverity;

  String _filterQuality = 'ALL';
  String get filterQuality => _filterQuality;

  Timer? _pollingTimer;

  AppState({ApiClient? client, bool enablePolling = true}) : apiClient = client ?? ApiClient() {
    refreshAll();
    if (enablePolling) {
      _startPolling();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      refreshOverviewSilently();
    });
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
    if (index == 1) refreshObservations();
    if (index == 2) refreshAlerts();
    if (index == 3) refreshDevices();
  }

  void setFilters({String? sensor, String? severity, String? quality}) {
    if (sensor != null) _filterSensor = sensor;
    if (severity != null) _filterSeverity = severity;
    if (quality != null) _filterQuality = quality;
    notifyListeners();
    refreshObservations();
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([
      refreshOverviewSilently(),
      refreshObservations(),
      refreshAlerts(),
      refreshDevices(),
    ]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshOverviewSilently() async {
    _overview = await apiClient.getOverview();
    notifyListeners();
  }

  Future<void> refreshObservations() async {
    _observations = await apiClient.getObservations(
      sensor: _filterSensor == 'ALL' ? null : _filterSensor,
      severity: _filterSeverity == 'ALL' ? null : _filterSeverity,
      qualityStatus: _filterQuality == 'ALL' ? null : _filterQuality,
    );
    notifyListeners();
  }

  Future<void> refreshAlerts() async {
    _alerts = await apiClient.getAlerts();
    notifyListeners();
  }

  Future<void> refreshDevices() async {
    _devices = await apiClient.getDevices();
    notifyListeners();
  }

  Future<bool> injectFixture(String scenario) async {
    _statusMessage = 'Injecting $scenario fixture...';
    notifyListeners();
    final ok = await apiClient.injectFixture(scenario);
    if (ok) {
      _statusMessage = 'Successfully injected $scenario fixture!';
      await refreshAll();
    } else {
      _statusMessage = 'Failed to inject fixture (check backend).';
    }
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _statusMessage = null;
      notifyListeners();
    });
    return ok;
  }

  Future<bool> login(String username, String password) async {
    final success = await apiClient.login(username, password);
    if (success) {
      _currentUser = username;
      _userRole = username == 'operator' ? 'operator' : 'viewer';
      _isLoggedIn = true;
      notifyListeners();
      await refreshAll();
      return true;
    }
    return false;
  }

  void logout() {
    apiClient.authToken = null;
    _currentUser = 'Guest Viewer';
    _userRole = 'viewer';
    _isLoggedIn = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
