class ActivityLog {
  final int id;
  final int petId;
  final String activityType;
  final String? title;
  final String? description;
  final int durationMinutes;
  final double? distanceKm;
  final int? caloriesBurned;
  final DateTime activityDate;
  final List<RoutePoint>? routeData;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityLog({
    required this.id,
    required this.petId,
    required this.activityType,
    this.title,
    this.description,
    required this.durationMinutes,
    this.distanceKm,
    this.caloriesBurned,
    required this.activityDate,
    this.routeData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    // 🔧 FIX: Robust pet_id extraction
    int extractPetId(Map<String, dynamic> json) {
      // Try direct pet_id field
      if (json['pet_id'] != null) {
        if (json['pet_id'] is int) return json['pet_id'] as int;
        if (json['pet_id'] is String)
          return int.tryParse(json['pet_id'] as String) ?? 0;
      }

      // Try nested pet object
      if (json['pet'] != null && json['pet'] is Map) {
        final petMap = json['pet'] as Map<String, dynamic>;
        if (petMap['id'] != null) {
          if (petMap['id'] is int) return petMap['id'] as int;
          if (petMap['id'] is String)
            return int.tryParse(petMap['id'] as String) ?? 0;
        }
      }

      return 0; // Fallback
    }

    return ActivityLog(
      id: json['id'] as int,
      petId: extractPetId(json),
      activityType: json['activity_type'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      caloriesBurned: json['calories_burned'] as int?,
      activityDate: DateTime.parse(json['activity_date'] as String),
      routeData: json['route_data'] != null
          ? (json['route_data'] as List)
                .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_type': activityType,
      'title': title,
      'description': description,
      'duration_minutes': durationMinutes,
      'distance_km': distanceKm,
      'calories_burned': caloriesBurned,
      'activity_date': activityDate.toIso8601String(),
      'route_data': routeData?.map((e) => e.toJson()).toList(),
    };
  }

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  String get activityIcon {
    switch (activityType.toLowerCase()) {
      case 'walk':
        return '🚶';
      case 'run':
        return '🏃';
      case 'play':
        return '🎾';
      case 'swim':
        return '🏊';
      case 'training':
        return '🎓';
      default:
        return '🐾';
    }
  }
}

class RoutePoint {
  final double lat;
  final double lng;
  final DateTime timestamp;

  RoutePoint({required this.lat, required this.lng, required this.timestamp});

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng, 'timestamp': timestamp.toIso8601String()};
  }
}

enum ActivityType {
  walk,
  run,
  play,
  swim,
  training,
  other;

  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }
}

class ActivityStats {
  final String period;
  final int totalActivities;
  final int totalDuration;
  final double totalDistance;
  final int totalCalories;
  final Map<String, int> byType;

  ActivityStats({
    required this.period,
    required this.totalActivities,
    required this.totalDuration,
    required this.totalDistance,
    required this.totalCalories,
    required this.byType,
  });

  factory ActivityStats.fromJson(Map<String, dynamic> json) {
    return ActivityStats(
      period: json['period'] as String,
      totalActivities: json['totalActivities'] as int,
      totalDuration: json['totalDuration'] as int,
      totalDistance: (json['totalDistance'] as num).toDouble(),
      totalCalories: json['totalCalories'] as int,
      byType: Map<String, int>.from(json['byType'] as Map),
    );
  }
}
