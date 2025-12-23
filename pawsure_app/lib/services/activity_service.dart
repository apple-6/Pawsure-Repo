// pawsure_app/lib/services/activity_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/models/activity_log_model.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/constants/api_config.dart';

class ActivityService {
  String get apiBaseUrl => ApiConfig.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    try {
      final authService = Get.find<AuthService>();
      final token = await authService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      debugPrint('⚠️ Could not get auth token: $e');
    }

    return headers;
  }

  // Create new activity
  Future<ActivityLog> createActivity(
    int petId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/activity-logs/pets/$petId'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ActivityLog.fromJson(jsonDecode(response.body));
      }

      throw Exception('Failed to create activity: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error creating activity: $e');
      rethrow;
    }
  }

  // Get all activities for a pet
  Future<List<ActivityLog>> getActivities(
    int petId, {
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '$apiBaseUrl/activity-logs/pets/$petId';
      final queryParams = <String, String>{};

      if (type != null) queryParams['type'] = type;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      if (queryParams.isNotEmpty) {
        url +=
            '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => ActivityLog.fromJson(e)).toList();
      }

      throw Exception('Failed to load activities: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error loading activities: $e');
      rethrow;
    }
  }

  // Get activity statistics
  Future<ActivityStats> getStats(int petId, String period) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/activity-logs/pets/$petId/stats?period=$period'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ActivityStats.fromJson(jsonDecode(response.body));
      }

      throw Exception('Failed to load stats: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error loading stats: $e');
      rethrow;
    }
  }

  // Update activity
  Future<ActivityLog> updateActivity(
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$apiBaseUrl/activity-logs/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return ActivityLog.fromJson(jsonDecode(response.body));
      }

      throw Exception('Failed to update activity: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error updating activity: $e');
      rethrow;
    }
  }

  // Delete activity
  Future<void> deleteActivity(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/activity-logs/$id'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete activity: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error deleting activity: $e');
      rethrow;
    }
  }
}
