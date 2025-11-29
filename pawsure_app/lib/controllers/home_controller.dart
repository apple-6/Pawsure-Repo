// pawsure_app/lib/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';

class HomeController extends GetxController {
  ApiService get _apiService => Get.find<ApiService>();

  // --- State Variables ---
  var pets = <Pet>[].obs;
  var selectedPet = Rx<Pet?>(null);
  var isLoadingPets = true.obs;

  var currentMood = "❓".obs;
  var userName = "User".obs;

  // Daily Progress
  var dailyProgress = <String, int>{"walks": 0, "meals": 0, "wellbeing": 0}.obs;
  final Map<String, int> dailyGoals = {"walks": 2, "meals": 2, "wellbeing": 1};

  @override
  void onInit() {
    super.onInit();
    loadPets();
    _syncUserName();
  }

  /// Sync user name from ProfileController
  void _syncUserName() {
    try {
      // Wait a bit for ProfileController to initialize
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isRegistered<ProfileController>()) {
          final profileController = Get.find<ProfileController>();

          // Set initial value
          _updateUserNameFromProfile(profileController);

          // Listen for changes
          ever(profileController.user, (_) {
            _updateUserNameFromProfile(profileController);
          });
        } else {
          debugPrint('⚠️ ProfileController not registered');
        }
      });
    } catch (e) {
      debugPrint('❌ Error syncing user name: $e');
    }
  }

  /// Helper method to update username from profile
  void _updateUserNameFromProfile(ProfileController profileController) {
    final fullName = profileController.user['name'] as String?;
    if (fullName != null && fullName.isNotEmpty) {
      // Extract first name
      userName.value = fullName.split(' ').first;
      debugPrint('✅ Username updated to: ${userName.value}');
    } else {
      userName.value = 'User';
      debugPrint('⚠️ No name found in profile, using default');
    }
  }

  /// Load pets from database
  Future<void> loadPets() async {
    try {
      isLoadingPets.value = true;
      debugPrint('🏠 Loading pets for home screen...');

      final fetchedPets = await _apiService.getPets();
      debugPrint('📦 Loaded ${fetchedPets.length} pets');

      if (fetchedPets.isNotEmpty) {
        pets.assignAll(fetchedPets);
        // Only reset selectedPet if it wasn't already set or is invalid
        if (selectedPet.value == null ||
            !fetchedPets.any((p) => p.id == selectedPet.value?.id)) {
          selectedPet.value = fetchedPets.first;
          _updatePetData(fetchedPets.first);
        }
      } else {
        pets.clear();
        selectedPet.value = null;
      }
    } catch (e) {
      debugPrint('❌ Error loading pets: $e');
      pets.clear();
      selectedPet.value = null;
    } finally {
      isLoadingPets.value = false;
    }
  }

  /// Update data when pet is selected
  void _updatePetData(Pet pet) {
    if (pet.moodRating != null) {
      if (pet.moodRating! >= 8) {
        currentMood.value = "😊";
      } else if (pet.moodRating! >= 5) {
        currentMood.value = "😐";
      } else {
        currentMood.value = "😢";
      }
    } else {
      currentMood.value = "❓";
    }

    // TODO: Fetch actual activity data from backend
    dailyProgress.value = {"walks": 1, "meals": 2, "wellbeing": 0};
  }

  /// Switch to next pet
  void switchPet() {
    if (pets.isEmpty) {
      Get.snackbar(
        'No Pets',
        'Add a pet first to switch between them',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final currentIndex = pets.indexWhere((p) => p.id == selectedPet.value?.id);
    final nextIndex = (currentIndex + 1) % pets.length;
    selectPet(pets[nextIndex]);
  }

  /// Select a specific pet
  void selectPet(Pet pet) {
    selectedPet.value = pet;
    _updatePetData(pet);
    debugPrint('🐕 Switched to ${pet.name}');
  }

  /// Log mood
  void logMood(String mood) {
    if (mood == 'happy')
      currentMood.value = "😊";
    else if (mood == 'neutral')
      currentMood.value = "😐";
    else if (mood == 'sad')
      currentMood.value = "😢";

    Get.snackbar(
      "Mood Logged",
      selectedPet.value != null
          ? "You logged $mood for ${selectedPet.value!.name}"
          : "Mood logged",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green[800],
    );
  }

  /// Reset state (call on logout)
  void resetState() {
    pets.clear();
    selectedPet.value = null;
    currentMood.value = "❓";
    userName.value = "User";
    dailyProgress.value = {"walks": 0, "meals": 0, "wellbeing": 0};
    isLoadingPets.value = true;
    debugPrint('✅ HomeController state reset');
  }
}
