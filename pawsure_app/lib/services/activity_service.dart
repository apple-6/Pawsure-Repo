import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/models/activity_log_model.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:pawsure_app/constants/api_config.dart';
import 'package:get/get.dart';

String get apiBaseUrl => ApiConfig.baseUrl;

class ActivityService {
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    try {
      final authService = Get.find<AuthService>();
      final token = await authService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        debugPrint('⚠️ ActivityService: No auth token');
      }
    } catch (e) {
      debugPrint('❌ ActivityService: Auth token error: $e');
    }
    return headers;
  }

  Future<List<ActivityLog>> getActivities(
    int petId, {
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🌐 ActivityService.getActivities(petId: $petId)');

      final headers = await _getHeaders();
      var url = '$apiBaseUrl/activity-logs/pets/$petId';
      final queryParams = <String, String>{};

      if (type != null) queryParams['type'] = type;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      if (queryParams.isNotEmpty) {
        url +=
            '?' +
            queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      debugPrint('📡 Request: $url');
      final response = await http.get(Uri.parse(url), headers: headers);
      debugPrint('📦 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        if (jsonList.isEmpty) return [];

        final activities = <ActivityLog>[];
        for (int i = 0; i < jsonList.length; i++) {
          try {
            activities.add(ActivityLog.fromJson(jsonList[i]));
          } catch (itemError) {
            debugPrint('⚠️ Skipping invalid activity at index $i: $itemError');
          }
        }
        debugPrint('✅ Parsed ${activities.length} valid activities');
        return activities;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      }

      throw Exception('Failed to load activities: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error in getActivities: $e');
      rethrow;
    }
  }

  Future<ActivityStats> getStats(int petId, String period) async {
    final headers = await _getHeaders();
    final url = '$apiBaseUrl/activity-logs/pets/$petId/stats?period=$period';
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return ActivityStats.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load stats');
  }

  // ✅ UPDATED: Supports multiple pets and returns a List
  Future<List<ActivityLog>> createActivity(
    List<int> petIds, // Accepts list of IDs
    Map<String, dynamic> payload,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/activity-logs'), // Generic endpoint
      headers: headers,
      body: jsonEncode({
        ...payload,
        'pet_ids': petIds, // Payload includes pet_ids array
      }),
    );

    if (response.statusCode == 201) {
      final List data = jsonDecode(response.body);
      return data.map((json) => ActivityLog.fromJson(json)).toList();
    }
    throw Exception('Failed to create activity');
  }

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

  Future<void> deleteActivity(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$apiBaseUrl/activity-logs/$id'),
      headers: headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete failed: ${response.statusCode}');
    }
  }
}
