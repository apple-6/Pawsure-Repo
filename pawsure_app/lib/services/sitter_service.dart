// lib/services/sitter_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:pawsure_app/constants/api_endpoints.dart';
import 'package:pawsure_app/screens/community/sitter_model.dart';
import 'package:pawsure_app/constants/api_config.dart';

class SitterService {
  final http.Client _client;
  final AuthService _authService = Get.find<AuthService>();

  String get _setupBaseUrl => '${ApiConfig.baseUrl}/sitters/setup';

  SitterService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true', // ✅ HEADER PRESENT
    };
  }

  // ... (submitSitterSetup is rarely used, skipping to critical fetch methods) ...

  /// Fetches the current logged-in sitter's profile.
  Future<Map<String, dynamic>> fetchMySitterProfile() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/sitters/my-profile');
      final headers = await _getHeaders();

      final response = await _client.get(uri, headers: headers); // ✅ OK

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return {};
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          if (data.isEmpty) return {};
          return data.first as Map<String, dynamic>;
        }
        return data as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return {};
      } else {
        throw Exception(
          'Failed to load sitter profile: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching my sitter profile: $e');
      rethrow;
    }
  }

  /// Fetches ALL sitters
  Future<List<Sitter>> fetchSitters() async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.sitters}');
      final headers = await _getHeaders(); // ✅ GET HEADERS

      // ✅ PASS HEADERS HERE
      final response = await _client.get(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to load sitters (${response.statusCode})');
      }

      final decodedBody = jsonDecode(response.body);
      return Sitter.fromJsonList(decodedBody);
    } catch (e) {
      debugPrint('❌ Error fetching sitters: $e');
      rethrow;
    }
  }

  /// Fetches available sitters based on date range
  Future<List<Sitter>> fetchSittersByRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
      final headers = await _getHeaders(); // ✅ GET HEADERS

      final uri =
          Uri.parse(
            '${ApiEndpoints.baseUrl}${ApiEndpoints.sitterSearch}',
          ).replace(
            queryParameters: {
              'startDate': formattedStartDate,
              'endDate': formattedEndDate,
            },
          );

      // ✅ PASS HEADERS HERE
      final response = await _client.get(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to search sitters');
      }

      final decodedBody = jsonDecode(response.body);
      return Sitter.fromJsonList(decodedBody);
    } catch (e) {
      debugPrint('❌ Error searching sitters: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
