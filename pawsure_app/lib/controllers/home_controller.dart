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
  
  // 🆕 Persistent State Storage (Per Pet ID)
  final Map<int, Map<String, int>> _petProgressStorage = {};
  final Map<int, Set<String>> _petLoggedMealsStorage = {};
  final Map<int, String> _petMoodStorage = {};

  // Daily Progress
  var dailyProgress = <String, int>{"walks": 0, "meals": 0, "wellbeing": 0}.obs;
  final Map<String, int> dailyGoals = {"walks": 2, "meals": 2, "wellbeing": 1};
  
  // 🆕 Meal tracking
  var loggedMeals = <String>{}.obs;

  // 🆕 Activity Stats
  var todayActivityStats = Rx<ActivityStats?>(null);
  var isLoadingActivityStats = false.obs;

  // 🆕 Track last loaded pet ID and date to prevent stale data
  int? _lastPetId;
  String? _lastLoadedDate;

  @override
  void onInit() {
    super.onInit();
    _lastLoadedDate = _getTodayString();
    _syncUserName();
    _observePetChanges();
  }

  String _getTodayString() => DateTime.now().toIso8601String().split('T')[0];

  void _checkAndResetForNewDay() {
    final today = _getTodayString();
    if (_lastLoadedDate != today) {
      debugPrint('☀️ New day detected! Resetting daily hub storage.');
      _petProgressStorage.clear();
      _petLoggedMealsStorage.clear();
      _petMoodStorage.clear();
      _lastLoadedDate = today;
    }
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
    // Initial load
    if (_petController.selectedPet.value != null) {
      final pet = _petController.selectedPet.value!;
      _checkAndResetForNewDay();
      _lastPetId = pet.id;
      _updatePetData(pet);
      loadTodayActivityStats(pet.id);
    }

    // Listen for changes
    ever(_petController.selectedPet, (Pet? pet) {
      if (pet != null) {
        _checkAndResetForNewDay();
        
        // 🛡️ CRITICAL FIX: Only reload if the PET ID changed.
        if (pet.id == _lastPetId && todayActivityStats.value != null) {
          currentStreak.value = pet.streak;
          return;
        }

        debugPrint('🔄 Pet switched to: ${pet.name} (ID: ${pet.id})');
        _lastPetId = pet.id;

        // Clear old stats immediately
        todayActivityStats.value = null;

        _updatePetData(pet);
        loadTodayActivityStats(pet.id);
      }
    });
  }

  /// Update data when pet is selected
  void _updatePetData(Pet pet) {
    int petId = pet.id;
    debugPrint('💾 Loading persistent state for pet ID: $petId');

    // 1. Load or Initialize Mood (Session fallback)
    if (_petMoodStorage.containsKey(petId)) {
      currentMood.value = _petMoodStorage[petId]!;
      todayMoodLogged.value = currentMood.value != "❓";
    } else {
      currentMood.value = "❓";
      todayMoodLogged.value = false;
    }

    // 2. Load or Initialize Progress (Session fallback)
    if (_petProgressStorage.containsKey(petId)) {
      dailyProgress.assignAll(_petProgressStorage[petId]!);
    } else {
      dailyProgress.assignAll({"walks": 0, "meals": 0, "wellbeing": 0});
    }

    // 3. Load or Initialize Logged Meals (Session fallback)
    if (_petLoggedMealsStorage.containsKey(petId)) {
      loggedMeals.assignAll(_petLoggedMealsStorage[petId]!);
    } else {
      loggedMeals.clear();
    }

    // Update streak from pet data (Source of truth)
    currentStreak.value = pet.streak;

    // Background sync with server
    _checkTodayMood(petId);
    _loadTodayMeals(petId);
  }

  /// 🆕 Load today's meals from API
  Future<void> _loadTodayMeals(int petId) async {
    try {
      final meals = await _apiService.getTodayMeals(petId);
      if (meals.isNotEmpty) {
        loggedMeals.assignAll(meals);
        dailyProgress['meals'] = meals.length;
        
        // Save to session storage
        _petLoggedMealsStorage[petId] = Set<String>.from(meals);
        _petProgressStorage[petId] = Map<String, int>.from(dailyProgress);
        dailyProgress.refresh();
      }
    } catch (e) {
      debugPrint('⚠️ Error loading today meals: $e');
    }
  }

  /// 🆕 Check if mood was logged today
  Future<void> _checkTodayMood(int petId) async {
    try {
      final todayMood = await _apiService.getTodayMood(petId);
      todayMoodLogged.value = todayMood != null;
      if (todayMood != null) {
        // Update progress
        dailyProgress['wellbeing'] = 1;
        
        // Update emoji based on the fetched mood
        if (todayMood is Map) {
             final score = todayMood['mood_score'] as int? ?? 5;
             if (score >= 8) currentMood.value = "😊";
             else if (score >= 5) currentMood.value = "😐";
             else currentMood.value = "😢";
        }
        
        // Save to storage
        _petMoodStorage[petId] = currentMood.value;
        _petProgressStorage[petId] = Map<String, int>.from(dailyProgress);
        dailyProgress.refresh();

        // Also refresh streak info to be sure
        loadStreakInfo(petId);
      }
    } catch (e) {
      debugPrint('⚠️ Error checking today mood: $e');
    }
  }

  /// 🆕 Load streak info from API
  Future<void> loadStreakInfo(int petId) async {
    try {
      final streakInfo = await _apiService.getStreakInfo(petId);
      final newStreak = streakInfo['currentStreak'] as int? ?? 0;
      currentStreak.value = newStreak;
      _petController.updatePetStreak(petId, newStreak);
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
      
      // Update walks progress from stats
      if (stats != null) {
          dailyProgress['walks'] = stats.totalActivities;
          _petProgressStorage[petId] = Map<String, int>.from(dailyProgress);
          dailyProgress.refresh();
          
          // Walks also update streak, so refresh it
          loadStreakInfo(petId);
      }

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
      await _loadTodayMeals(pet.id);
    }
  }

  /// 🆕 Calculate daily progress percentage
  int calculateDailyProgress() {
    final double walksProgress =
        (dailyProgress['walks'] ?? 0) / (dailyGoals['walks'] ?? 1);
    final double mealsProgress =
        (dailyProgress['meals'] ?? 0) / (dailyGoals['meals'] ?? 1);
    final double wellbeingProgress =
        (dailyProgress['wellbeing'] ?? 0) / (dailyGoals['wellbeing'] ?? 1);

    final double totalProgress =
        ((walksProgress + mealsProgress + wellbeingProgress) / 3)
            .clamp(0.0, 1.0);
    
    return (totalProgress * 100).round();
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
      
      // Update PetController globally
      _petController.updatePetStreak(pet.id, newStreak);

      // Update wellbeing progress
      dailyProgress['wellbeing'] = 1;
      
      // Save to storage
      _petMoodStorage[pet.id] = currentMood.value;
      _petProgressStorage[pet.id] = Map<String, int>.from(dailyProgress);
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

  /// 🆕 Log meal (local state only for now)
  Future<void> logMeal(String mealType) async {
    final pet = _petController.selectedPet.value;
    if (pet == null) return;

    if (loggedMeals.contains(mealType)) {
       Get.snackbar(
        "Already Logged",
        "You've already logged $mealType for today!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[800],
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      // Call API to log meal and get updated streak
      final result = await _apiService.logMeal(
        petId: pet.id,
        mealType: mealType,
      );

      final newStreak = result['streak'] as int? ?? 0;
      currentStreak.value = newStreak;
      
      // Update PetController globally
      _petController.updatePetStreak(pet.id, newStreak);

      final currentMeals = dailyProgress['meals'] ?? 0;
      
      // Increment meal count and add to set
      loggedMeals.add(mealType);
      dailyProgress['meals'] = currentMeals + 1;
      
      // Save to storage
      _petLoggedMealsStorage[pet.id] = Set<String>.from(loggedMeals);
      _petProgressStorage[pet.id] = Map<String, int>.from(dailyProgress);
      
      dailyProgress.refresh();
        
      Get.snackbar(
        "Meal Logged 🔥",
        "$mealType has been recorded! Current streak: $newStreak",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('❌ Error logging meal: $e');
      Get.snackbar(
        "Error",
        "Failed to save meal. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    }
  }

  /// Reset state (call on logout)
  void resetState() {
    currentMood.value = "❓";
    userName.value = "User";
    dailyProgress.assignAll({"walks": 0, "meals": 0, "wellbeing": 0});
    loggedMeals.clear();
    _petProgressStorage.clear();
    _petLoggedMealsStorage.clear();
    _petMoodStorage.clear();
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