import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/services/booking_service.dart';

class BookingController extends GetxController {
  final BookingService _bookingService = BookingService();

  // State Variables
  var userBookings = <dynamic>[].obs;
  var isLoadingBookings = false.obs;
  var isCreatingBooking = false.obs; 

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();
  }

  /// Fetch all bookings for the current user
  Future<void> fetchMyBookings() async {
    try {
      isLoadingBookings.value = true;
      
      final data = await _bookingService.fetchMyBookings();
      
      debugPrint("📡 BookingController: Loaded ${data.length} bookings.");
      userBookings.assignAll(data);
      
    } catch (e) {
      debugPrint("❌ BookingController Error: $e");
      userBookings.clear(); 
    } finally {
      isLoadingBookings.value = false;
    }
  }

  /// Create a new booking and refresh the list
  Future<bool> createBooking({
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
      isCreatingBooking.value = true;

      await _bookingService.createBooking(
        startDate: startDate,
        endDate: endDate,
        totalAmount: totalAmount,
        sitterId: sitterId,
        petId: petId,
        dropOffTime: dropOffTime,
        pickUpTime: pickUpTime,
        message: message,
        paymentMethodId: paymentMethodId,
      );

      await fetchMyBookings();
      
      return true; 
    } catch (e) {
      Get.snackbar(
        "Booking Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false; 
    } finally {
      isCreatingBooking.value = false;
    }
  }
}