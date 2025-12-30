//pawsure_app\lib\services\auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import './storage_service.dart';
import 'package:pawsure_app/constants/api_config.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static String get _baseUrl => ApiConfig.baseUrl;

  // ✅ Get StorageService from GetX dependency injection
  StorageService get _storage => Get.find<StorageService>();

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
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
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

      // ✅ Store token
      await _storage.write(key: 'jwt', value: token);
      debugPrint('🔑 JWT token stored');

      // Fetch and store user profile
      try {
        final profile = await this.profile();
        if (profile != null && profile.containsKey('role')) {
          await _storage.write(key: 'user_role', value: profile['role']);
          debugPrint('👤 User role stored: ${profile['role']}');
        }
      } catch (e) {
        debugPrint('⚠️ Failed to fetch profile after login: $e');
      }

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

  /// Logout user and clear all stored credentials
  Future<void> logout() async {
    debugPrint('🚪 Logging out...');
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'user_role');
    debugPrint('✅ Logout complete');
  }

  /// Get stored JWT token
  Future<String?> getToken() async {
    final token = await _storage.read(key: 'jwt');
    if (token != null) {
      debugPrint('🔑 Using auth token: ${token.substring(0, 20)}...');
    } else {
      debugPrint('! No auth token found - API calls may fail');
    }
    return token;
  }

  /// Get user role from storage
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
          .get(uri, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

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
        return null;
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
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
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
          await _storage.write(key: 'jwt', value: token);
          await _storage.write(key: 'user_role', value: role);
          debugPrint('✅ Registration successful, token stored');
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
}
