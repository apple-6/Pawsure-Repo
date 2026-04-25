// pawsure_app/lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pawsure_app/constants/api_config.dart';
import './storage_service.dart';

// 🟢 IMPORTS: Controllers needed for the Refresh/Reset Protocol
import 'package:pawsure_app/controllers/pet_controller.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';
import 'package:pawsure_app/controllers/home_controller.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/controllers/booking_controller.dart';
import 'package:pawsure_app/controllers/calendar_controller.dart';

class AuthService {
  static String get _baseUrl => ApiConfig.baseUrl;

  // ✅ Get StorageService from GetX dependency injection
  StorageService get _storage => Get.find<StorageService>();

  // ✅ In-memory token for immediate access
  String? _token;

  // ✅ Public getter
  String? get token => _token;

  /// Constructor: Syncs memory with disk storage on app startup
  AuthService() {
    _loadTokenFromStorage();
  }

  Future<void> _loadTokenFromStorage() async {
    _token = await _storage.read(key: 'jwt');
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    final isAuth = token != null && token.isNotEmpty;
    debugPrint('🔐 isAuthenticated: $isAuth');
    return isAuth;
  }

  /// Login with email or phone number
  Future<String> login(
    String emailOrPhone,
    String password, {
    bool isPhone = false,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    debugPrint('AuthService.login -> POST $uri');

    http.Response resp;
    try {
      String identifier = emailOrPhone;
      if (isPhone && !emailOrPhone.startsWith('+')) {
        identifier = '+60$emailOrPhone';
      }

      final body = {'identifier': identifier, 'password': password};

      resp = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true', // ✅ ADDED HERE
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out');
    }

    debugPrint('AuthService.login <- ${resp.statusCode} ${resp.body}');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(resp.body);
      final token = data['access_token'] as String?;
      if (token == null) throw Exception('access_token not found in response');

      // ✅ Store token in memory and storage
      _token = token;
      await _storage.write(key: 'jwt', value: token);
      debugPrint('🔑 JWT token stored');

      final prefs = await SharedPreferences.getInstance();

      // Attempt to get ID from login response directly
      if (data.containsKey('user') && data['user'] != null) {
        final userId = data['user']['id'];
        if (userId is int) {
          await prefs.setInt('userId', userId);
          debugPrint("✅ Saved User ID from Login: $userId");
        }
      }

      // Fetch and store user profile
      try {
        final profile = await this.profile();
        if (profile != null) {
          if (profile.containsKey('id') && profile['id'] is int) {
            await prefs.setInt('userId', profile['id']);
            debugPrint("✅ Saved User ID from Profile: ${profile['id']}");
          }

          if (profile.containsKey('role')) {
            await _storage.write(key: 'user_role', value: profile['role']);
            debugPrint('👤 User role stored: ${profile['role']}');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Failed to fetch profile after login: $e');
      }

      // 🟢 THE FIX: Force Global Refresh of All Controllers
      await _refreshAllControllers();

      return token;
    } else {
      String message = 'Login failed: ${resp.statusCode}';
      try {
        final Map<String, dynamic> err = jsonDecode(resp.body);
        if (err.containsKey('message')) message = err['message'].toString();
      } catch (_) {}
      throw Exception(message);
    }
  }

  /// 🟢 UPDATED: Refreshes data for the new user
  Future<void> _refreshAllControllers() async {
    debugPrint(
      '🔄 REFRESH PROTOCOL: Reloading all controllers for new user...',
    );

    // 1. Refresh Profile
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadProfile();
    }

    // 2. Refresh Pets (Critical for Home/Activity screens)
    if (Get.isRegistered<PetController>()) {
      await Get.find<PetController>().loadPets();
    }

    // 3. Refresh Bookings
    if (Get.isRegistered<BookingController>()) {
      Get.find<BookingController>().fetchMyBookings();
    }

    // 4. ✅ FIXED: Reset/Reload Calendar with new method
    if (Get.isRegistered<CalendarController>()) {
      final calendarController = Get.find<CalendarController>();
      calendarController.resetState();
      // ✅ Use new loadAllOwnerEvents() instead of loadEvents(petId)
      calendarController.loadAllOwnerEvents();
      calendarController.loadAllUpcomingEvents();
    }

    // 5. Refresh Home Data
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshHomeData();
    }

    debugPrint('✅ REFRESH PROTOCOL: Complete.');
  }

  Future<void> logout() async {
    debugPrint('🚪 Logging out...');
    _token = null;
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'user_role');

    // ✅ Clear User ID on logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    debugPrint('✅ Logout complete - cleared userId');

