// pawsure_app/lib/models/event_model.dart

enum EventType {
  health,
  sitter,
  grooming,
  activity,
  other;

  static EventType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'health':
        return EventType.health;
      case 'sitter':
        return EventType.sitter;
      case 'grooming':
        return EventType.grooming;
      case 'activity':
        return EventType.activity;
      default:
        return EventType.other;
    }
  }

  String toJson() => name;
}

enum EventStatus {
  upcoming,
  pending,
  completed,
  missed;

  static EventStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'upcoming':
        return EventStatus.upcoming;
      case 'pending':
        return EventStatus.pending;
      case 'completed':
        return EventStatus.completed;
      case 'missed':
        return EventStatus.missed;
      default:
        return EventStatus.upcoming;
    }
  }

  String toJson() => name;
}

class EventModel {
  final int id;
  final String title;
  final DateTime dateTime;
  final EventType eventType;
  final EventStatus status;
  final String? location;
  final String? notes;
  final int petId;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.eventType,
    required this.status,
    this.location,
    this.notes,
    required this.petId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper for UI to treat single pet ID as list (for compatibility)
  List<int> get petIds => [petId];

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      title: json['title'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      eventType: EventType.fromString(json['eventType'] as String),
      status: EventStatus.fromString(json['status'] as String),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      petId: json['petId'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'eventType': eventType.toJson(),
      'status': status.toJson(),
      'location': location,
      'notes': notes,
      'petId': petId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPast => dateTime.isBefore(DateTime.now());

  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  String get displayDate {
    if (isToday) return 'Today';
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    if (dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day) {
      return 'Tomorrow';
    }
    return '${dateTime.day} ${_monthName(dateTime.month)}';
  }

  String get displayTime {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // ✅ FIX: Added copyWith method
  EventModel copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    EventType? eventType,
    EventStatus? status,
    String? location,
    String? notes,
    int? petId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      petId: petId ?? this.petId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
