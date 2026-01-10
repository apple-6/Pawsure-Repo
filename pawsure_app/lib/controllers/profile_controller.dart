//pawsure_app/lib/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_dashboard.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_registration_screen.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = Get.find<ApiService>();

  // Observable user data
  var user = <String, dynamic>{}.obs;
  var isLoading = true.obs;
  var isSitter = false.obs;

  String? get token => _authService.token;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      debugPrint('🔍 Loading user profile...');

      // Get current user from AuthService
      final profile = await _authService.profile();

      if (profile != null) {
        final name = profile['name'] as String? ?? '';
        final nameParts = name.split(' ');
        final userId = profile['id'];

        user.value = {
          'id': userId,
          'name': name,
          'firstName': nameParts.isNotEmpty ? nameParts.first : '',
          'lastName': nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
          'email': profile['email'],
          'role': profile['role'],
        };

        if (userId != null) {
          final sitterProfile = await _apiService.getSitterByUserId(userId);
          isSitter.value = (sitterProfile != null); // True if found, False if null
          
          debugPrint('✅ Sitter Status: ${isSitter.value ? "Is Sitter" : "Not Sitter"}');
        }

        debugPrint(
          '✅ Profile loaded: ${user['firstName']} ${user['lastName']}',
        );
      } else {
        debugPrint('⚠️ No profile data available');
        // If profile fetch fails/returns null, ensure we don't show old data
        if (user.isNotEmpty) user.clear();
        isSitter.value = false;
      }
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleSitterSwitch() async {
    if (isSitter.value) {
      // --- SCENARIO A: ALREADY A SITTER ---
      // Simply switch the view
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', 'sitter');

        // Navigate to Sitter Mode
        Get.offAll(() => const SitterDashboard()); 
        
        Get.snackbar("Mode Switched", "Welcome back to Sitter Mode!");
      } catch (e) {
        Get.snackbar("Error", "Failed to switch mode");
      }
    } else {
      // --- SCENARIO B: BECOME A SITTER ---
      // Navigate to Registration Form
      Get.to(() => const SitterRegistrationScreen());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> payload) async {
    // TODO: Call backend to update user profile
    user.addAll(payload);
    user.refresh();
  }

  /// Reset state (call on logout)
  void resetState() {
    user.clear();
    isSitter.value = false;
    isLoading.value = true;
    debugPrint('✅ ProfileController state reset');
  }
}
