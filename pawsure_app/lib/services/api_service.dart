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

String get apiBaseUrl {
  const envUrl = String.fromEnvironment('API_BASE_URL');
  if (envUrl.isNotEmpty) return envUrl;

  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000';
  } else {
    return 'http://localhost:3000';
  }
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
}
