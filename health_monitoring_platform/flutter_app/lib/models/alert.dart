/// Model representing an engineering review alert.
class AlertItem {
  final String eventId;
  final String deviceId;
  final String eventTime;
  final String sensor;
  final double? rawValue;
  final double? processedValue;
  final String unit;
  final double? baseline;
  final double? deviation;
  final String severity;
  final String confidence;
  final String qualityStatus;
  final List<String> reasonCodes;
  final String explanation;
  final bool isFixture;

  AlertItem({
    required this.eventId,
    required this.deviceId,
    required this.eventTime,
    required this.sensor,
    this.rawValue,
    this.processedValue,
    required this.unit,
    this.baseline,
    this.deviation,
    required this.severity,
    required this.confidence,
    required this.qualityStatus,
    required this.reasonCodes,
    required this.explanation,
    required this.isFixture,
  });

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      eventId: json['event_id'] ?? '',
      deviceId: json['device_id'] ?? '',
      eventTime: json['event_time'] ?? '',
      sensor: json['sensor'] ?? '',
      rawValue: json['raw_value'] != null ? (json['raw_value'] as num).toDouble() : null,
      processedValue: json['processed_value'] != null ? (json['processed_value'] as num).toDouble() : null,
      unit: json['unit'] ?? '',
      baseline: json['baseline'] != null ? (json['baseline'] as num).toDouble() : null,
      deviation: json['deviation'] != null ? (json['deviation'] as num).toDouble() : null,
      severity: json['severity'] ?? 'REVIEW',
      confidence: json['confidence'] ?? 'HIGH',
      qualityStatus: json['quality_status'] ?? 'ACCEPTABLE',
      reasonCodes: (json['reason_codes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      explanation: json['explanation'] ?? '',
      isFixture: json['is_fixture'] ?? false,
    );
  }
}
