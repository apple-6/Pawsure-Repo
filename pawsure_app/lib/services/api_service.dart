// Pawsure-Repo\pawsure_app\lib\services\api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Added for MediaType
import 'package:flutter/foundation.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/models/event_model.dart';
import 'package:pawsure_app/models/sitter_model.dart'; // Ensure you have this model or UserProfile
import 'package:pawsure_app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/constants/api_config.dart';

String get apiBaseUrl => ApiConfig.baseUrl;

// Helper function to get file extension (equivalent to Node.js extname)
String extname(String filename) {
  final lastDot = filename.lastIndexOf('.');
  if (lastDot == -1) return '';
  return filename.substring(lastDot);
}

class ApiService {
  final AuthService _authService = AuthService();

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

      final request =
          http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/pets'));

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
      debugPrint('📦 Response Body: ${response.body}');

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

  // ========================================================================
  // EVENTS API
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
      debugPrint('📦 Response Body: ${response.body}');

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
      int userId, Map<String, dynamic> payload) async {
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
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
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
}