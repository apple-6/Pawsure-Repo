// pawsure_app/lib/controllers/activity_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/activity_log_model.dart';
import 'package:pawsure_app/services/activity_service.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';

class ActivityController extends GetxController {
  final ActivityService _activityService = ActivityService();
  final PetController _petController = Get.find<PetController>();

  var activities = <ActivityLog>[].obs;
  var filteredActivities = <ActivityLog>[].obs;
  var isLoading = false.obs;
  var selectedFilter = 'All'.obs;
  var stats = Rx<ActivityStats?>(null);
  var selectedPeriod = 'week'.obs;

  @override
  void onInit() {
    super.onInit();
    // Watch for pet changes
    ever(_petController.selectedPet, (pet) {
      if (pet != null) {
        loadActivities(pet.id);
        loadStats(pet.id, selectedPeriod.value);
      }
    });

    // Watch for filter changes
    ever(selectedFilter, (_) => _applyFilter());
  }

  Future<void> loadActivities(
    int petId, {
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;
      final fetchedActivities = await _activityService.getActivities(
        petId,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );
      activities.assignAll(fetchedActivities);
      _applyFilter();
    } catch (e) {
      debugPrint('❌ Error loading activities: $e');
      Get.snackbar(
        'Error',
        'Failed to load activities',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats(int petId, String period) async {
    try {
      final fetchedStats = await _activityService.getStats(petId, period);
      stats.value = fetchedStats;
    } catch (e) {
      debugPrint('❌ Error loading stats: $e');
    }
  }

  Future<void> createActivity(int petId, Map<String, dynamic> payload) async {
    try {
      await _activityService.createActivity(petId, payload);
      await loadActivities(petId);
      await loadStats(petId, selectedPeriod.value);
      Get.back();
      Get.snackbar(
        'Success',
        'Activity added!',
        backgroundColor: Colors.green.withOpacity(0.1),
      );
    } catch (e) {
      debugPrint('❌ Error creating activity: $e');
      Get.snackbar(
        'Error',
        'Failed to add activity',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  Future<void> updateActivity(int id, Map<String, dynamic> payload) async {
    try {
      await _activityService.updateActivity(id, payload);
      if (_petController.selectedPet.value != null) {
        await loadActivities(_petController.selectedPet.value!.id);
      }
      Get.back();
      Get.snackbar(
        'Success',
        'Activity updated!',
        backgroundColor: Colors.green.withOpacity(0.1),
      );
    } catch (e) {
      debugPrint('❌ Error updating activity: $e');
      Get.snackbar(
        'Error',
        'Failed to update activity',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      await _activityService.deleteActivity(id);
      if (_petController.selectedPet.value != null) {
        await loadActivities(_petController.selectedPet.value!.id);
        await loadStats(
          _petController.selectedPet.value!.id,
          selectedPeriod.value,
        );
      }
      Get.snackbar(
        'Success',
        'Activity deleted',
        backgroundColor: Colors.green.withOpacity(0.1),
      );
    } catch (e) {
      debugPrint('❌ Error deleting activity: $e');
      Get.snackbar(
        'Error',
        'Failed to delete activity',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setPeriod(String period) {
    selectedPeriod.value = period;
    if (_petController.selectedPet.value != null) {
      loadStats(_petController.selectedPet.value!.id, period);
    }
  }

  void _applyFilter() {
    if (selectedFilter.value == 'All') {
      filteredActivities.assignAll(activities);
    } else {
      filteredActivities.assignAll(
        activities
            .where((a) => a.activityType == selectedFilter.value.toLowerCase())
            .toList(),
      );
    }
  }
}
