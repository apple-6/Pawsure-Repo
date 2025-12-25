//Pawsure-Repo\pawsure_app\lib\services\api_service.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/models/event_model.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/constants/api_config.dart';
import 'package:path/path.dart' show extension;

String get apiBaseUrl => ApiConfig.baseUrl;

// Helper function to get file extension (equivalent to Node.js extname)
String extname(String filename) {
  final lastDot = filename.lastIndexOf('.');
  if (lastDot == -1) return '';
  return filename.substring(lastDot);
}

class ApiService {
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
      headers.remove('Content-Type');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/pets'),
      );
      request.headers.addAll(headers);

      // Required fields
      request.fields['name'] = name;
      request.fields['breed'] = breed;

      // Optional fields
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
            filename: fileName, // Add this line
          );
          request.files.add(photoFile);
          debugPrint('📸 Added photo file: $photoPath as $fileName');
        } catch (e) {
          debugPrint('⚠️ Error adding photo file: $e');
        }
      }

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

  /// 🆕 PUT /pets/:id - Update an existing pet
  Future<Pet> updatePet({
    required int petId,
    String? name,
    String? breed,
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

      // Add new photo if provided
      // Add new photo if provided
      if (photoPath != null && photoPath.isNotEmpty) {
        try {
          // 🔧 FIX: Generate a clean, unique filename
          final String fileName =
              'pet_update_${DateTime.now().millisecondsSinceEpoch}.jpg';

          final photoFile = await http.MultipartFile.fromPath(
            'photo',
            photoPath,
            filename: fileName, // Add this line
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
  // HEALTH RECORDS API (keeping existing code)
  // ========================================================================

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
      rethrow;
    }
  }

  Future<HealthRecord> addHealthRecord(
    int petId,
    Map<String, dynamic> payload,
  ) async {
    try {
      debugPrint('➕ API: POST $apiBaseUrl/pets/$petId/health-records');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/pets/$petId/health-records'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        return HealthRecord.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to add health record (${response.statusCode}): ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in addHealthRecord: $e');
      rethrow;
    }
  }

  Future<HealthRecord> updateHealthRecord(
    int recordId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$apiBaseUrl/health-records/$recordId'),
        headers: headers,
        body: jsonEncode(payload),
      );

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
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHealthRecord(int recordId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/health-records/$recordId'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 401) {
          throw Exception('Authentication failed. Please log in again.');
        }
        throw Exception(
          'Failed to delete health record (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // ========================================================================
  // EVENTS API (keeping existing code)
  // ========================================================================

  Future<List<EventModel>> getEvents(int petId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/events?petId=$petId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to load events (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventModel>> getUpcomingEvents(int petId, {int limit = 3}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/events/upcoming?petId=$petId&limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to load upcoming events (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<EventModel> createEvent(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/events'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        return EventModel.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception(
        'Failed to create event (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<EventModel> updateEventStatus(
    int eventId,
    EventStatus newStatus,
  ) async {
    try {
      final headers = await _getHeaders();
      final payload = {'status': newStatus.toJson()};
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/events/$eventId'),
        headers: headers,
        body: jsonEncode(payload),
      );

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
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(int eventId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/events/$eventId'),
        headers: headers,
      );

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

  /// GET /community - Fetch all posts (optionally filtered by tab)
  Future<List<dynamic>> getPosts({String tab = 'all'}) async {
    try {
      debugPrint('🔍 API: GET $apiBaseUrl/community?tab=$tab');

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/community?tab=$tab'),
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

  /// POST /community/create - Create a new post with media files
  Future<void> createPost({
    required String content,
    bool isUrgent = false,
    List<String>? mediaPaths,
  }) async {
    try {
      debugPrint('➕ API: POST $apiBaseUrl/community/create');
      debugPrint('📤 Creating post: $content, urgent: $isUrgent');

      // Get headers WITHOUT Content-Type (multipart will set it)
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/community/create'),
      );

      // Add all headers including Authorization
      request.headers.addAll(headers);

      // Add form fields - match your NestJS backend field names EXACTLY
      request.fields['content'] = content.trim();
      request.fields['is_urgent'] = isUrgent
          .toString(); // Sends 'true' or 'false' as string

      // Add media files if provided
      if (mediaPaths != null && mediaPaths.isNotEmpty) {
        for (int i = 0; i < mediaPaths.length; i++) {
          final path = mediaPaths[i];
          try {
            // Generate clean filename
            final fileName =
                'post_${DateTime.now().millisecondsSinceEpoch}_$i${extname(path)}';

            final file = await http.MultipartFile.fromPath(
              'media', // MUST match FilesInterceptor('media') in NestJS
              path,
              filename: fileName,
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
}
