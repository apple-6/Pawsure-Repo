// pawsure_app/lib/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';
import 'package:pawsure_app/services/activity_service.dart';
import 'package:pawsure_app/models/activity_log_model.dart';

class HomeController extends GetxController {
  // 🔧 Use centralized PetController
  PetController get _petController => Get.find<PetController>();

  // 🆕 Activity Service
  final ActivityService _activityService = ActivityService();

  // --- State Variables ---
  var currentMood = "❓".obs;
  var userName = "User".obs;

  // Daily Progress
  var dailyProgress = <String, int>{"walks": 0, "meals": 0, "wellbeing": 0}.obs;
  final Map<String, int> dailyGoals = {"walks": 2, "meals": 2, "wellbeing": 1};

  // 🆕 Activity Stats
  var todayActivityStats = Rx<ActivityStats?>(null);
  var isLoadingActivityStats = false.obs;

  @override
  void onInit() {
    super.onInit();
    _syncUserName();
    _observePetChanges();
  }

  /// Sync user name from ProfileController
  void _syncUserName() {
    try {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isRegistered<ProfileController>()) {
          final profileController = Get.find<ProfileController>();
          _updateUserNameFromProfile(profileController);
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
      userName.value = fullName.split(' ').first;
      debugPrint('✅ Username updated to: ${userName.value}');
    } else {
      userName.value = 'User';
      debugPrint('⚠️ No name found in profile, using default');
    }
  }

  /// 🆕 Observe pet changes from PetController
  void _observePetChanges() {
    // Initial load when first pet is available
    if (_petController.selectedPet.value != null) {
      final pet = _petController.selectedPet.value!;
      _updatePetData(pet);
      loadTodayActivityStats(pet.id);
    }

    // Listen for subsequent changes
    ever(_petController.selectedPet, (Pet? pet) {
      if (pet != null) {
        debugPrint('🔄 Pet changed to: ${pet.name} (ID: ${pet.id})');

        // Clear old stats immediately to avoid showing stale data
        todayActivityStats.value = null;

        _updatePetData(pet);
        loadTodayActivityStats(pet.id);
      }
    });
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

  /// 🆕 Load today's activity stats
  Future<void> loadTodayActivityStats(int petId) async {
    try {
      debugPrint('📊 Loading activity stats for pet ID: $petId');
      isLoadingActivityStats.value = true;

      final stats = await _activityService.getStats(petId, 'day');

      todayActivityStats.value = stats;
      debugPrint(
        '✅ Activity stats loaded: ${stats.totalActivities} activities, ${stats.totalDuration} min',
      );
    } catch (e) {
      debugPrint('❌ Error loading today\'s activity stats for pet $petId: $e');
      todayActivityStats.value = null;
    } finally {
      isLoadingActivityStats.value = false;
    }
  }

  /// 🆕 REFRESH METHOD: Call this to force a refresh of the home data
  Future<void> refreshHomeData() async {
    final pet = _petController.selectedPet.value;
    if (pet != null) {
      debugPrint('🔄 Refreshing home data for ${pet.name}...');
      await loadTodayActivityStats(pet.id);
    }
  }

  /// 🆕 Calculate daily progress percentage
  int calculateDailyProgress() {
    final stats = todayActivityStats.value;
    if (stats == null) return 0;

    // Define daily targets (customize as needed)
    const targetMinutes = 30; // 30 minutes of activity per day
    const targetActivities = 2; // At least 2 activities per day

    final minutesProgress = (stats.totalDuration / targetMinutes * 100).clamp(
      0,
      100,
    );
    final activitiesProgress = (stats.totalActivities / targetActivities * 100)
        .clamp(0, 100);

    // Average of both metrics
    return ((minutesProgress + activitiesProgress) / 2).round();
  }

  /// 🔧 Getters that delegate to PetController
  RxList<Pet> get pets => _petController.pets;
  Rx<Pet?> get selectedPet => _petController.selectedPet;
  RxBool get isLoadingPets => _petController.isLoadingPets;

  /// 🔧 Delegate pet selection to PetController
  void selectPet(Pet pet) {
    _petController.selectPet(pet);
  }

  /// Switch to next pet
  void switchPet() {
    if (_petController.pets.isEmpty) {
      Get.snackbar(
        'No Pets',
        'Add a pet first to switch between them',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final currentIndex = _petController.pets.indexWhere(
      (p) => p.id == _petController.selectedPet.value?.id,
    );
    final nextIndex = (currentIndex + 1) % _petController.pets.length;
    selectPet(_petController.pets[nextIndex]);
  }

  /// Log mood
  void logMood(String mood) {
    if (mood == 'happy') {
      currentMood.value = "😊";
    } else if (mood == 'neutral') {
      currentMood.value = "😐";
    } else if (mood == 'sad') {
      currentMood.value = "😢";
    }

    Get.snackbar(
      "Mood Logged",
      _petController.selectedPet.value != null
          ? "You logged $mood for ${_petController.selectedPet.value!.name}"
          : "Mood logged",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green[800],
    );
  }

  /// Reset state (call on logout)
  void resetState() {
    currentMood.value = "❓";
    userName.value = "User";
    dailyProgress.value = {"walks": 0, "meals": 0, "wellbeing": 0};
    todayActivityStats.value = null;
    isLoadingActivityStats.value = false;
    debugPrint('✅ HomeController state reset');
  }
}
