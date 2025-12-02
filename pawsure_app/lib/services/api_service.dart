//Pawsure-Repo\pawsure_app\lib\services\api_service.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/models/event_model.dart'; // 🆕 IMPORT
import 'package:pawsure_app/services/auth_service.dart';
import 'package:get/get.dart';

// Detect platform and use appropriate localhost address
// 10.0.2.2 is for Android emulator, localhost for Windows/Web/iOS
String get apiBaseUrl {
  const envUrl = String.fromEnvironment('API_BASE_URL');
  if (envUrl.isNotEmpty) return envUrl;
  
  // Use 10.0.2.2 for Android emulator, localhost for other platforms
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000';
  } else {
    return 'http://localhost:3000';
  }
}

class ApiService {
  // Get authenticated headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

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

  // ========================================================================
  // PETS API
  // ========================================================================

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

  // ========================================================================
  // HEALTH RECORDS API
  // ========================================================================

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
  /// 🔧 FIXED: Corrected the API endpoint
  Future<HealthRecord> updateHealthRecord(
    int recordId,
    Map<String, dynamic> payload,
  ) async {
    try {
      debugPrint('🔄 API: PUT $apiBaseUrl/health-records/$recordId');
      debugPrint('📤 Payload: ${jsonEncode(payload)}');

      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$apiBaseUrl/health-records/$recordId'), // ✅ Correct endpoint
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
  /// 🔧 FIXED: Corrected the API endpoint
  Future<void> deleteHealthRecord(int recordId) async {
    try {
      debugPrint('🗑️ API: DELETE $apiBaseUrl/health-records/$recordId');

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/health-records/$recordId'), // ✅ Correct endpoint
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

  // ========================================================================
  // 🆕 EVENTS API
  // ========================================================================

  /// GET /events?petId=X - Fetch all events for a specific pet
  Future<List<EventModel>> getEvents(int petId) async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/events?petId=$petId');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/events?petId=$petId'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        final events = jsonList
            .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
            .toList();

        debugPrint('✅ Parsed ${events.length} events');
        return events;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to load events (${response.statusCode}): ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getEvents: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// GET /events/upcoming?petId=X&limit=3 - Get upcoming events for dashboard
  Future<List<EventModel>> getUpcomingEvents(int petId, {int limit = 3}) async {
    try {
      debugPrint(
        '🔍 API: GET $apiBaseUrl/events/upcoming?petId=$petId&limit=$limit',
      );

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/events/upcoming?petId=$petId&limit=$limit'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        final events = jsonList
            .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
            .toList();

        debugPrint('✅ Parsed ${events.length} upcoming events');
        return events;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to load upcoming events (${response.statusCode}): ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getUpcomingEvents: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// POST /events - Create a new event
  Future<EventModel> createEvent(Map<String, dynamic> payload) async {
    try {
      debugPrint('➕ API: POST $apiBaseUrl/events');
      debugPrint('📤 Payload: ${jsonEncode(payload)}');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/events'),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        final event = EventModel.fromJson(json);

        debugPrint('✅ Event created successfully');
        return event;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to create event (${response.statusCode}): ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in createEvent: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// PATCH /events/:id - Update event status
  Future<EventModel> updateEventStatus(
    int eventId,
    EventStatus newStatus,
  ) async {
    try {
      debugPrint('🔄 API: PATCH $apiBaseUrl/events/$eventId');
      final payload = {'status': newStatus.toJson()};
      debugPrint('📤 Payload: ${jsonEncode(payload)}');

      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/events/$eventId'),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        return EventModel.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to update event status (${response.statusCode}): ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in updateEventStatus: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// DELETE /events/:id - Delete an event
  Future<void> deleteEvent(int eventId) async {
    try {
      debugPrint('🗑️ API: DELETE $apiBaseUrl/events/$eventId');

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/events/$eventId'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 401) {
          throw Exception('Authentication failed. Please log in again.');
        }
        throw Exception(
          'Failed to delete event (${response.statusCode}): ${response.body}',
        );
      }

      debugPrint('✅ Event deleted successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error in deleteEvent: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
