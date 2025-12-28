//Pawsure-Repo\pawsure_app\lib\services\api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/models/event_model.dart'; // 🆕 IMPORT
import 'package:pawsure_app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/constants/api_config.dart';

String get apiBaseUrl => ApiConfig.baseUrl;
// Detect platform and use appropriate localhost address
// 10.0.2.2 is for Android emulator, localhost for Windows/Web/iOS

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

  /// POST /pets - Create a new pet with optional photo upload
  Future<Pet> createPet({
    required String name,
    required String breed,
    String? species,
    String? dob,
    String? photoPath,
  }) async {
    try {
      debugPrint('➕ API: POST $apiBaseUrl/pets');
      debugPrint('📤 Creating pet: $name, breed: $breed');

      final headers = await _getHeaders();
      // Remove Content-Type for multipart - it will be set automatically
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/pets'));

      // Add headers (including auth token)
      request.headers.addAll(headers);

      // Add text fields
      request.fields['name'] = name;
      request.fields['breed'] = breed;
      if (species != null && species.isNotEmpty) {
        request.fields['species'] = species;
      }
      if (dob != null && dob.isNotEmpty) {
        // Convert mm/dd/yyyy to ISO format if needed
        request.fields['dob'] = dob;
      }

      // Add photo file if provided
      if (photoPath != null && photoPath.isNotEmpty) {
        try {
          final photoFile = await http.MultipartFile.fromPath(
            'photo',
            photoPath,
          );
          request.files.add(photoFile);
          debugPrint('📸 Added photo file: $photoPath');
        } catch (e) {
          debugPrint('⚠️ Error adding photo file: $e');
          // Continue without photo
        }
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        final pet = Pet.fromJson(json);

        debugPrint('✅ Pet created successfully: ${pet.name}');
        return pet;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to create pet (${response.statusCode}): ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in createPet: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }


  /// DELETE /pets/:petId - Delete a pet
  Future<void> deletePet(int petId) async {
    try {
      // ⚠️ NOTE: Ensure 'apiBaseUrl' is correctly defined in this file
      debugPrint('🗑️ API: DELETE $apiBaseUrl/pets/$petId');

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/pets/$petId'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      // Assuming your backend returns 200 (OK) or 204 (No Content) on success
      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 401) {
          throw Exception('Authentication failed. Please log in again.');
        }
        throw Exception(
          'Failed to delete pet (${response.statusCode}): ${response.body}',
        );
      }

      debugPrint('✅ Pet deleted successfully from database');
    } catch (e, stackTrace) {
      debugPrint('❌ Error in deletePet: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

// --------------------------------------------------------------------------

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
    } catch (e) {
      rethrow;
    }
  }

  // ========================================================================
  // BOOKINGS API (Sitter)
  // ========================================================================

  /// GET /bookings/sitter - Fetch all bookings for the authenticated sitter
  Future<List<Map<String, dynamic>>> getSitterBookings() async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/bookings/sitter');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/bookings/sitter'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        final bookings = jsonList
            .map((e) => e as Map<String, dynamic>)
            .toList();

        debugPrint('✅ Parsed ${bookings.length} sitter bookings');
        return bookings;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to load sitter bookings (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Error in getSitterBookings: $e');
      rethrow;
    }
  }

  /// PATCH /bookings/:id/status - Update booking status (accept/decline)
  Future<Map<String, dynamic>> updateBookingStatus(int bookingId, String status) async {
    try {
      debugPrint('✏️ API: PATCH $apiBaseUrl/bookings/$bookingId/status');
      debugPrint('📤 Updating status to: $status');

      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/bookings/$bookingId/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ Booking status updated successfully');
        return json;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to update booking status (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Error in updateBookingStatus: $e');
      rethrow;
    }
  }
}
