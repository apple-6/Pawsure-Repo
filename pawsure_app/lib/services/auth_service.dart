//pawsure_app\lib\services\auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import './storage_service.dart';
import 'package:pawsure_app/constants/api_config.dart';

class AuthService {
  // Determine base URL depending on platform so emulator can reach host machine.
  // - Android emulator (AVD): use 10.0.2.2 to reach host localhost
  // - iOS simulator: use localhost
  // - Real devices: replace with your machine's LAN IP (e.g. http://192.168.1.100:3000)
  static String get _baseUrl => ApiConfig.baseUrl;

  // Use file-based storage implementation
  final StorageService _storage = FileStorageService();

  /// Check if user is authenticated
  /// Returns true if a valid token exists
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Login with email or phone number
  /// Automatically adds +60 prefix for phone numbers
  Future<String> login(
    String emailOrPhone,
    String password, {
    bool isPhone = false,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
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

  /// Logout user and clear all stored credentials
  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'user_role');
  }

  /// Get stored JWT token
  Future<String?> getToken() async {
    return _storage.read(key: 'jwt');
  }

  /// Get user role from storage
  Future<String?> getUserRole() async {
    return _storage.read(key: 'user_role');
  }

  /// Get current user profile
  /// Returns null if not authenticated or if request fails
  Future<Map<String, dynamic>?> profile() async {
    final token = await getToken();
    if (token == null) {
      // ignore: avoid_print
      print('⚠️ No token available for profile request');
      return null;
    }

    final uri = Uri.parse('$_baseUrl/auth/profile');
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

        // Update stored role if available
        if (data.containsKey('role')) {
          await _storage.write(key: 'user_role', value: data['role']);
        }

        return data;
      } else if (resp.statusCode == 401) {
        // Token is invalid or expired - clear it
        // ignore: avoid_print
        print('🔒 Token expired or invalid, clearing storage');
        await logout();
        return null;
      } else {
        // ignore: avoid_print
        print(
          '⚠️ Profile endpoint returned: ${resp.statusCode} - ${resp.body}',
        );
        return null;
      }
    } on SocketException catch (e) {
      // ignore: avoid_print
      print('❌ Network error in profile: ${e.message}');
      return null;
    } on TimeoutException {
      // ignore: avoid_print
      print('❌ Profile request timed out');
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('❌ AuthService.profile error: $e');
      return null;
    }
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
          await _storage.write(key: 'user_role', value: role);
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

  /// Submits the 4-step sitter setup form
  /// Requires user to be authenticated
  Future<void> submitSitterSetup(Map<String, dynamic> setupData) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated. Please log in.');
    }

    final uri = Uri.parse('$_baseUrl/sitters/setup');
    // ignore: avoid_print
    print('AuthService.submitSitterSetup -> POST $uri');

    // 2. Create a Multipart Request (Required for files)
    var request = http.MultipartRequest('POST', uri);

    // Add Headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';

    // 3. Add Text Fields
    setupData.forEach((key, value) {
      // Skip the file path keys (we handle the file separately below)
      // Also skip null values
      if (key != 'idDocumentUrl' &&
          key != 'idDocumentFilePath' &&
          value != null) {
        request.fields[key] = value.toString();
      }
    });

    // 4. Add the File (The Critical Fix)
    // We look for 'idDocumentFilePath' which contains the local path on your phone
    final filePath = setupData['idDocumentFilePath'];

    if (filePath != null && filePath.toString().isNotEmpty) {
      final file = File(filePath);

      if (await file.exists()) {
        // Create the file part
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();

        var multipartFile = http.MultipartFile(
          'idDocumentFile', // <--- This MUST match the NestJS @UseInterceptors name
          stream,
          length,
          filename: file.path.split(Platform.pathSeparator).last,
        );

        request.files.add(multipartFile);
      } else {
        print('⚠️ Warning: File not found at path: $filePath');
      }
    }

    // 5. Send the request
    try {
      // MERGE FIX: Used Sprint3 logic to send Multipart request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // ignore: avoid_print
      print(
        'AuthService.submitSitterSetup <- ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // MERGE FIX: Used HEAD logic to update Role in storage
        await _storage.write(key: 'user_role', value: 'sitter');
        return;
      } else if (response.statusCode == 401) {
        // MERGE FIX: Used HEAD logic to handle token expiration
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
  /// Returns true if token is valid, false otherwise
  Future<bool> validateToken() async {
    final profile = await this.profile();
    return profile != null;
  }
}
