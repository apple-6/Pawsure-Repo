import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/services/api_service.dart'; // To access apiBaseUrl
import 'package:pawsure_app/services/auth_service.dart';

class BookingService {
  Future<void> createBooking({
    required DateTime startDate,
    required DateTime endDate,
    required double totalAmount,
    required String sitterId,
    required int petId,
    required String dropOffTime, // 🆕 Required
    required String pickUpTime, // 🆕 Required
    String? message,
  }) async {
    try {
      final authService = Get.find<AuthService>();
      final token = await authService.getToken();

      final response = await http.post(
        Uri.parse('$apiBaseUrl/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'start_date': DateFormat('yyyy-MM-dd').format(startDate),
          'end_date': DateFormat('yyyy-MM-dd').format(endDate),
          'total_amount': totalAmount,
          'sitterId': int.parse(sitterId),
          'petId': petId,
          'drop_off_time': dropOffTime, // 🆕 Added to payload
          'pick_up_time': pickUpTime, // 🆕 Added to payload
          'message': message,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create booking: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchMyBookings() async {
    try {
      final authService = Get.find<AuthService>();
      final token = await authService.getToken();

      final response = await http.get(
        Uri.parse('$apiBaseUrl/bookings'), // Requires a GET endpoint on NestJS
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      rethrow;
    }
  }
  
}
