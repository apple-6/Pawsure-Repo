// lib/models/activity_log_model.dart
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
    return ActivityLog(
      id: json['id'] as int,
      // FIX: Handle both direct pet_id and nested pet object
      petId:
          json['pet_id'] as int? ??
          (json['pet'] != null ? (json['pet']['id'] as int?) : null) ??
          0, // Fallback to 0 if both are null
      activityType: json['activity_type'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int,
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
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
