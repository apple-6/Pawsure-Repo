import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/sitter.dart';

class SitterService {
  static String get _baseUrl {
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
      if (Platform.isIOS) return 'http://localhost:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }

  /// Fetch list of sitters from the backend.
  static Future<List<Sitter>> fetchSitters({int limit = 20}) async {
    final uri = Uri.parse('\$_baseUrl/sitters?limit=\$limit');
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final List<dynamic> items = jsonDecode(resp.body) as List<dynamic>;
        return items
            .map((e) => Sitter.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch sitters: ${resp.statusCode}');
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out');
    }
  }
}
