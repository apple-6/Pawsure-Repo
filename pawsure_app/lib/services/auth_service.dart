import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import './storage_service.dart';

class AuthService {
  // Determine base URL depending on platform so emulator can reach host machine.
  // - Android emulator (AVD): use 10.0.2.2 to reach host localhost
  // - iOS simulator: use localhost
  // - Real devices: replace with your machine's LAN IP (e.g. http://192.168.1.100:3000)
  static String get _baseUrl {
    try {
      // Using ADB reverse: run "adb reverse tcp:3000 tcp:3000" to use localhost on real device
      if (Platform.isAndroid) return 'http://localhost:3000';
      if (Platform.isIOS) return 'http://localhost:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }

  // Use file-based storage implementation
  final StorageService _storage = FileStorageService();

  /// Login with email or phone number
  /// Automatically adds +60 prefix for phone numbers
  Future<String> login(
    String emailOrPhone,
    String password, {
    bool isPhone = false,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    // Debug: print the request target
    // ignore: avoid_print
    print('AuthService.login -> POST $uri');
    http.Response resp;
    try {
      // Add +60 prefix for phone numbers if not already present
      String identifier = emailOrPhone;
      if (isPhone && !emailOrPhone.startsWith('+')) {
        identifier = '+60$emailOrPhone';
      }

      // Backend accepts 'identifier' which can be either email or phone
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
    // Debug: print status and body for troubleshooting
    // ignore: avoid_print
    print('AuthService.login <- ${resp.statusCode} ${resp.body}');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(resp.body);
      final token = data['access_token'] as String?;
      if (token == null) throw Exception('access_token not found in response');
      await _storage.write(key: 'jwt', value: token);

      // Fetch and store user profile
      try {
        final profile = await this.profile();
        if (profile != null && profile.containsKey('role')) {
          await _storage.write(key: 'user_role', value: profile['role']);
        }
      } catch (e) {
        // ignore: avoid_print
        print('⚠️ Failed to fetch profile after login: $e');
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

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'user_role');
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'jwt');
  }

  /// Get user role
  Future<String?> getUserRole() async {
    return _storage.read(key: 'user_role');
  }

  /// Get current user profile
  /// ✅ FIXED: Changed from /auth/me to /auth/profile
  Future<Map<String, dynamic>?> profile() async {
    final token = await getToken();
    if (token == null) {
      // ignore: avoid_print
      print('⚠️ No token available for profile request');
      return null;
    }

    final uri = Uri.parse('$_baseUrl/auth/profile'); // ✅ Changed from /auth/me
    // ignore: avoid_print
    print('🔍 AuthService.profile -> GET $uri');

    try {
      final resp = await http
          .get(uri, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      // ignore: avoid_print
      print('📦 Profile Response: ${resp.statusCode}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        // ignore: avoid_print
        print('✅ Profile data received: ${data['name']}');
        return data;
      } else {
        // ignore: avoid_print
        print(
          '⚠️ Profile endpoint returned: ${resp.statusCode} - ${resp.body}',
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ AuthService.profile error: $e');
    }
    return null;
  }

  /// Register a new user with optional phone number and role
  /// Expects body: { name, email, password, phone_number?, role }
  /// Automatically adds +60 prefix for phone numbers
  /// If backend returns access_token, it will be stored and returned.
  Future<String?> register(
    String name,
    String email,
    String password, {
    String? phoneNumber,
    String role = 'owner', // Default role is 'owner'
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    // ignore: avoid_print
    print('AuthService.register -> POST $uri');
    http.Response resp;
    try {
      // Add +60 prefix for phone numbers if provided and not already present
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
    // ignore: avoid_print
    print('AuthService.register <- ${resp.statusCode} ${resp.body}');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      try {
        final Map<String, dynamic> data = jsonDecode(resp.body);
        final token = data['access_token'] as String?;
        if (token != null) {
          await _storage.write(key: 'jwt', value: token);
          return token;
        }
      } catch (_) {
        // ignore parse errors - treat as success without token
      }
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

  /// --- SITTER SETUP FUNCTION ---
  /// Submits the 4-step sitter setup form.
  Future<void> submitSitterSetup(Map<String, dynamic> setupData) async {
    // 1. Get the stored token
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated. Please log in.');
    }

    final uri = Uri.parse('$_baseUrl/sitters/setup');
    // ignore: avoid_print
    print('AuthService.submitSitterSetup -> POST $uri');
    http.Response resp;

    try {
      resp = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token', // 2. Send the token
            },
            body: json.encode(setupData), // 3. Send the form data
          )
          .timeout(const Duration(seconds: 10));
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out');
    }

    // ignore: avoid_print
    print('AuthService.submitSitterSetup <- ${resp.statusCode} ${resp.body}');

    // 4. Check for success
    if (resp.statusCode == 201) {
      // Success!
      return;
    } else {
      // Handle errors
      String message = 'Setup failed: ${resp.statusCode}';
      try {
        final Map<String, dynamic> err = jsonDecode(resp.body);
        if (err.containsKey('message')) message = err['message'].toString();
      } catch (_) {}
      throw Exception(message);
    }
  }
}
