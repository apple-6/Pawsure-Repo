import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawsure_app/constants/api_endpoints.dart';
import 'package:pawsure_app/screens/community/sitter_model.dart';

class SitterService {
  SitterService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

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

  Uri _buildUri({DateTime? date}) {
    if (date == null) {
      return Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.sitters}');
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.sitterSearch}?date=$formattedDate',
    );
  }

  void dispose() {
    _client.close();
  }
}

