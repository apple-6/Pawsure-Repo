import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/services/sitter_service.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';

class SitterController extends GetxController {
  final SitterService _sitterService = SitterService();
  final ApiService _apiService = ApiService();
  final ProfileController _profileController = Get.find<ProfileController>();

  // State Variables
  var sitterProfile = <String, dynamic>{}.obs;
  var bookings = <dynamic>[].obs;
  var isLoading = false.obs;

  // Computed Stats
  var earnings = 0.0.obs;
  var pendingRequestsCount = 0.obs;
  var activeStaysCount = 0.obs;
  var avgRating = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      await Future.wait([fetchMyProfile(), fetchBookings()]);
      _calculateStats();
    } catch (e) {
      debugPrint('❌ Error refreshing sitter data: $e');
    } finally {
      // FIX: Schedule the state update to run after the current build frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = false;
      });
    }
  }

  Future<void> fetchMyProfile() async {
    try {
      final profile = await _sitterService.fetchMySitterProfile();
      sitterProfile.value = profile;
      avgRating.value = (profile['rating'] ?? 0.0).toDouble();
    } catch (e) {
      debugPrint('❌ Error fetching sitter profile: $e');
    }
  }

  Future<void> fetchBookings() async {
    try {
      final data = await _apiService.getSitterBookings();
      bookings.assignAll(data);
    } catch (e) {
      debugPrint('❌ Error fetching sitter bookings: $e');
    }
  }

  void _calculateStats() {
    double totalEarnings = 0.0;
    int pendingCount = 0;
    int activeCount = 0;

    for (var booking in bookings) {
      final status = booking['status']?.toString().toLowerCase() ?? '';
      final amount = (booking['total_amount'] ?? 0.0).toDouble();
      final isPaid = booking['is_paid'] == true;

      if (isPaid || status == 'completed' || status == 'paid') {
        totalEarnings += amount;
      }

      if (status == 'pending') {
        pendingCount++;
      }

      if (status == 'accepted' || status == 'in progress') {
        activeCount++;
      }
    }

    earnings.value = totalEarnings;
    pendingRequestsCount.value = pendingCount;
    activeStaysCount.value = activeCount;
  }

  String get sitterName => _profileController.user['name'] ?? 'Sitter';

  Future<void> updateBookingStatus(int bookingId, String status) async {
    try {
      await _apiService.updateBookingStatus(bookingId, status);
      await fetchBookings();
      _calculateStats();
      Get.snackbar(
        'Success',
        'Booking $status successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update booking status');
    }
  }
}
