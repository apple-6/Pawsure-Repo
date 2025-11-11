// lib/services/sitter_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Used for the @required annotation

class SitterService {
  // Replace with your actual base API URL
  final String _baseUrl = 'http://10.0.2.2:3000/sitters/setup'; // Use 10.0.2.2 for Android emulator localhost

  // Placeholder for getting the user's authentication token
  // You will need to integrate this with your actual Auth service/storage
  Future<String> _getAuthToken() async {
    // Example: Retrieve token from SharedPreferences, Flutter Secure Storage, etc.
    // Replace this with your actual logic
    return 'YOUR_JWT_AUTH_TOKEN'; 
  }

  /// Submits the sitter setup form data, including the ID document file.
  Future<void> submitSitterSetup({
    @required Map<String, dynamic> setupData,
    @required String idDocumentFilePath,
  }) async {
    final uri = Uri.parse(_baseUrl);
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
    if (idDocumentFilePath != null && idDocumentFilePath.isNotEmpty) {
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
}