// pawsure_app\lib\models\activity_log_model.dart
import 'package:flutter/foundation.dart'; // 👈 FIX 1: Needed for debugPrint

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
    // 🔧 HELPER 1: Robust petId extraction (Updated per Fix 2)
    int extractPetId(Map<String, dynamic> json) {
      // Try camelCase petId (Backend standard)
      if (json['petId'] != null) {
        if (json['petId'] is int) return json['petId'] as int;
        if (json['petId'] is String) {
          final parsed = int.tryParse(json['petId'] as String);
          if (parsed != null && parsed > 0) return parsed;
        }
      }

      // Try snake_case pet_id (Fallback)
      if (json['pet_id'] != null) {
        if (json['pet_id'] is int) return json['pet_id'] as int;
        if (json['pet_id'] is String) {
          final parsed = int.tryParse(json['pet_id'] as String);
          if (parsed != null && parsed > 0) return parsed;
        }
      }

      // Try nested pet object
      if (json['pet'] != null && json['pet'] is Map) {
        final petMap = json['pet'] as Map<String, dynamic>;
        if (petMap['id'] != null) {
          final parsed = int.tryParse(petMap['id'].toString());
          if (parsed != null && parsed > 0) return parsed;
        }
      }

      // 🔧 FIX: Throw error instead of returning 0
      throw FormatException('Could not extract valid petId from JSON: $json');
    }

    // 🔧 HELPER 2: Safe Double Parsing (Fixes "0.00" String crash)
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return ActivityLog(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      petId: extractPetId(json),
      activityType: json['activity_type'] ?? 'unknown',
      title: json['title'] as String?,
      description: json['description'] as String?,
      durationMinutes: (json['duration_minutes'] is int)
          ? json['duration_minutes']
          : int.tryParse(json['duration_minutes'].toString()) ?? 0,
      // 🔧 FIX 2: Use helper to handle String "0.00"
      distanceKm: parseDouble(json['distance_km']),
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
