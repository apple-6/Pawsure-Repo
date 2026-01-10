import 'package:flutter/foundation.dart';

class ActivityLog {
  final int id;
  final int petId;
  final String activityType;
  final String title;
  final String? description;
  final int durationMinutes;
  final double distanceKm;
  final int caloriesBurned;
  final DateTime activityDate;
  final List<RoutePoint>? routeData;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityLog({
    required this.id,
    required this.petId,
    required this.activityType,
    required this.title,
    this.description,
    required this.durationMinutes,
    required this.distanceKm,
    required this.caloriesBurned,
    required this.activityDate,
    this.routeData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    // 🔧 HELPER: Robust petId extraction
    int extractPetId(Map<String, dynamic> json) {
      if (json['petId'] != null) {
        if (json['petId'] is int) return json['petId'];
        return int.tryParse(json['petId'].toString()) ?? 0;
      }
      if (json['pet_id'] != null) {
        if (json['pet_id'] is int) return json['pet_id'];
        return int.tryParse(json['pet_id'].toString()) ?? 0;
      }
      if (json['pet'] != null && json['pet'] is Map) {
        final petMap = json['pet'] as Map<String, dynamic>;
        return int.tryParse(petMap['id'].toString()) ?? 0;
      }
      return 0;
    }

    return ActivityLog(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      petId: extractPetId(json),
      activityType: json['activity_type'] ?? 'unknown',
      title: json['title'] ?? 'Untitled',
      description: json['description'],
      durationMinutes: json['duration_minutes'] != null
          ? (json['duration_minutes'] is int
                ? json['duration_minutes']
                : int.tryParse(json['duration_minutes'].toString()) ?? 0)
          : 0,
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] is num
                ? (json['distance_km'] as num).toDouble()
                : double.tryParse(json['distance_km'].toString()) ?? 0.0)
          : 0.0,
      caloriesBurned: json['calories_burned'] != null
          ? (json['calories_burned'] is int
                ? json['calories_burned']
                : int.tryParse(json['calories_burned'].toString()) ?? 0)
          : 0,
      activityDate: DateTime.parse(json['activity_date'].toString()),
      routeData: json['route_data'] != null
          ? (json['route_data'] as List)
                .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
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
    return hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
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
        return '📝';
    }
  }
}

class RoutePoint {
  final double lat;
  final double lng;
  final DateTime? timestamp;

  RoutePoint({required this.lat, required this.lng, this.timestamp});

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      lat: (json['lat'] is num)
          ? (json['lat'] as num).toDouble()
          : double.parse(json['lat'].toString()),
      lng: (json['lng'] is num)
          ? (json['lng'] as num).toDouble()
          : double.parse(json['lng'].toString()),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }
}

class ActivityStats {
  final int totalActivities;
  final int totalDuration;
  final double totalDistance;
  final int totalCalories;
  final Map<String, int>? activityBreakdown;

  ActivityStats({
    required this.totalActivities,
    required this.totalDuration,
    required this.totalDistance,
    required this.totalCalories,
    this.activityBreakdown,
  });

  factory ActivityStats.fromJson(Map<String, dynamic> json) {
    return ActivityStats(
      totalActivities: json['totalActivities'] ?? 0,
      totalDuration: json['totalDuration'] ?? 0,
      totalDistance: (json['totalDistance'] ?? 0).toDouble(),
      totalCalories: json['totalCalories'] ?? 0,
      activityBreakdown: json['activityBreakdown'] != null
          ? Map<String, int>.from(json['activityBreakdown'])
          : null,
    );
  }
}

// 🔧 FIX: RESTORED ENUM FOR GPS & MODAL SCREENS
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
