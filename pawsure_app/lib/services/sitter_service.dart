import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/constants/api_endpoints.dart';
import 'package:pawsure_app/screens/community/sitter_model.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:flutter/foundation.dart';

// Get API base URL with platform detection
String get _apiBaseUrl {
  const envUrl = String.fromEnvironment('API_BASE_URL');
  if (envUrl.isNotEmpty) return envUrl;
  
  // Use 10.0.2.2 for Android emulator, localhost for other platforms
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000';
  } else {
    return 'http://localhost:3000';
  }
}

class SitterService {
  SitterService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // Get authenticated headers with JWT token
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
        debugPrint('🔑 SitterService: Using auth token');
      } else {
        debugPrint('⚠️ SitterService: No auth token found - API calls may fail');
      }
    } catch (e) {
      debugPrint('⚠️ SitterService: Could not get auth token: $e');
    }

    return headers;
  }

  Future<List<Sitter>> fetchSitters({DateTime? date}) async {
    try {
      final uri = _buildUri(date: date);
      final headers = await _getHeaders();
      
      debugPrint('🔍 SitterService: GET $uri');

      final response = await _client.get(uri, headers: headers);

      debugPrint('📦 SitterService: Response ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load sitters (${response.statusCode}): ${response.body}',
        );
      }

      final decodedBody = jsonDecode(response.body);
      if (decodedBody is! List) {
        throw Exception('Unexpected response for sitters list');
      }

      final sitters = Sitter.fromJsonList(decodedBody);
      debugPrint('✅ SitterService: Loaded ${sitters.length} sitters');
      return sitters;
    } catch (e, stackTrace) {
      debugPrint('❌ SitterService: Error fetching sitters: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Uri _buildUri({DateTime? date}) {
    if (date == null) {
      return Uri.parse('$_apiBaseUrl${ApiEndpoints.sitters}');
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return Uri.parse(
      '$_apiBaseUrl${ApiEndpoints.sitterSearch}?date=$formattedDate',
    );
  }

  void dispose() {
    _client.close();
  }
}

