// lib/services/sitter_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    };
  }

  /// Submits the sitter setup form data, including the ID document file.
  Future<void> submitSitterSetup({
    required Map<String, dynamic> setupData,
    required String idDocumentFilePath,
  }) async {
    final uri = Uri.parse(_setupBaseUrl);
    final request = http.MultipartRequest('POST', uri);

    final token = await _authService.getToken();
    request.headers['Authorization'] = 'Bearer $token';

    // 1. Add text fields to the request
    setupData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // 2. Add the file to the request
    if (idDocumentFilePath.isNotEmpty) {
      File file = File(idDocumentFilePath);
      request.files.add(
        await http.MultipartFile.fromPath(
          'idDocumentFile',
          file.path,
        ),
      );
    }

    // 3. Send the request
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('✅ Sitter profile successfully created.');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Failed to create sitter profile.',
        );
      }
    } catch (e) {
      throw Exception('Network or submission error: $e');
    }
  }

  /// Fetches the current logged-in sitter's profile.
  Future<Map<String, dynamic>> fetchMySitterProfile() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/sitters/my-profile');
      final headers = await _getHeaders();
      
      final response = await _client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {}; // No profile yet
      } else {
        throw Exception('Failed to load sitter profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching my sitter profile: $e');
      rethrow;
    }
  }

  /// Fetches ALL sitters, typically used when no date filter is applied.
  Future<List<Sitter>> fetchSitters() async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.sitters}');
      debugPrint('🔍 Fetching sitters from: $uri');
      
      final response = await _client.get(uri);
      debugPrint('📦 Sitter API Response: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('❌ Failed to load sitters: ${response.body}');
        throw Exception(
          'Failed to load sitters (${response.statusCode}): ${response.body}',
        );
      }

      debugPrint('📦 Sitter Response Body: ${response.body}');
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is! List) {
        throw Exception('Unexpected response for sitters list');
      }

      debugPrint('✅ Parsing ${decodedBody.length} sitters');
      return Sitter.fromJsonList(decodedBody);
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching sitters: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /**
   * Fetches available sitters based on a continuous date range.
   * This calls the updated backend searchByAvailability logic.
   */
  Future<List<Sitter>> fetchSittersByRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 1. Format dates for the backend (e.g., '2025-12-10')
      final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      // 2. Build the URI with query parameters
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.sitterSearch}')
          .replace(
            queryParameters: {
              'startDate': formattedStartDate,
              'endDate': formattedEndDate,
            },
          );

      debugPrint('🔍 Searching sitters by range: $uri');

      // 3. Send the request
      final response = await _client.get(uri);
      debugPrint('📦 Sitter Search Response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        debugPrint('❌ Search failed: ${errorBody['message']}');
        throw Exception(
          'Failed to search sitters by range: ${errorBody['message'] ?? response.statusCode}',
        );
      }

      debugPrint('📦 Search Response Body: ${response.body}');
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is! List) {
        throw Exception('Unexpected response format for filtered sitters.');
      }

      debugPrint('✅ Found ${decodedBody.length} available sitters');
      return Sitter.fromJsonList(decodedBody);
    } catch (e, stackTrace) {
      debugPrint('❌ Error searching sitters: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // --- Removed _buildUri as it's no longer necessary with the new methods ---

  /// Closes the underlying HTTP client.
  void dispose() {
    _client.close();
  }
}
