import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Determine base URL depending on platform so emulator can reach host machine.
  // - Android emulator (AVD): use 10.0.2.2 to reach host localhost
  // - iOS simulator: use localhost
  // - Real devices: replace with your machine's LAN IP (e.g. http://192.168.1.100:3000)
  static String get _baseUrl {
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
      if (Platform.isIOS) return 'http://localhost:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    // Debug: print the request target
    // ignore: avoid_print
    print('AuthService.login -> POST $uri');
    http.Response resp;
    try {
      resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
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
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'jwt');
  }

  Future<Map<String, dynamic>?> profile() async {
    final token = await getToken();
    if (token == null) return null;
    final uri = Uri.parse('$_baseUrl/auth/me');
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    return null;
  }

  /// Register a new user. Expects body: { name, email, password }
  /// If backend returns access_token, it will be stored and returned.
  Future<String?> register(String name, String email, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    // ignore: avoid_print
    print('AuthService.register -> POST $uri');
    http.Response resp;
    try {
      resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
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
}
