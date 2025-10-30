class HealthRecord {
  final int id;
  final String recordType;
  final String recordDate;
  final String description;
  final String? clinic;
  final String? nextDueDate;

  HealthRecord({
    required this.id,
    required this.recordType,
    required this.recordDate,
    required this.description,
    this.clinic,
    this.nextDueDate,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as int,
      recordType:
          json['record_type'] as String, // keeps backend <-> app mapping
      recordDate: json['record_date'] as String,
      description: json['description'] as String? ?? '',
      clinic: json['clinic'] as String?,
      nextDueDate: json['nextDueDate'] as String?,
    );
  }
}
