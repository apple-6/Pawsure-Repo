// Pawsure-Repo\pawsure_app\lib\services\api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/models/event_model.dart';
import 'package:pawsure_app/models/sitter_model.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/constants/api_config.dart';
import 'package:pawsure_app/models/comment_model.dart';
import 'package:mime/mime.dart';

String get apiBaseUrl => ApiConfig.baseUrl;

// Helper function to get file extension
String extname(String filename) {
  final lastDot = filename.lastIndexOf('.');
  if (lastDot == -1) return '';
  return filename.substring(lastDot);
}

class ApiService {
  AuthService get _authService => Get.find<AuthService>();

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    try {
      final token = await _authService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${token.replaceAll('"', '').trim()}';
      }
    } catch (e) {
      debugPrint('⚠️ Could not get auth token: $e');
    }

    return headers;
  }

  // ========================================================================
  // PETS API
  // ========================================================================

  Future<List<Pet>> getPets() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$apiBaseUrl/pets'), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Pet.fromJson(e)).toList();
      }
      throw Exception('Failed to load pets: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error in getPets: $e');
      rethrow;
    }
  }

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
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/pets'));
      request.headers.addAll(headers);

      request.fields['name'] = name;
      request.fields['breed'] = breed;
      if (species != null) request.fields['species'] = species;
      if (dob != null) request.fields['dob'] = dob;
      if (weight != null) request.fields['weight'] = weight.toString();
      if (sterilizationStatus != null) request.fields['sterilization_status'] = sterilizationStatus;
      if (allergies != null) request.fields['allergies'] = allergies;
      if (moodRating != null) request.fields['mood_rating'] = moodRating.toString();
      if (lastVetVisit != null) request.fields['last_vet_visit'] = lastVetVisit;

      if (photoPath != null && photoPath.isNotEmpty) {
        final fileName = 'pet_${DateTime.now().millisecondsSinceEpoch}.jpg';
        request.files.add(await http.MultipartFile.fromPath('photo', photoPath, filename: fileName));
      }

      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Pet.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create pet: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error in createPet: $e');
      rethrow;
    }
  }

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
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      final request = http.MultipartRequest('PUT', Uri.parse('$apiBaseUrl/pets/$petId'));
      request.headers.addAll(headers);

      if (name != null) request.fields['name'] = name;
      if (breed != null) request.fields['breed'] = breed;
      if (species != null) request.fields['species'] = species;
      if (dob != null) request.fields['dob'] = dob;
      if (weight != null) request.fields['weight'] = weight.toString();
      if (height != null) request.fields['height'] = height.toString();
      if (bodyConditionScore != null) request.fields['body_condition_score'] = bodyConditionScore.toString();
      if (weightHistory != null) request.fields['weight_history'] = jsonEncode(weightHistory);
      if (sterilizationStatus != null) request.fields['sterilization_status'] = sterilizationStatus;
      if (allergies != null) request.fields['allergies'] = allergies;
      if (foodBrand != null) request.fields['food_brand'] = foodBrand;
      if (dailyFoodAmount != null) request.fields['daily_food_amount'] = dailyFoodAmount;
      if (moodRating != null) request.fields['mood_rating'] = moodRating.toString();
      if (lastVetVisit != null) request.fields['last_vet_visit'] = lastVetVisit;

      if (photoPath != null && photoPath.isNotEmpty) {
        final fileName = 'pet_upd_${DateTime.now().millisecondsSinceEpoch}.jpg';
        request.files.add(await http.MultipartFile.fromPath('photo', photoPath, filename: fileName));
      }

      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        return Pet.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update pet: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error in updatePet: $e');
      rethrow;
    }
  }

  Future<void> deletePet(int petId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse('$apiBaseUrl/pets/$petId'), headers: headers);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete pet: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error in deletePet: $e');
      rethrow;
    }
  }

  // ========================================================================
  // HEALTH RECORDS API
  // ========================================================================

  Future<List<HealthRecord>> getHealthRecords(int petId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$apiBaseUrl/pets/$petId/health-records'), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => HealthRecord.fromJson(e)).toList();
      }
      throw Exception('Failed to load health records: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error in getHealthRecords: $e');
      rethrow;
    }
  }

  Future<HealthRecord> addHealthRecord(int petId, Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/pets/$petId/health-records'),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return HealthRecord.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to add health record: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error in addHealthRecord: $e');
      rethrow;
    }
  }

  // ========================================================================
  // EVENTS API
  // ========================================================================

  Future<List<EventModel>> getAllOwnerEvents() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$apiBaseUrl/events/owner/all'), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => EventModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error in getAllOwnerEvents: $e');
      return [];
    }
  }

  // ========================================================================
  // POSTS/COMMUNITY API
  // ========================================================================

  Future<List<dynamic>> getPosts({String tab = 'all'}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$apiBaseUrl/posts?tab=$tab'), headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to load posts: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error in getPosts: $e');
      rethrow;
    }
  }

  Future<void> createPost({
    required String content,
    bool isUrgent = false,
    List<String>? mediaPaths,
  }) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/posts'));
      request.headers.addAll(headers);
      request.fields['content'] = content.trim();
      request.fields['is_urgent'] = isUrgent.toString();

      if (mediaPaths != null) {
        for (int i = 0; i < mediaPaths.length; i++) {
          final path = mediaPaths[i];
          final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}_$i${extname(path)}';
          final file = await http.MultipartFile.fromPath('media', path, filename: fileName);
          request.files.add(file);
        }
      }

      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error in createPost: $e');
      rethrow;
    }
  }

  Future<void> updatePost({
    required String postId,
    required String content,
    required bool isUrgent,
    required List<String> existingMediaUrls,
    required List<String> newMediaPaths,
  }) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      final request = http.MultipartRequest('PUT', Uri.parse('$apiBaseUrl/posts/$postId'));
      request.headers.addAll(headers);
      request.fields['content'] = content;
      request.fields['isUrgent'] = isUrgent.toString();
      request.fields['existingMedia'] = jsonEncode(existingMediaUrls);

      for (var path in newMediaPaths) {
        if (path.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath('media', path));
        }
      }

      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update post: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error in updatePost: $e');
      rethrow;
    }
  }

  // ========================================================================
  // MOOD & STREAK API
  // ========================================================================

  Future<Map<String, dynamic>> logMood({
    required int petId,
    required int moodScore,
    String? moodLabel,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/pets/$petId/mood'),
        headers: headers,
        body: jsonEncode({
          'mood_score': moodScore,
          if (moodLabel != null) 'mood_label': moodLabel,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to log mood: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error in logMood: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStreakInfo(int petId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$apiBaseUrl/pets/$petId/mood/streak'), headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'currentStreak': 0};
    } catch (e) {
      return {'currentStreak': 0};
    }
  }

  // ========================================================================
  // MEAL LOGS API
  // ========================================================================

  Future<Map<String, dynamic>> logMeal({required int petId, required String mealType}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/pets/$petId/meals'),
        headers: headers,
        body: jsonEncode({'meal_type': mealType}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getTodayMeals(int petId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$apiBaseUrl/pets/$petId/meals/today'), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e['meal_type'] as String).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ========================================================================
  // CHAT & SITTER API (Simplified)
  // ========================================================================

  Future<List<dynamic>> getChatHistory(String room) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/chat/$room'), headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed history');
  }

  Future<UserProfile?> getMySitterProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$apiBaseUrl/sitters/my-profile'), headers: headers);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return UserProfile.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> createSitterProfile(Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse('$apiBaseUrl/sitters'), headers: headers, body: jsonEncode(payload));
    if (response.statusCode != 201) throw Exception('Failed registration');
  }

  // ========================================================================
  // LIKES & COMMENTS
  // ========================================================================

  Future<Map<String, dynamic>> toggleLike(String postId) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse('$apiBaseUrl/likes/$postId'), headers: headers);
    return jsonDecode(response.body);
  }

  Future<List<CommentModel>> getComments(String postId) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/comments/post/$postId'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CommentModel.fromJson(_flattenCommentData(json, postId))).toList();
    }
    return [];
  }

  Future<CommentModel> addComment(String postId, String content) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse('$apiBaseUrl/comments/post/$postId'), headers: headers, body: jsonEncode({'content': content}));
    return CommentModel.fromJson(_flattenCommentData(jsonDecode(response.body), postId));
  }

  Map<String, dynamic> _flattenCommentData(Map<String, dynamic> json, String postId) {
    final user = json['user'] ?? {};
    return {
      'id': json['id'].toString(),
      'postId': postId,
      'userId': (user['id'] ?? '').toString(),
      'userName': user['name'] ?? 'Unknown',
      'content': json['content'] ?? '',
      'createdAt': json['created_at'] ?? DateTime.now().toIso8601String(),
    };
  }
}
