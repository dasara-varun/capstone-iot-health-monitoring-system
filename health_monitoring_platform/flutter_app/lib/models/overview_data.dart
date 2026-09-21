import 'observation.dart';

/// Model representing overview aggregated response.
class OverviewData {
  final String systemState;
  final Map<String, Observation> latestObservations;
  final int pendingQueueCount;
  final String? lastSuccessfulSync;
  final String processingVersion;
  final String disclaimer;

  OverviewData({
    required this.systemState,
    required this.latestObservations,
    required this.pendingQueueCount,
    this.lastSuccessfulSync,
    required this.processingVersion,
    required this.disclaimer,
  });

  factory OverviewData.fromJson(Map<String, dynamic> json) {
    final rawObs = json['latest_observations'] as Map<String, dynamic>? ?? {};
    final Map<String, Observation> observations = {};
    rawObs.forEach((k, v) {
      observations[k] = Observation.fromJson(v as Map<String, dynamic>);
    });

    return OverviewData(
      systemState: json['system_state'] ?? 'NORMAL',
      latestObservations: observations,
      pendingQueueCount: json['pending_queue_count'] ?? 0,
      lastSuccessfulSync: json['last_successful_sync'],
      processingVersion: json['processing_version'] ?? '1.0.0',
      disclaimer: json['disclaimer'] ?? '',
    );
  }
}
