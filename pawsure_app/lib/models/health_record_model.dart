class HealthRecord {
  final int id;
  final String recordType;
  final DateTime recordDate; // ✅ Changed from String to DateTime
  final String description;
  final String? clinic;
  final DateTime? nextDueDate; // ✅ Changed from String? to DateTime?

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
      // ✅ Parse the string date into DateTime
      recordDate: DateTime.parse(json['record_date'] as String),
      description: json['description'] as String? ?? '',
      clinic: json['clinic'] as String?,
      // ✅ Parse nextDueDate if it exists
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'] as String)
          : null,
    );
  }
}
