/// Model representing an observation record matching backend schema.
class Observation {
  final String eventId;
  final String deviceId;
  final String eventTime;
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
  final String createdAt;
  final bool isFixture;

  Observation({
    required this.eventId,
    required this.deviceId,
    required this.eventTime,
    required this.sensor,
    this.rawValue,
    this.processedValue,
    required this.unit,
    required this.qualityStatus,
    required this.qualityScore,
    this.baseline,
    this.deviation,
    required this.severity,
    required this.confidence,
    this.anomalyScore,
    required this.reasonCodes,
    required this.explanation,
    required this.syncStatus,
    required this.createdAt,
    required this.isFixture,
  });

  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      eventId: json['event_id'] ?? '',
      deviceId: json['device_id'] ?? '',
      eventTime: json['event_time'] ?? '',
      sensor: json['sensor'] ?? '',
      rawValue: json['raw_value'] != null ? (json['raw_value'] as num).toDouble() : null,
      processedValue: json['processed_value'] != null ? (json['processed_value'] as num).toDouble() : null,
      unit: json['unit'] ?? '',
      qualityStatus: json['quality_status'] ?? 'ACCEPTABLE',
      qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 1.0,
      baseline: json['baseline'] != null ? (json['baseline'] as num).toDouble() : null,
      deviation: json['deviation'] != null ? (json['deviation'] as num).toDouble() : null,
      severity: json['severity'] ?? 'NORMAL',
      confidence: json['confidence'] ?? 'HIGH',
      anomalyScore: json['anomaly_score'] != null ? (json['anomaly_score'] as num).toDouble() : null,
      reasonCodes: (json['reason_codes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      explanation: json['explanation'] ?? '',
      syncStatus: json['sync_status'] ?? 'SYNCHRONIZED',
      createdAt: json['created_at'] ?? '',
      isFixture: json['is_fixture'] ?? false,
    );
  }
}
