/// Model representing an edge device in the registry.
class DeviceItem {
  final String deviceId;
  final String name;
  final String operatingState;
  final String softwareVersion;
  final String lastContact;
  final String? lastSync;
  final int queueDepth;
  final String storageCondition;
  final double samplingIntervalSec;

  DeviceItem({
    required this.deviceId,
    required this.name,
    required this.operatingState,
    required this.softwareVersion,
    required this.lastContact,
    this.lastSync,
    required this.queueDepth,
    required this.storageCondition,
    required this.samplingIntervalSec,
  });

  factory DeviceItem.fromJson(Map<String, dynamic> json) {
    return DeviceItem(
      deviceId: json['device_id'] ?? '',
      name: json['name'] ?? '',
      operatingState: json['operating_state'] ?? 'NORMAL',
      softwareVersion: json['software_version'] ?? '1.0.0',
      lastContact: json['last_contact'] ?? '',
      lastSync: json['last_sync'],
      queueDepth: json['queue_depth'] ?? 0,
      storageCondition: json['storage_condition'] ?? 'OK',
      samplingIntervalSec: (json['sampling_interval_sec'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
