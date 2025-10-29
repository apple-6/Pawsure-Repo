class HealthRecord {
  final int id;
  final String record_type;
  final String record_date;
  final String description;

  HealthRecord({
    required this.id,
    required this.record_type,
    required this.record_date,
    required this.description,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as int,
      record_type: json['record_type'] as String,
      record_date: json['record_date'] as String,
      description: json['description'] as String,
    );
  }
}
