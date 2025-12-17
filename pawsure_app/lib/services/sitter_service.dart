// lib/services/sitter_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Needed for the 'required' keyword for now
import 'package:intl/intl.dart';
import 'package:pawsure_app/constants/api_endpoints.dart';
import 'package:pawsure_app/screens/community/sitter_model.dart';


class SitterService {
  // Use a dedicated client for non-setup calls
  final http.Client _client;
  // Use consistent base URL from ApiEndpoints
  String get _setupBaseUrl => '${ApiEndpoints.baseUrl}/sitters/setup';

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
        throw Exception(errorBody['message'] ?? 'Failed to create sitter profile.');
      }
    } catch (e) {
      print('An error occurred during API submission: $e');
      throw Exception('Network or submission error: $e');
    }
  }

  /// Fetches a list of sitters, optionally filtered by date availability.
  // This satisfies the 'fetchSitters' method missing error
  Future<List<Sitter>> fetchSitters({DateTime? date}) async {
    final uri = _buildUri(date: date);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load sitters (${response.statusCode}): ${response.body}',
      );
    }

    final decodedBody = jsonDecode(response.body);
    if (decodedBody is! List) {
      throw Exception('Unexpected response for sitters list');
    }

    return Sitter.fromJsonList(decodedBody);
  }

  // Helper method for fetchSitters
  Uri _buildUri({DateTime? date}) {
    if (date == null) {
      return Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.sitters}');
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.sitterSearch}?date=$formattedDate',
    );
  }

  /// Closes the underlying HTTP client.
  // This satisfies the 'dispose' method missing error
  void dispose() {
    _client.close();
  }
}