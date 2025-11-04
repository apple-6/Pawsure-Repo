import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/models/health_record_model.dart';

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

class ApiService {
  Future<List<Pet>> getPets() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/pets'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => Pet.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load pets (${response.statusCode})');
  }

  Future<List<HealthRecord>> getHealthRecords(int petId) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/pets/$petId/health-records'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => HealthRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // Provide more detailed error information
    final errorBody = response.body;
    throw Exception(
      'Failed to load health records (${response.statusCode}): $errorBody',
    );
  }

  Future<void> addHealthRecord(int petId, Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/pets/$petId/health-records'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add health record (${response.statusCode})');
    }
  }
}