    // 🟢 THE FIX: Reset All Controllers
    _resetAllControllers();
  }

  /// 🟢 NEW HELPER: Resets all controllers to empty state
  void _resetAllControllers() {
    debugPrint('🧹 RESET PROTOCOL: Clearing all controller state...');

    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().resetState();
    }
    if (Get.isRegistered<PetController>()) {
      Get.find<PetController>().resetState();
    }
    if (Get.isRegistered<BookingController>()) {
      Get.find<BookingController>().userBookings.clear();
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().resetState();
    }
    if (Get.isRegistered<HealthController>()) {
      Get.find<HealthController>().resetState();
    }
    if (Get.isRegistered<CalendarController>()) {
      Get.find<CalendarController>().resetState();
    }

    debugPrint('✨ RESET PROTOCOL: Memory cleared.');
  }

  Future<String?> getToken() async {
    // Return memory token for better performance
    if (_token != null) {
      debugPrint('🔑 Using cached token');
      return _token;
    }

    _token = await _storage.read(key: 'jwt');
    if (_token != null) {
      debugPrint('🔑 Loaded token from storage');
    } else {
      debugPrint('⚠️ No auth token found');
    }
    return _token;
  }

  /// Get user role
  Future<String?> getUserRole() async {
    return _storage.read(key: 'user_role');
  }

  /// Get current user profile
  Future<Map<String, dynamic>?> profile() async {
    final token = await getToken();
    if (token == null) {
      debugPrint('⚠️ No token available for profile request');
      return null;
    }

    final uri = Uri.parse('$_baseUrl/auth/profile');
    debugPrint('🔍 AuthService.profile -> GET $uri');

    try {
      final resp = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': 'true', // ✅ ADDED HERE
            },
          )
          .timeout(const Duration(seconds: 60));

      debugPrint('📦 Profile Response: ${resp.statusCode}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('✅ Profile data received: ${data['name']}');

        // Update stored role if available
        if (data.containsKey('role')) {
          await _storage.write(key: 'user_role', value: data['role']);
        }

        return data;
      } else if (resp.statusCode == 401) {
        debugPrint('🔒 Token expired or invalid, clearing storage');
        await logout();
        return null;
      } else {
        debugPrint(
          '⚠️ Profile endpoint returned: ${resp.statusCode} - ${resp.body}',
        );
      }
    } on SocketException catch (e) {
      debugPrint('❌ Network error in profile: ${e.message}');
      return null;
    } on TimeoutException {
      debugPrint('❌ Profile request timed out');
      return null;
    } catch (e) {
      debugPrint('❌ AuthService.profile error: $e');
      return null;
    }
    return null;
  }

  /// Register a new user
  Future<String?> register(
    String name,
    String email,
    String password, {
    String? phoneNumber,
    String role = 'owner',
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    debugPrint('AuthService.register -> POST $uri');

    http.Response resp;
    try {
      String? formattedPhone = phoneNumber;
      if (phoneNumber != null &&
          phoneNumber.isNotEmpty &&
          !phoneNumber.startsWith('+')) {
        formattedPhone = '+60$phoneNumber';
      }

      final body = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        if (formattedPhone != null && formattedPhone.isNotEmpty)
          'phone_number': formattedPhone,
      };

      resp = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true', // ✅ ADDED HERE
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out');
    }

    debugPrint('AuthService.register <- ${resp.statusCode} ${resp.body}');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      try {
        final Map<String, dynamic> data = jsonDecode(resp.body);
        final token = data['access_token'] as String?;
        if (token != null) {
          // Update in-memory token immediately (was missing)
          _token = token;
          await _storage.write(key: 'jwt', value: token);
          await _storage.write(key: 'user_role', value: role);
          debugPrint('✅ Registration successful, token stored');

          // 🟢 Refresh controllers after registration
          await _refreshAllControllers();

          return token;
        }
      } catch (_) {}
      return null;
    } else {
      String message = 'Register failed: ${resp.statusCode}';
      try {
        final Map<String, dynamic> err = jsonDecode(resp.body);
        if (err.containsKey('message')) message = err['message'].toString();
      } catch (_) {}
      throw Exception(message);
    }
  }

  /// Submits the 4-step sitter setup form
  Future<void> submitSitterSetup(Map<String, dynamic> setupData) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated. Please log in.');
    }

    final uri = Uri.parse('$_baseUrl/sitters/setup');
    debugPrint('AuthService.submitSitterSetup -> POST $uri');

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['ngrok-skip-browser-warning'] = 'true';

    setupData.forEach((key, value) {
      if (key != 'idDocumentUrl' &&
          key != 'idDocumentFilePath' &&
          value != null) {
        request.fields[key] = value.toString();
      }
    });

    final filePath = setupData['idDocumentFilePath'];
    if (filePath != null && filePath.toString().isNotEmpty) {
      final file = File(filePath);
      if (await file.exists()) {
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();
        var multipartFile = http.MultipartFile(
          'idDocumentFile',
          stream,
          length,
          filename: file.path.split(Platform.pathSeparator).last,
        );
        request.files.add(multipartFile);
      } else {
        debugPrint('⚠️ Warning: File not found at path: $filePath');
      }
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint(
        'AuthService.submitSitterSetup <- ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await _storage.write(key: 'user_role', value: 'sitter');
        debugPrint('✅ Sitter setup complete');
        return;
      } else if (response.statusCode == 401) {
        await logout();
        throw Exception('Session expired. Please log in again.');
      } else {
        String message = 'Setup failed: ${response.statusCode}';
        try {
          final Map<String, dynamic> err = jsonDecode(response.body);
          if (err.containsKey('message')) message = err['message'].toString();
        } catch (_) {}
        throw Exception(message);
      }
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Error sending request: $e');
    }
  }

  /// Validate if the current token is still valid
  Future<bool> validateToken() async {
    final profile = await this.profile();
    return profile != null;
  }

  /// Get user ID from storage
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}
