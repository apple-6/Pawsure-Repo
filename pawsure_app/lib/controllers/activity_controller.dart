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
  // ✅ ADDED: Variable to store month stats
  var monthStats = Rx<ActivityStats?>(null);

  var selectedPeriod = 'week'.obs;
  var selectedFilter = 'All'.obs;

  // ✅ UPDATED: Logic to return correct stats based on selection
  Rx<ActivityStats?> get stats {
    switch (selectedPeriod.value) {
      case 'week':
        return weekStats;
      case 'month':
        return monthStats; // Returns the actual month stats
      case 'day':
      default:
        return todayStats;
    }
  }

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
        loadMonthStats(); // ✅ ADDED: Trigger load on pet change
      } else {
        activities.clear();
        filteredActivities.clear();
        todayStats.value = null;
        weekStats.value = null;
        monthStats.value = null; // ✅ ADDED: Clear month stats
      }
    });

    // Watch for filter changes
    ever(selectedFilter, (val) => applyFilter(val));

    // Initial load
    if (_petController.selectedPet.value != null) {
      loadActivities();
      loadTodayStats();
      loadWeekStats();
      loadMonthStats(); // ✅ ADDED: Trigger initial load
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

  // ✅ ADDED: Function to fetch month data from API
  Future<void> loadMonthStats() async {
    final pet = _petController.selectedPet.value;
    if (pet == null) return;
    try {
      monthStats.value = await _activityService.getStats(pet.id, 'month');
    } catch (e) {
      debugPrint('❌ Error loading month stats: $e');
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
    // ✅ UPDATED: Reload specific stat if needed
    final pet = _petController.selectedPet.value;
    if (pet != null) {
      if (period == 'day') {
        loadTodayStats();
      } else if (period == 'week') {
        loadWeekStats();
      } else if (period == 'month') {
        loadMonthStats();
      }
    }
  }

  // ✅ UPDATED: Accepts List<int> for multiple pets
  Future<void> createActivity(
    List<int> petIds,
    Map<String, dynamic> payload,
  ) async {
    try {
      await _activityService.createActivity(petIds, payload);
      await loadActivities(); // Refresh for all affected pets

      // Refresh stats for all pets (ensures charts stay updated)
      await loadTodayStats();
      await loadWeekStats();
      await loadMonthStats();

      Get.back();
      Get.snackbar(
        'Success',
        'Activity added for ${petIds.length} pet(s)!',
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
      // Added stats refresh to ensure accuracy after update
      await loadTodayStats();
      await loadWeekStats();
      await loadMonthStats();
      Get.back();
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
      loadMonthStats(); // ✅ ADDED: Refresh month stats
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
