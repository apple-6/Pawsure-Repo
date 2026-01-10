//pawsure_app/lib/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Observable user data
  var user = <String, dynamic>{}.obs;
  var isLoading = true.obs;

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

        user.value = {
          'id': profile['id'],
          'name': name,
          'firstName': nameParts.isNotEmpty ? nameParts.first : '',
          'lastName': nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
          'email': profile['email'],
          'role': profile['role'],
        };

        debugPrint(
          '✅ Profile loaded: ${user['firstName']} ${user['lastName']}',
        );
      } else {
        debugPrint('⚠️ No profile data available');
        // If profile fetch fails/returns null, ensure we don't show old data
        if (user.isNotEmpty) user.clear();
      }
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
    } finally {
      isLoading.value = false;
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
    isLoading.value = true;
    debugPrint('✅ ProfileController state reset');
  }
}
