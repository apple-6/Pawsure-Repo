//pawsure_app\lib\services\booking_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/services/api_service.dart'; // To access apiBaseUrl
import 'package:pawsure_app/services/auth_service.dart';

class BookingService {

  final ApiService _apiService = ApiService();

  Future<void> createBooking({
    required DateTime startDate,
    required DateTime endDate,
    required double totalAmount,
    required String sitterId,
    required int petId,
    required String dropOffTime,
    required String pickUpTime,
    String? message,
    int? paymentMethodId,
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
          'drop_off_time': dropOffTime,
          'pick_up_time': pickUpTime,
          'message': message,
          if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
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

  /// Fetch bookings specifically for the Owner 
  Future<List<dynamic>> fetchOwnerBookings() async {
    // Delegates to the ApiService method
    return await _apiService.getOwnerBookings();
  }

  /// Update booking status (used for Cancelling requests)
  /// ✅ This is the method your error said was missing!
  Future<void> updateBookingStatus(int bookingId, String status) async {
    await _apiService.updateBookingStatus(bookingId, status);
  }
}
