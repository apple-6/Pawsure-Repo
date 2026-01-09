// pawsure_app/lib/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';
import 'package:pawsure_app/services/activity_service.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/models/activity_log_model.dart';

class HomeController extends GetxController {
  // 🔧 Use centralized PetController
  PetController get _petController => Get.find<PetController>();

  // 🆕 Activity Service
  final ActivityService _activityService = ActivityService();
  
  // 🆕 API Service for mood logging
  ApiService get _apiService => Get.find<ApiService>();

  // --- State Variables ---
  var currentMood = "❓".obs;
  var userName = "User".obs;

  // 🆕 Streak tracking
  var currentStreak = 0.obs;
  var todayMoodLogged = false.obs;
  var isLoggingMood = false.obs;

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
    // Update mood display based on pet's mood rating
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

    // Update streak from pet data
    currentStreak.value = pet.streak;

    // Check if mood was logged today
    _checkTodayMood(pet.id);

    // TODO: Fetch actual activity data from backend
    dailyProgress.value = {"walks": 1, "meals": 2, "wellbeing": 0};
  }

  /// 🆕 Check if mood was logged today
  Future<void> _checkTodayMood(int petId) async {
    try {
      final todayMood = await _apiService.getTodayMood(petId);
      todayMoodLogged.value = todayMood != null;
      if (todayMood != null) {
        dailyProgress['wellbeing'] = 1;
        dailyProgress.refresh();
      }
    } catch (e) {
      debugPrint('⚠️ Error checking today mood: $e');
    }
  }

  /// 🆕 Load streak info from API
  Future<void> loadStreakInfo(int petId) async {
    try {
      final streakInfo = await _apiService.getStreakInfo(petId);
      currentStreak.value = streakInfo['currentStreak'] as int? ?? 0;
      debugPrint('🔥 Current streak: ${currentStreak.value} days');
    } catch (e) {
      debugPrint('⚠️ Error loading streak info: $e');
    }
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

  /// 🆕 Log mood and save to backend
  Future<void> logMood(String mood) async {
    final pet = _petController.selectedPet.value;
    if (pet == null) {
      Get.snackbar(
        "No Pet Selected",
        "Please select a pet first",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[800],
      );
      return;
    }

    // Map mood string to score
    int moodScore;
    String moodEmoji;
    if (mood == 'happy') {
      moodScore = 8;
      moodEmoji = "😊";
    } else if (mood == 'neutral') {
      moodScore = 5;
      moodEmoji = "😐";
    } else {
      moodScore = 3;
      moodEmoji = "😢";
    }

    // Update UI immediately for responsiveness
    currentMood.value = moodEmoji;
    isLoggingMood.value = true;

    try {
      // Call API to log mood
      final result = await _apiService.logMood(
        petId: pet.id,
        moodScore: moodScore,
        moodLabel: mood,
      );

      // Update streak from response
      final newStreak = result['streak'] as int? ?? 0;
      currentStreak.value = newStreak;
      todayMoodLogged.value = true;

      // Update wellbeing progress
      dailyProgress['wellbeing'] = 1;
      dailyProgress.refresh();

      // Show success with streak info
      String streakMsg = newStreak > 1 
          ? "🔥 $newStreak day streak!" 
          : "Start your streak!";

      Get.snackbar(
        "Mood Logged! $streakMsg",
        "You logged $mood for ${pet.name}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
        duration: const Duration(seconds: 3),
      );

      debugPrint('✅ Mood logged successfully. Streak: $newStreak');
    } catch (e) {
      debugPrint('❌ Error logging mood: $e');
      Get.snackbar(
        "Error",
        "Failed to save mood. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    } finally {
      isLoggingMood.value = false;
    }
  }

  /// Reset state (call on logout)
  void resetState() {
    currentMood.value = "❓";
    userName.value = "User";
    dailyProgress.value = {"walks": 0, "meals": 0, "wellbeing": 0};
    todayActivityStats.value = null;
    isLoadingActivityStats.value = false;
    currentStreak.value = 0;
    todayMoodLogged.value = false;
    isLoggingMood.value = false;
    debugPrint('✅ HomeController state reset');
  }

  // ✅ ADDED THIS METHOD TO FIX THE ERROR
  // MainNavigation.dart calls this, but PetController handles loading now.
  // We keep this empty wrapper to satisfy the compiler.
  Future<void> loadPets() async {
    debugPrint(
      '⚠️ loadPets called in HomeController - delegated to PetController logic',
    );
  }
}
