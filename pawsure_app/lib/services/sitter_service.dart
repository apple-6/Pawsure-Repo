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
  // Use a dedicated client for non-setup calls and a separate base URL for setup (as shown in your conflict)
  final http.Client _client;
  // This base URL was defined for the setup endpoint, which suggests it might be different from ApiEndpoints.baseUrl
  String get _setupBaseUrl => '${ApiConfig.baseUrl}/sitters/setup';

  SitterService({http.Client? client}) : _client = client ?? http.Client();

  // Placeholder for getting the user's authentication token
  Future<String> _getAuthToken() async {
    // Example: Retrieve token from SharedPreferences, Flutter Secure Storage, etc.
    return 'YOUR_JWT_AUTH_TOKEN';
  }

  /// Submits the sitter setup form data, including the ID document file.
  Future<void> submitSitterSetup({
    // FIX: Replaced deprecated @required with modern 'required' keyword
    required Map<String, dynamic> setupData,
    required String idDocumentFilePath,
  }) async {
    final uri = Uri.parse(_setupBaseUrl);
    final request = http.MultipartRequest('POST', uri);

    final token = await _getAuthToken();
    request.headers['Authorization'] = 'Bearer $token';

    // 1. Add text fields to the request
    setupData.forEach((key, value) {
      // Ensure complex types (like booleans) are converted to strings
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // 2. Add the file to the request
    if (idDocumentFilePath.isNotEmpty) {
      File file = File(idDocumentFilePath);

      // CRITICAL: 'idDocumentFile' MUST match the key in your NestJS @FileInterceptor!
      request.files.add(
        await http.MultipartFile.fromPath(
          'idDocumentFile',
          file.path,
          // Optional: You might want to specify contentType here if needed
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
        // Handle API errors (e.g., validation, conflict, 401 Unauthorized)
        final errorBody = json.decode(response.body);
        print('❌ Setup failed: Status ${response.statusCode}');
        print('Error Details: $errorBody');
        throw Exception(
          errorBody['message'] ?? 'Failed to create sitter profile.',
        );
      }
    } catch (e) {
      print('An error occurred during API submission: $e');
      throw Exception('Network or submission error: $e');
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

  /// Fetches available sitters based on a continuous date range.
  /// This calls the updated backend searchByAvailability logic.
  Future<List<Sitter>> fetchSittersByRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 1. Format dates for the backend (e.g., '2025-12-10')
      final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      // 2. Build the URI with query parameters
      final uri =
          Uri.parse(
            '${ApiEndpoints.baseUrl}${ApiEndpoints.sitterSearch}',
          ).replace(
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
