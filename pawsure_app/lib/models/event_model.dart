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

extension EventTypeExtension on EventType {
  static EventType fromJson(String value) => EventType.fromString(value);
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

extension EventStatusExtension on EventStatus {
  static EventStatus fromJson(String value) => EventStatus.fromString(value);
}

class EventModel {
  final int id;
  final String title;
  final DateTime dateTime;
  final EventType eventType;
  final EventStatus status;
  final String? location;
  final String? notes;

  // ✅ NEW: Multi-pet support
  final List<int> petIds;

  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.eventType,
    required this.status,
    required this.petIds,
    this.location,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // ✅ CRITICAL FIX: Always parse as UTC, then convert to local for display
    DateTime parsedDateTime;
    try {
      final dateTimeStr = json['dateTime'] as String;

      // Ensure UTC parsing by adding 'Z' if not present
      String utcDateStr = dateTimeStr;
      if (!utcDateStr.endsWith('Z') && !utcDateStr.contains('+')) {
        utcDateStr = '${utcDateStr}Z';
      }

      // Parse as UTC
      parsedDateTime = DateTime.parse(utcDateStr).toUtc();

      // debugPrint('📅 Parsed dateTime: $dateTimeStr → UTC: $parsedDateTime');
    } catch (e) {
      print('⚠️ Error parsing dateTime: $e, using fallback');
      parsedDateTime = DateTime.now().toUtc();
    }

    // ✅ Handle both pet_ids array and legacy petId
    List<int> petIdsList = [];
    if (json['pet_ids'] != null) {
      petIdsList = (json['pet_ids'] as List<dynamic>)
          .map((e) => e as int)
          .toList();
    } else if (json['petId'] != null) {
      petIdsList = [json['petId'] as int];
    }

    return EventModel(
      id: json['id'] as int,
      title: json['title'] as String,
      dateTime: parsedDateTime, // ✅ Now in UTC
      eventType: EventType.fromString(json['eventType'] as String),
      status: EventStatus.fromString(json['status'] as String),
      petIds: petIdsList,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
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
      'pet_ids': petIds,
      'location': location,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Comparisons should be done in local time or UTC consistently.
  // Since we parsed to UTC, comparisons to DateTime.now() (which is local)
  // need care, or we convert everything to same zone.
  bool get isPast => dateTime.isBefore(DateTime.now().toUtc());

  bool get isToday {
    final now = DateTime.now();
    final localDt = dateTime.toLocal(); // Convert to local for day comparison
    return localDt.year == now.year &&
        localDt.month == now.month &&
        localDt.day == now.day;
  }

  String get displayDate {
    if (isToday) return 'Today';
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final localDt = dateTime.toLocal(); // Convert to local for display

    if (localDt.year == tomorrow.year &&
        localDt.month == tomorrow.month &&
        localDt.day == tomorrow.day) {
      return 'Tomorrow';
    }
    return '${localDt.day} ${_monthName(localDt.month)}';
  }

  String get displayTime {
    final localDt = dateTime.toLocal(); // Convert to local for display
    final hour = localDt.hour.toString().padLeft(2, '0');
    final minute = localDt.minute.toString().padLeft(2, '0');
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

  EventModel copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    EventType? eventType,
    EventStatus? status,
    List<int>? petIds,
    String? location,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
      petIds: petIds ?? this.petIds,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
