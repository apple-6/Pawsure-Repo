import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:pawsure_app/services/auth_service.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_dashboard.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_registration_screen.dart';
// Note: You might need to import http for MultipartRequest if not in ApiService
// import 'package:http/http.dart' as http; 

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = Get.find<ApiService>();

  // Observable user data
  var user = <String, dynamic>{}.obs;
  var isLoading = true.obs;
  var isSaving = false.obs; // New observable for save button loading state
  var isSitter = false.obs;
  
  // Image Picking
  var selectedImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();

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
          // Add these fields if your backend returns them, otherwise default to empty
          'phone': profile['phone_number'] ?? profile['phone'] ?? '',
          'bio': profile['bio'] ?? '',
          'avatar': profile['profile_picture'] ?? '',
        };

        if (userId != null) {
          final sitterProfile = await _apiService.getSitterByUserId(userId);
          isSitter.value = (sitterProfile != null);
        }
      } else {
        if (user.isNotEmpty) user.clear();
        isSitter.value = false;
      }
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- New: Image Picker ---
  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  // --- New: Update Profile (Handles Text + Image) ---
  Future<void> updateUserProfile(String name, String phone, String email) async {
    isSaving.value = true;
    try {
      // 1. Call API Service
      final response = await _apiService.updateProfileMultipart(
      {
        'name': name,
        'phone': phone, 
        'email': email,
      },
      selectedImage.value,
    );

      // 2. Update local state
      user['name'] = name;
      user['phone'] = phone;
      user['email'] = email;

      // Update avatar if backend returned new one
      if (response['user'] != null && response['user']['profile_picture'] != null) {
        user['avatar'] = response['user']['profile_picture'];
      }
      
      user.refresh(); // Force the UI to update with the new values

      Get.back(); // Close the edit screen
      Get.snackbar(
        'Success', 
        'Profile updated successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
      );
      
      // Clear selected image to avoid showing it next time
      selectedImage.value = null; 
      
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      Get.snackbar(
        'Error', 
        'Failed to update profile',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> handleSitterSwitch() async {
    if (isSitter.value) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', 'sitter');
        Get.offAll(() => const SitterDashboard()); 
        Get.snackbar("Mode Switched", "Welcome back to Sitter Mode!");
      } catch (e) {
        Get.snackbar("Error", "Failed to switch mode");
      }
    } else {
      Get.to(() => const SitterRegistrationScreen());
    }
  }

  void resetState() {
    user.clear();
    selectedImage.value = null; // Reset image
    isSitter.value = false;
    isLoading.value = true;
    debugPrint('✅ ProfileController state reset');
  }
}