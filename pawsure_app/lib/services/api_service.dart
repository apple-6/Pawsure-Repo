import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:get/get.dart';

// Use the same base URL pattern as your existing code
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

class ApiService {
  // Get authenticated headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    // Get JWT token from AuthService
    try {
      final authService = Get.find<AuthService>();
      final token = await authService.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint('🔑 Using auth token: ${token.substring(0, 20)}...');
      } else {
        debugPrint('⚠️ No auth token found - API calls may fail');
      }
    } catch (e) {
      debugPrint('⚠️ Could not get auth token: $e');
    }

    return headers;
  }

  /// GET /pets - Fetch all pets for the authenticated user
  Future<List<Pet>> getPets() async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/pets');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/pets'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        final pets = jsonList
            .map((e) => Pet.fromJson(e as Map<String, dynamic>))
            .toList();

        debugPrint('✅ Parsed ${pets.length} pets');
        return pets;
      } else if (response.statusCode == 401) {
        debugPrint('❌ Authentication failed - token may be invalid or expired');
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to load pets (${response.statusCode}): ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getPets: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// GET /pets/:petId/health-records - Fetch health records for a specific pet
  Future<List<HealthRecord>> getHealthRecords(int petId) async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/pets/$petId/health-records');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/pets/$petId/health-records'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        final records = jsonList
            .map((e) => HealthRecord.fromJson(e as Map<String, dynamic>))
            .toList();

        debugPrint('✅ Parsed ${records.length} health records');
        return records;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to load health records (${response.statusCode}): ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getHealthRecords: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// POST /pets/:petId/health-records - Add a new health record
  Future<HealthRecord> addHealthRecord(
    int petId,
    Map<String, dynamic> payload,
  ) async {
    try {
      debugPrint('➕ API: POST $apiBaseUrl/pets/$petId/health-records');
      debugPrint('📤 Payload: ${jsonEncode(payload)}');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/pets/$petId/health-records'),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        final record = HealthRecord.fromJson(json);

        debugPrint('✅ Health record created successfully');
        return record;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to add health record (${response.statusCode}): ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in addHealthRecord: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// PUT /health-records/:recordId - Update an existing health record
  Future<HealthRecord> updateHealthRecord(
    int recordId,
    Map<String, dynamic> payload,
  ) async {
    try {
      debugPrint('🔄 API: PUT $apiBaseUrl/health-records/$recordId');
      debugPrint('📤 Payload: ${jsonEncode(payload)}');

      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$apiBaseUrl/health-records/$recordId'),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        return HealthRecord.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to update health record (${response.statusCode}): ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in updateHealthRecord: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// DELETE /health-records/:recordId - Delete a health record
  Future<void> deleteHealthRecord(int recordId) async {
    try {
      debugPrint('🗑️ API: DELETE $apiBaseUrl/health-records/$recordId');

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/health-records/$recordId'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 401) {
          throw Exception('Authentication failed. Please log in again.');
        }
        throw Exception(
          'Failed to delete health record (${response.statusCode}): ${response.body}',
        );
      }

      debugPrint('✅ Health record deleted successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error in deleteHealthRecord: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
