// Pawsure-Repo\pawsure_app\lib\services\api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Added for MediaType
import 'package:flutter/foundation.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/models/event_model.dart';
import 'package:pawsure_app/models/sitter_model.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/constants/api_config.dart';
import 'package:pawsure_app/models/comment_model.dart';

String get apiBaseUrl => ApiConfig.baseUrl;

// Helper function to get file extension (equivalent to Node.js extname)
String extname(String filename) {
  final lastDot = filename.lastIndexOf('.');
  if (lastDot == -1) return '';
  return filename.substring(lastDot);
}

class ApiService {
  // ✅ FIX: Use GetX singleton instead of creating new instance
  AuthService get _authService => Get.find<AuthService>();

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    try {
      final token = await _authService.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        // debugPrint('🔑 Using auth token: ${token.substring(0, 20)}...');
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
    double? weight,
    String? sterilizationStatus,
    String? allergies,
    double? moodRating,
    String? lastVetVisit,
  }) async {
    try {
      debugPrint('➕ API: POST $apiBaseUrl/pets');
      debugPrint('📤 Creating pet: $name, breed: $breed');

      final headers = await _getHeaders();
      // Remove Content-Type for multipart - it will be set automatically
      headers.remove('Content-Type');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/pets'),
      );

      // Add headers (including auth token)
      request.headers.addAll(headers);

      // Add text fields
      request.fields['name'] = name;
      request.fields['breed'] = breed;
      if (species != null && species.isNotEmpty) {
        request.fields['species'] = species;
      }
      if (dob != null && dob.isNotEmpty) {
        request.fields['dob'] = dob;
      }
      if (weight != null) {
        request.fields['weight'] = weight.toString();
      }
      if (sterilizationStatus != null && sterilizationStatus.isNotEmpty) {
        request.fields['sterilization_status'] = sterilizationStatus;
      }
      if (allergies != null && allergies.isNotEmpty) {
        request.fields['allergies'] = allergies;
      }
      if (moodRating != null) {
        request.fields['mood_rating'] = moodRating.toString();
      }
      if (lastVetVisit != null && lastVetVisit.isNotEmpty) {
        request.fields['last_vet_visit'] = lastVetVisit;
      }

      // Add photo file if provided
      if (photoPath != null && photoPath.isNotEmpty) {
        try {
          // 🔧 FIX: Generate a clean, unique filename to prevent 'undefined' URLs
          final String fileName =
              'pet_${DateTime.now().millisecondsSinceEpoch}.jpg';

          final photoFile = await http.MultipartFile.fromPath(
            'photo',
            photoPath,
            filename: fileName,
          );
          request.files.add(photoFile);
          debugPrint('📸 Added photo file: $photoPath as $fileName');
        } catch (e) {
          debugPrint('⚠️ Error adding photo file: $e');
        }
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📦 API Response: ${response.statusCode}');

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

  /// PUT /pets/:id - Update an existing pet
  Future<Pet> updatePet({
    required int petId,
    String? name,
    String? breed,
    String? species,
    String? dob,
    String? photoPath,
    double? weight,
    double? height,
    int? bodyConditionScore,
    List<Map<String, dynamic>>? weightHistory,
    String? sterilizationStatus,
    String? allergies,
    String? foodBrand,
    String? dailyFoodAmount,
    double? moodRating,
    String? lastVetVisit,
  }) async {
    try {
      debugPrint('✏️ API: PUT $apiBaseUrl/pets/$petId');
      debugPrint('📤 Updating pet: $name');

      final headers = await _getHeaders();
      headers.remove('Content-Type');

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$apiBaseUrl/pets/$petId'),
      );
      request.headers.addAll(headers);

      // Add fields only if they're not null
      if (name != null && name.isNotEmpty) {
        request.fields['name'] = name;
      }
      if (breed != null && breed.isNotEmpty) {
        request.fields['breed'] = breed;
      }
      if (species != null && species.isNotEmpty) {
        request.fields['species'] = species;
      }
      if (dob != null && dob.isNotEmpty) {
        request.fields['dob'] = dob;
      }
      if (weight != null) {
        request.fields['weight'] = weight.toString();
      }
      if (height != null) {
        request.fields['height'] = height.toString();
      }
      if (bodyConditionScore != null) {
        request.fields['body_condition_score'] = bodyConditionScore.toString();
      }
      if (weightHistory != null) {
        request.fields['weight_history'] = jsonEncode(weightHistory);
      }
      if (sterilizationStatus != null && sterilizationStatus.isNotEmpty) {
        request.fields['sterilization_status'] = sterilizationStatus;
      }
      if (allergies != null && allergies.isNotEmpty) {
        request.fields['allergies'] = allergies;
      }
      if (foodBrand != null && foodBrand.isNotEmpty) {
        request.fields['food_brand'] = foodBrand;
      }
      if (dailyFoodAmount != null && dailyFoodAmount.isNotEmpty) {
        request.fields['daily_food_amount'] = dailyFoodAmount;
      }
      if (moodRating != null) {
        request.fields['mood_rating'] = moodRating.toString();
      }
      if (lastVetVisit != null && lastVetVisit.isNotEmpty) {
        request.fields['last_vet_visit'] = lastVetVisit;
      }

      if (sterilizationStatus != null && sterilizationStatus.isNotEmpty) {
        request.fields['sterilization_status'] = sterilizationStatus;
        debugPrint(
          '✅ Added sterilization_status to request: $sterilizationStatus',
        );
      } else {
        debugPrint(
          '⚠️ sterilizationStatus is null or empty: $sterilizationStatus',
        );
      }

      // Add new photo if provided
      if (photoPath != null && photoPath.isNotEmpty) {
        try {
          // 🔧 FIX: Generate a clean, unique filename
          final String fileName =
              'pet_update_${DateTime.now().millisecondsSinceEpoch}.jpg';

          final photoFile = await http.MultipartFile.fromPath(
            'photo',
            photoPath,
            filename: fileName,
          );
          request.files.add(photoFile);
          debugPrint('📸 Updating photo: $photoPath as $fileName');
        } catch (e) {
          debugPrint('⚠️ Error adding photo file: $e');
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        final pet = Pet.fromJson(json);

        debugPrint('✅ Pet updated successfully: ${pet.name}');
        return pet;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to update pet (${response.statusCode}): ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in updatePet: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// DELETE /pets/:petId - Delete a pet
  Future<void> deletePet(int petId) async {
    try {
      debugPrint('🗑️ API: DELETE $apiBaseUrl/pets/$petId');

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/pets/$petId'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

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

  // ========================================================================
  // EVENTS API
  // ========================================================================

  // ✅ NEW: Fetch ALL owner events (multi-pet)
  Future<List<EventModel>> getAllOwnerEvents() async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/events/owner/all');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/events/owner/all'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        return jsonList.map((e) => EventModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load owner events: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error in getAllOwnerEvents: $e');
      return [];
    }
  }

  // ✅ NEW: Fetch upcoming events for dashboard (owner view)
  Future<List<EventModel>> getAllOwnerUpcomingEvents({int limit = 3}) async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/events/owner/upcoming?limit=$limit');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/events/owner/upcoming?limit=$limit'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        return jsonList.map((e) => EventModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load upcoming events: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error in getAllOwnerUpcomingEvents: $e');
      return [];
    }
  }

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
  // ✅ UPDATED: Handles both single object and List response (multi-pet)
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        // ✅ Handle array response if multiple pets were selected
        if (data is List) {
          if (data.isNotEmpty) {
            // Return the first event created (sufficient for UI feedback)
            return EventModel.fromJson(data.first as Map<String, dynamic>);
          } else {
            throw Exception('Created event list was empty');
          }
        } else {
          // Handle single object response
          return EventModel.fromJson(data as Map<String, dynamic>);
        }
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
    } catch (e, stackTrace) {
      debugPrint('❌ Error in deleteEvent: $e');
      debugPrint('Stack trace: $stackTrace');
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

  /// GET /bookings/owner - Fetch all bookings for the authenticated owner
  Future<List<Map<String, dynamic>>> getOwnerBookings() async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/bookings/owner');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/bookings/owner'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        final bookings = jsonList
            .map((e) => e as Map<String, dynamic>)
            .toList();

        debugPrint('✅ Parsed ${bookings.length} owner bookings');
        return bookings;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to load owner bookings (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Error in getOwnerBookings: $e');
      rethrow;
    }
  }

  /// PATCH /bookings/:id/status - Update booking status (accept/decline)
  Future<Map<String, dynamic>> updateBookingStatus(
    int bookingId,
    String status,
  ) async {
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

  /// PATCH /bookings/:id/complete - Mark service as completed (Sitter)
  Future<Map<String, dynamic>> completeService(int bookingId) async {
    try {
      debugPrint('✅ API: PATCH $apiBaseUrl/bookings/$bookingId/complete');

      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/bookings/$bookingId/complete'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ Service marked as completed');
        return json;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to complete service (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Error in completeService: $e');
      rethrow;
    }
  }

  /// POST /bookings/:id/pay - Process payment (Owner)
  Future<Map<String, dynamic>> processPayment(int bookingId) async {
    try {
      debugPrint('💳 API: POST $apiBaseUrl/bookings/$bookingId/pay');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/bookings/$bookingId/pay'),
        headers: headers,
        body: jsonEncode({}),
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ Payment processed successfully');
        return json;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to process payment (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Error in processPayment: $e');
      rethrow;
    }
  }

  /// GET /bookings - Get user's bookings (to check for unpaid ones)
  Future<List<Map<String, dynamic>>> getMyBookings() async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/bookings');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/bookings'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        final bookings = jsonList
            .map((e) => e as Map<String, dynamic>)
            .toList();

        debugPrint('✅ Parsed ${bookings.length} bookings');
        return bookings;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to load bookings (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Error in getMyBookings: $e');
      rethrow;
    }
  }

  // ========================================================================
  // POSTS/COMMUNITY API
  // ========================================================================

  /// GET /posts - Fetch all posts (optionally filtered by tab)
  Future<List<dynamic>> getPosts({String tab = 'all'}) async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/posts?tab=$tab');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/posts?tab=$tab'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> posts = jsonDecode(response.body) as List<dynamic>;
        debugPrint('✅ Loaded ${posts.length} posts');
        return posts;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to load posts (${response.statusCode}): ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getPosts: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// POST /posts - Create a new post with media files
  Future<void> createPost({
    required String content,
    bool isUrgent = false,
    List<String>? mediaPaths,
  }) async {
    try {
      debugPrint('➕ API: POST $apiBaseUrl/posts');
      debugPrint('📤 Creating post: $content, urgent: $isUrgent');

      // Get headers WITHOUT Content-Type (multipart will set it)
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/posts'),
      );

      // Add all headers including Authorization
      request.headers.addAll(headers);

      // Add form fields - match your NestJS backend field names EXACTLY
      request.fields['content'] = content.trim();
      request.fields['is_urgent'] = isUrgent.toString();

      // Add media files if provided
      if (mediaPaths != null && mediaPaths.isNotEmpty) {
        for (int i = 0; i < mediaPaths.length; i++) {
          final path = mediaPaths[i];
          try {
            // Generate clean filename
            final fileName =
                'post_${DateTime.now().millisecondsSinceEpoch}_$i${extname(path)}';

            // ✅ FIXED: Explicitly set the MIME type based on file extension
            String mimeType = 'application/octet-stream'; // Default
            final ext = extname(path).toLowerCase();

            if (['.jpg', '.jpeg'].contains(ext)) {
              mimeType = 'image/jpeg';
            } else if (ext == '.png') {
              mimeType = 'image/png';
            } else if (ext == '.gif') {
              mimeType = 'image/gif';
            } else if (ext == '.webp') {
              mimeType = 'image/webp';
            } else if (ext == '.mp4') {
              mimeType = 'video/mp4';
            } else if (ext == '.mov') {
              mimeType = 'video/quicktime';
            } else if (ext == '.avi') {
              mimeType = 'video/x-msvideo';
            }

            debugPrint('📸 File MIME type detected: $mimeType for $fileName');

            final file = await http.MultipartFile.fromPath(
              'media', // MUST match FilesInterceptor('media') in NestJS
              path,
              filename: fileName,
              contentType: MediaType(
                'image',
                mimeType.split('/')[1],
              ), // ✅ Explicitly set MIME type
            );
            request.files.add(file);
            debugPrint('📸 Added media file: $path as $fileName');
          } catch (e) {
            debugPrint('⚠️ Error adding media file $i: $e');
          }
        }
      }

      // Log request details for debugging
      debugPrint('📋 Request headers: ${request.headers}');
      debugPrint('📋 Request fields: ${request.fields}');
      debugPrint('📋 Request files count: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('✅ Post created successfully!');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        throw Exception(
          'Failed to create post (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in createPost: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ========================================================================
  // CHAT API
  // ========================================================================

  Future<List<dynamic>> getChatHistory(String room) async {
    final token = await _authService.getToken();

    // Matches NestJS @Get('chat/:room')
    final url = Uri.parse('${ApiConfig.baseUrl}/chat/$room');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load chat history');
    }
  }

  // ========================================================================
  // SITTER PROFILE API
  // ========================================================================

  /// PATCH /sitters/user/:userId - Update sitter profile by USER ID
  Future<UserProfile> updateSitterProfile(
    int userId,
    Map<String, dynamic> payload,
  ) async {
    try {
      // ✅ Calls the new endpoint: /sitters/user/23
      debugPrint('🔄 API: PATCH $apiBaseUrl/sitters/user/$userId');

      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/sitters/user/$userId'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        // Assuming UserProfile is the correct return type model
        return UserProfile.fromJson(json);
      } else {
        throw Exception('Failed to update: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      rethrow;
    }
  }

  // ========================================================================
  // PAYMENT METHODS API
  // ========================================================================

  /// GET /payment-methods - Get all payment methods for authenticated user
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/payment-methods');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/payment-methods'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        return jsonList.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to load payment methods (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Error in getPaymentMethods: $e');
      rethrow;
    }
  }

  /// POST /payment-methods - Add a new payment method
  Future<Map<String, dynamic>> addPaymentMethod({
    required String cardType,
    required String lastFourDigits,
    required String cardholderName,
    required String expiryMonth,
    required String expiryYear,
    bool isDefault = false,
    String? nickname,
  }) async {
    try {
      debugPrint('➕ API: POST $apiBaseUrl/payment-methods');

      final headers = await _getHeaders();
      final body = {
        'cardType': cardType,
        'lastFourDigits': lastFourDigits,
        'cardholderName': cardholderName,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'isDefault': isDefault,
        if (nickname != null) 'nickname': nickname,
      };

      final response = await http.post(
        Uri.parse('$apiBaseUrl/payment-methods'),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ Payment method added successfully');
        return json;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to add payment method (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Error in addPaymentMethod: $e');
      rethrow;
    }
  }

  /// PATCH /payment-methods/:id/default - Set as default payment method
  Future<Map<String, dynamic>> setDefaultPaymentMethod(int methodId) async {
    try {
      debugPrint('✏️ API: PATCH $apiBaseUrl/payment-methods/$methodId/default');

      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/payment-methods/$methodId/default'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ Default payment method updated');
        return json;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to set default payment method (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Error in setDefaultPaymentMethod: $e');
      rethrow;
    }
  }

  /// DELETE /payment-methods/:id - Delete a payment method
  Future<void> deletePaymentMethod(int methodId) async {
    try {
      debugPrint('🗑️ API: DELETE $apiBaseUrl/payment-methods/$methodId');

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/payment-methods/$methodId'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Payment method deleted successfully');
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to delete payment method (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Error in deletePaymentMethod: $e');
      rethrow;
    }
  }

  // ========================================================================
  // LIKES API
  // ========================================================================

  /// POST /likes/:postId - Toggle like status
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    try {
      debugPrint('👍 API: POST $apiBaseUrl/likes/$postId');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/likes/$postId'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(
          response.body,
        ); // Returns { isLiked: bool, likesCount: int }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed');
      }

      throw Exception('Failed to toggle like');
    } catch (e) {
      debugPrint('❌ Error toggling like: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _flattenCommentData(
    Map<String, dynamic> json,
    String postId,
  ) {
    final user = json['user'] ?? {};

    // Check if 'post' is an object or just an ID
    String responsePostId = postId;
    if (json['post'] != null && json['post'] is Map) {
      responsePostId = json['post']['id'].toString();
    }

    return {
      'id': json['id'].toString(),
      'postId': responsePostId,
      'userId': (user['id'] ?? '').toString(),
      'userName': user['name'] ?? 'Unknown',
      'content': json['content'] ?? '',
      'likesCount': json['likesCount'] ?? 0,
      'createdAt':
          json['created_at'] ??
          json['createdAt'] ??
          DateTime.now().toIso8601String(),
      'updatedAt':
          json['updated_at'] ??
          json['updatedAt'] ??
          DateTime.now().toIso8601String(),
    };
  }

  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final headers = await _getHeaders();
      // 🆕 UPDATED: Added print to verify the exact URL being called
      debugPrint('🔍 API: GET $apiBaseUrl/comments/post/$postId');

      final response = await http.get(
        Uri.parse('$apiBaseUrl/comments/post/$postId'),
        headers: headers,
      );

      // 🆕 UPDATED: Print status code and body to debug the error
      debugPrint('📦 API Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((json) {
          final flatData = _flattenCommentData(json, postId);
          return CommentModel.fromJson(flatData);
        }).toList();
      } else {
        // 🆕 UPDATED: Print the actual server error message before throwing
        debugPrint('❌ Server Error Body: ${response.body}');
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching comments: $e");
      return [];
    }
  }

  Future<CommentModel> addComment(String postId, String content) async {
    try {
      final headers = await _getHeaders();
      // 🆕 UPDATED: Log the payload being sent
      debugPrint(
        '➕ API: POST $apiBaseUrl/comments/post/$postId with content: $content',
      );

      final response = await http.post(
        Uri.parse('$apiBaseUrl/comments/post/$postId'),
        headers: headers,
        body: jsonEncode({'content': content}),
      );

      // 🆕 UPDATED: Print status code and body
      debugPrint('📦 API Response Code: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final flatData = _flattenCommentData(json, postId);
        return CommentModel.fromJson(flatData);
      } else {
        // 🆕 UPDATED: Print the actual server error message before throwing
        debugPrint('❌ Server Error Body: ${response.body}');
        throw Exception('Failed to post comment: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error posting comment: $e");
      rethrow;
    }
  }

  // ========================================================================
  // MOOD & STREAK API
  // ========================================================================

  /// POST /pets/:petId/mood - Log a mood for the pet
  Future<Map<String, dynamic>> logMood({
    required int petId,
    required int moodScore,
    String? moodLabel,
    String? notes,
  }) async {
    try {
      debugPrint('😊 API: POST $apiBaseUrl/pets/$petId/mood');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/pets/$petId/mood'),
        headers: headers,
        body: jsonEncode({
          'mood_score': moodScore,
          if (moodLabel != null) 'mood_label': moodLabel,
          if (notes != null) 'notes': notes,
        }),
      );

      debugPrint('📦 API Response: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ Mood logged! Streak: ${data['streak']}');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to log mood (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Error in logMood: $e');
      rethrow;
    }
  }

  /// GET /pets/:petId/mood/today - Get today's mood
  Future<Map<String, dynamic>?> getTodayMood(int petId) async {
    try {
      debugPrint('📅 API: GET $apiBaseUrl/pets/$petId/mood/today');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/pets/$petId/mood/today'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['logged'] == true) {
          return data['mood'] as Map<String, dynamic>?;
        }
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error in getTodayMood: $e');
      return null;
    }
  }

  /// GET /pets/:petId/mood/history?days=30 - Get mood history
  Future<List<Map<String, dynamic>>> getMoodHistory(
    int petId, {
    int days = 30,
  }) async {
    try {
      debugPrint('📊 API: GET $apiBaseUrl/pets/$petId/mood/history?days=$days');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/pets/$petId/mood/history?days=$days'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final history = data['history'] as List<dynamic>;
        return history.map((e) => e as Map<String, dynamic>).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error in getMoodHistory: $e');
      return [];
    }
  }

  /// GET /pets/:petId/mood/streak - Get streak information
  Future<Map<String, dynamic>> getStreakInfo(int petId) async {
    try {
      debugPrint('🔥 API: GET $apiBaseUrl/pets/$petId/mood/streak');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/pets/$petId/mood/streak'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      return {
        'currentStreak': 0,
        'totalDaysLogged': 0,
        'lastActivityDate': null,
      };
    } catch (e) {
      debugPrint('❌ Error in getStreakInfo: $e');
      return {
        'currentStreak': 0,
        'totalDaysLogged': 0,
        'lastActivityDate': null,
      };
    }
  }

  // ========================================================================
  // MEAL LOGS API
  // ========================================================================

  /// POST /pets/:petId/meals - Log a meal for the pet
  Future<Map<String, dynamic>> logMeal({
    required int petId,
    required String mealType,
  }) async {
    try {
      debugPrint('🍲 API: POST $apiBaseUrl/pets/$petId/meals');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/pets/$petId/meals'),
        headers: headers,
        body: jsonEncode({
          'meal_type': mealType,
        }),
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to log meal (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('❌ Error in logMeal: $e');
      rethrow;
    }
  }

  /// GET /pets/:petId/meals/today - Get today's meals
  Future<List<String>> getTodayMeals(int petId) async {
    try {
      debugPrint('📅 API: GET $apiBaseUrl/pets/$petId/meals/today');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/pets/$petId/meals/today'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e['meal_type'] as String).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error in getTodayMeals: $e');
      return [];
    }
  }

  Future<void> createReview({
    required int bookingId,
    required double rating,
    required String comment,
  }) async {
    try {
      debugPrint('⭐ API: POST $apiBaseUrl/reviews');

      final headers = await _getHeaders(); // Uses your existing helper
      final response = await http.post(
        Uri.parse('$apiBaseUrl/reviews'),
        headers: headers,
        body: jsonEncode({
          'bookingId': bookingId,
          'rating': rating,
          'comment': comment,
        }),
      );

      debugPrint('📦 API Response: ${response.statusCode}');

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to submit review: ${response.body}');
    }
  } catch (e) {
    debugPrint('❌ Error submitting review: $e');
    rethrow;
  }
}

// ========================================================================
  // SITTER PROFILE API (Current User)
  // ========================================================================

  /// GET /sitters/my-profile - Fetch the logged-in user's sitter profile
  /// This replaces the crashing '/sitters/me' call
  Future<UserProfile?> getMySitterProfile() async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/sitters/my-profile');
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$apiBaseUrl/sitters/my-profile'),
        headers: headers,
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 404) {
        // Profile not found - User needs to register as sitter
        return null;
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error in getMySitterProfile: $e');
      return null;
    }
  }

// ========================================================================
  // SITTER CHECK & REGISTRATION API (Added for Switch Mode)
  // ========================================================================

  /// GET /sitters/user/:userId - Check if sitter profile exists
  /// Returns UserProfile if found (Scenario A), returns null if 404 (Scenario B).
  Future<UserProfile?> getSitterByUserId(int userId) async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/sitters/user/$userId');
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$apiBaseUrl/sitters/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // ✅ Profile exists!
        return UserProfile.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        // ⚠️ Profile does not exist (User is not a sitter yet)
        return null; 
      } else {
        // Other errors (500, etc)
        debugPrint('⚠️ Unexpected status checking sitter: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('⚠️ Error checking sitter status: $e');
      return null;
    }
  }

  /// POST /sitters - Create a new sitter profile
  Future<void> createSitterProfile(Map<String, dynamic> payload) async {
    try {
      debugPrint('➕ API: POST $apiBaseUrl/sitters');
      debugPrint('📤 Payload: ${jsonEncode(payload)}');
      
      final headers = await _getHeaders();
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/sitters'),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('✅ Sitter profile created successfully');
      } else {
        throw Exception('Failed to register as sitter: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error in createSitterProfile: $e');
      rethrow;
    }
  }
}
