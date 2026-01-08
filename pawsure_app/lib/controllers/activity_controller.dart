//pawsure_app/lib/controllers/activity_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/services/activity_service.dart';
import 'package:pawsure_app/models/activity_log_model.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';

class ActivityController extends GetxController {
  final ActivityService _activityService = Get.put(ActivityService());
  final PetController _petController = Get.find<PetController>();

  var isLoading = false.obs;
  var activities = <ActivityLog>[].obs;
  var filteredActivities = <ActivityLog>[].obs;

  var todayStats = Rx<ActivityStats?>(null);
  var weekStats = Rx<ActivityStats?>(null);

  var selectedPeriod = 'week'.obs;
  var selectedFilter = 'All'.obs;

  // 🔧 FIX: Return Rx<ActivityStats?> so the UI can call .value on it
  Rx<ActivityStats?> get stats =>
      selectedPeriod.value == 'week' ? weekStats : todayStats;

  @override
  void onInit() {
    super.onInit();

    // Listen to pet changes
    ever(_petController.selectedPet, (pet) {
      if (pet != null) {
        debugPrint('🐾 ActivityController: Pet changed to ${pet.name}');
        loadActivities();
        loadTodayStats();
        loadWeekStats();
      } else {
        activities.clear();
        filteredActivities.clear();
        todayStats.value = null;
        weekStats.value = null;
      }
    });

    // Watch for filter changes
    ever(selectedFilter, (val) => applyFilter(val));

    // Initial load
    if (_petController.selectedPet.value != null) {
      loadActivities();
      loadTodayStats();
      loadWeekStats();
    }
  }

  Future<void> loadActivities() async {
    final pet = _petController.selectedPet.value;
    if (pet == null) return;

    try {
      isLoading.value = true;
      debugPrint('🔄 Loading activities for ${pet.name}...');

      final result = await _activityService.getActivities(pet.id);

      activities.value = result;
      applyFilter(selectedFilter.value);

      debugPrint('✅ Loaded ${result.length} activities');
    } catch (e) {
      debugPrint('❌ Error in loadActivities: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTodayStats() async {
    final pet = _petController.selectedPet.value;
    if (pet == null) return;
    try {
      todayStats.value = await _activityService.getStats(pet.id, 'day');
    } catch (e) {
      debugPrint('❌ Error loading today stats: $e');
    }
  }

  Future<void> loadWeekStats() async {
    final pet = _petController.selectedPet.value;
    if (pet == null) return;
    try {
      weekStats.value = await _activityService.getStats(pet.id, 'week');
    } catch (e) {
      debugPrint('❌ Error loading week stats: $e');
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void applyFilter(String filter) {
    if (filter == 'All') {
      filteredActivities.value = activities;
    } else {
      filteredActivities.value = activities
          .where(
            (activity) =>
                activity.activityType.toLowerCase() == filter.toLowerCase(),
          )
          .toList();
    }
    debugPrint(
      '🔧 Filter applied: $filter (${filteredActivities.length} items)',
    );
  }

  void setPeriod(String period) {
    selectedPeriod.value = period;
    // Optional: reload if needed
    final pet = _petController.selectedPet.value;
    if (pet != null) {
      if (period == 'day') {
        loadTodayStats();
      } else {
        loadWeekStats();
      }
    }
  }

  Future<void> createActivity(int petId, Map<String, dynamic> payload) async {
    try {
      await _activityService.createActivity(petId, payload);
      await loadActivities();
      await loadTodayStats();
      await loadWeekStats();
      Get.back();
      // 🔧 FIX: Updated deprecated withOpacity
      Get.snackbar(
        'Success',
        'Activity added!',
        backgroundColor: Colors.green.withValues(alpha: 0.1),
      );
    } catch (e) {
      debugPrint('❌ Create Error: $e');
      Get.snackbar(
        'Error',
        'Failed to add activity',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      );
    }
  }

  Future<void> updateActivity(int id, Map<String, dynamic> payload) async {
    try {
      await _activityService.updateActivity(id, payload);
      await loadActivities();
      Get.back();
      // 🔧 FIX: Updated deprecated withOpacity
      Get.snackbar(
        'Success',
        'Activity updated!',
        backgroundColor: Colors.green.withValues(alpha: 0.1),
      );
    } catch (e) {
      debugPrint('❌ Update Error: $e');
      Get.snackbar(
        'Error',
        'Failed to update activity',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      );
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      await _activityService.deleteActivity(id);
      await loadActivities();
      loadTodayStats();
      loadWeekStats();
      // 🔧 FIX: Updated deprecated withOpacity
      Get.snackbar(
        'Success',
        'Activity deleted',
        backgroundColor: Colors.green.withValues(alpha: 0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete activity',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      );
    }
  }
}
