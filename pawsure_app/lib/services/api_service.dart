// Pawsure-Repo\pawsure_app\lib\services\api_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
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

class ApiService {
  AuthService get _authService => Get.find<AuthService>();
  static const _timeout = Duration(seconds: 30);

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

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 401) {
      debugPrint('❌ Unauthorized: Token may be expired');
      throw Exception('Session expired. Please log in again.');
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        final message = errorBody['message'] ?? 'Unknown error';
        throw Exception(message);
      } catch (e) {
        throw Exception('Server Error: ${response.statusCode}');
      }
    }
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
        request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
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
        request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
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
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$apiBaseUrl/pets/$petId'), headers: headers);
    if (response.statusCode != 200 && response.statusCode != 204) throw Exception('Failed to delete pet');
  }

  // ========================================================================
  // HEALTH RECORDS API
  // ========================================================================

  Future<List<HealthRecord>> getHealthRecords(int petId) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/pets/$petId/health-records'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => HealthRecord.fromJson(e)).toList();
    }
    return [];
  }

  Future<HealthRecord> addHealthRecord(int petId, Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse('$apiBaseUrl/pets/$petId/health-records'), headers: headers, body: jsonEncode(payload));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return HealthRecord.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to add health record');
  }

  Future<HealthRecord> updateHealthRecord(int recordId, Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final response = await http.patch(Uri.parse('$apiBaseUrl/health-records/$recordId'), headers: headers, body: jsonEncode(payload));
    if (response.statusCode == 200) return HealthRecord.fromJson(jsonDecode(response.body));
    throw Exception('Failed to update health record');
  }

  Future<void> deleteHealthRecord(int recordId) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$apiBaseUrl/health-records/$recordId'), headers: headers);
    if (response.statusCode != 200 && response.statusCode != 204) throw Exception('Failed to delete health record');
  }

  // ========================================================================
  // EVENTS API
  // ========================================================================

  Future<List<EventModel>> getAllOwnerEvents() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/events/owner/all'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => EventModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<EventModel>> getAllOwnerUpcomingEvents({int limit = 3}) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/events/owner/upcoming?limit=$limit'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => EventModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<EventModel> updateEventStatus(int eventId, EventStatus status) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$apiBaseUrl/events/$eventId/status'),
      headers: headers,
      body: jsonEncode({'status': status.toJson()}),
    );
    if (response.statusCode == 200) return EventModel.fromJson(jsonDecode(response.body));
    throw Exception('Failed to update event status');
  }

  Future<void> deleteEvent(int eventId) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$apiBaseUrl/events/$eventId'), headers: headers);
    if (response.statusCode != 200 && response.statusCode != 204) throw Exception('Failed to delete event');
  }

  Future<void> createEvent(Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse('$apiBaseUrl/events'), headers: headers, body: jsonEncode(payload));
    if (response.statusCode != 201) throw Exception('Failed to create event');
  }

  // ========================================================================
  // MOOD & STREAK API
  // ========================================================================

  Future<Map<String, dynamic>> logMood({required int petId, required int moodScore, String? moodLabel}) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/pets/$petId/mood'),
      headers: headers,
      body: jsonEncode({'mood_score': moodScore, if (moodLabel != null) 'mood_label': moodLabel}),
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> getTodayMood(int petId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$apiBaseUrl/pets/$petId/mood/today'), headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getStreakInfo(int petId) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/pets/$petId/mood/streak'), headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    return {'currentStreak': 0};
  }

  // ========================================================================
  // MEAL LOGS API
  // ========================================================================

  Future<Map<String, dynamic>> logMeal({required int petId, required String mealType}) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse('$apiBaseUrl/pets/$petId/meals'), headers: headers, body: jsonEncode({'meal_type': mealType}));
    return jsonDecode(response.body);
  }

  Future<List<String>> getTodayMeals(int petId) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/pets/$petId/meals/today'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e['meal_type'] as String).toList();
    }
    return [];
  }

  // ========================================================================
  // POSTS/COMMUNITY API
  // ========================================================================

  Future<List<dynamic>> getPosts({String tab = 'all'}) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/posts?tab=$tab'), headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load posts');
  }

  Future<void> createPost({required String content, bool isUrgent = false, List<String>? mediaPaths}) async {
    final headers = await _getHeaders();
    headers.remove('Content-Type');
    final request = http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/posts'));
    request.headers.addAll(headers);
    request.fields['content'] = content;
    request.fields['is_urgent'] = isUrgent.toString();
    if (mediaPaths != null) {
      for (var path in mediaPaths) {
        request.files.add(await http.MultipartFile.fromPath('media', path));
      }
    }
    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 201) throw Exception('Failed to create post');
  }

  Future<void> updatePost({
    required String postId,
    required String content,
    required bool isUrgent,
    required List<String> existingMediaUrls,
    required List<String> newMediaPaths,
  }) async {
    final headers = await _getHeaders();
    headers.remove('Content-Type');
    final request = http.MultipartRequest('PUT', Uri.parse('$apiBaseUrl/posts/$postId'));
    request.headers.addAll(headers);
    request.fields['content'] = content;
    request.fields['is_urgent'] = isUrgent.toString();
    request.fields['existingMedia'] = jsonEncode(existingMediaUrls);

    if (newMediaPaths.isNotEmpty) {
      for (var path in newMediaPaths) {
        request.files.add(await http.MultipartFile.fromPath('media', path));
      }
    }
    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200 && response.statusCode != 201) throw Exception('Failed to update post');
  }

  // ========================================================================
  // USER PROFILE & SITTER API
  // ========================================================================

  Future<dynamic> getSitterByUserId(int userId) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/sitters/user/$userId'), headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  Future<dynamic> getMySitterProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/sitters/my-profile'), headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  Future<Map<String, dynamic>> updateProfileMultipart(Map<String, dynamic> data, File? image) async {
    final headers = await _getHeaders();
    headers.remove('Content-Type');
    final request = http.MultipartRequest('PATCH', Uri.parse('$apiBaseUrl/users/profile'));
    request.headers.addAll(headers);
    data.forEach((key, value) => request.fields[key] = value.toString());
    if (image != null) request.files.add(await http.MultipartFile.fromPath('profile_picture', image.path));
    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to update profile');
  }

  Future<List<dynamic>> getSitterBookings() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/bookings/sitter'), headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<List<dynamic>> getOwnerBookings() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/bookings/owner'), headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<List<dynamic>> getMyBookings() async {
    return getOwnerBookings();
  }

  Future<void> updateBookingStatus(int bookingId, String status) async {
    final headers = await _getHeaders();
    final response = await http.patch(Uri.parse('$apiBaseUrl/bookings/$bookingId/status'), headers: headers, body: jsonEncode({'status': status}));
    if (response.statusCode != 200) throw Exception('Failed to update booking');
  }

  Future<void> completeService(int bookingId) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse('$apiBaseUrl/bookings/$bookingId/complete'), headers: headers);
    if (response.statusCode != 200) throw Exception('Failed to complete service');
  }

  Future<dynamic> getSitterDetails(int sitterId) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/sitters/$sitterId'), headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load sitter details');
  }

  Future<void> createSitterProfile(Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse('$apiBaseUrl/sitters'), headers: headers, body: jsonEncode(payload));
    if (response.statusCode != 201) throw Exception('Failed to create sitter profile');
  }

  Future<void> updateSitterProfile(Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final response = await http.patch(Uri.parse('$apiBaseUrl/sitters/profile'), headers: headers, body: jsonEncode(payload));
    if (response.statusCode != 200) throw Exception('Failed to update sitter profile');
  }

  // ========================================================================
  // REVIEWS & PAYMENTS
  // ========================================================================

  Future<void> createReview({required int bookingId, required int rating, String? comment}) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse('$apiBaseUrl/reviews'), headers: headers, body: jsonEncode({
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
    }));
    if (response.statusCode != 201) throw Exception('Failed to create review');
  }

  Future<void> processPayment(dynamic payloadOrId) async {
    final headers = await _getHeaders();
    final dynamic body = (payloadOrId is Map) ? payloadOrId : {'bookingId': payloadOrId};
    
    final response = await http.post(Uri.parse('$apiBaseUrl/payments/process'), headers: headers, body: jsonEncode(body));
    if (response.statusCode != 201 && response.statusCode != 200) throw Exception('Failed to process payment');
  }

  // ========================================================================
  // PAYMENT METHODS API
  // ========================================================================

  Future<List<dynamic>> getPaymentMethods() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/payment-methods'), headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<void> addPaymentMethod({required String cardType, required String lastFourDigits, required String cardholderName, required String expiryMonth, required String expiryYear, bool isDefault = false}) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse('$apiBaseUrl/payment-methods'), headers: headers, body: jsonEncode({
      'cardType': cardType, 'lastFourDigits': lastFourDigits, 'cardholderName': cardholderName, 'expiryMonth': expiryMonth, 'expiryYear': expiryYear, 'isDefault': isDefault
    }));
    if (response.statusCode != 201) throw Exception('Failed to add payment method');
  }

  Future<void> setDefaultPaymentMethod(int methodId) async {
    final headers = await _getHeaders();
    final response = await http.patch(Uri.parse('$apiBaseUrl/payment-methods/$methodId/default'), headers: headers);
    if (response.statusCode != 200) throw Exception('Failed to set default payment method');
  }

  Future<void> deletePaymentMethod(int methodId) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$apiBaseUrl/payment-methods/$methodId'), headers: headers);
    if (response.statusCode != 200) throw Exception('Failed to delete payment method');
  }

  // ========================================================================
  // LIKES, COMMENTS & CHAT
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

  Future<List<dynamic>> getChatHistory(String room) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiBaseUrl/chat/$room'), headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed history');
  }
}
