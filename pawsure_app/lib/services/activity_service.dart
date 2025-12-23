import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/models/activity_model.dart';
import 'package:pawsure_app/constants/api_endpoints.dart';

class ActivityService {
  Future<List<ActivityModel>> getActivitiesByPet(String petId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiEndpoints.baseUrl}${ApiEndpoints.activitiesByPet(petId)}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((activity) =>
                ActivityModel.fromJson(activity as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load activities (${response.statusCode})');
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      rethrow;
    }
  }

  Future<ActivityModel> addActivity({
    required String petId,
    required String activityType,
    required String title,
    required String description,
    required DateTime activityDate,
    required int durationMinutes,
    double? distanceKm,
    int? caloriesBurned,
  }) async {
    try {
      final payload = {
        'petId': petId,
        'activityType': activityType,
        'title': title,
        'description': description,
        'activityDate': activityDate.toIso8601String(),
        'durationMinutes': durationMinutes,
        'distanceKm': distanceKm,
        'caloriesBurned': caloriesBurned,
      };

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.addActivity}'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ActivityModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw Exception('Failed to add activity (${response.statusCode})');
    } catch (e) {
      debugPrint('Error adding activity: $e');
      rethrow;
    }
  }
}
