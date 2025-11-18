import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/services/api_service.dart';

class HealthController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();

  // --- STATE VARIABLES ---

  // From health_screen.dart
  var pets = <Pet>[].obs;
  var selectedPet = Rx<Pet?>(null);
  var isLoadingPets = true.obs;

  // From records_tab.dart
  var healthRecords = <HealthRecord>[].obs; // This is the master list
  var filteredRecords = <HealthRecord>[].obs; // This is the list for the UI
  var isLoadingRecords = false.obs;
  var selectedFilter = 'All'.obs;

  // For the TabBar
  late TabController tabController;

  // --- LIFECYCLE & WORKERS ---

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    _fetchPets();

    // This is a GetX "worker"
    // It automatically listens to 'selectedPet' and runs a function when it changes.
    ever(selectedPet, (Pet? pet) {
      if (pet != null) {
        _fetchHealthRecords(pet.id);
      } else {
        healthRecords.clear();
        filteredRecords.clear();
      }
    });

    // This worker automatically re-runs the filter logic when the
    // master list or the filter string changes.
    everAll([healthRecords, selectedFilter], (_) {
      _updateFilteredRecords();
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // --- BUSINESS LOGIC ---

  // (Logic moved from _fetchPets() in health_screen.dart)
  Future<void> _fetchPets() async {
    try {
      isLoadingPets.value = true;
      final fetchedPets = await _apiService.getPets();
      if (fetchedPets.isNotEmpty) {
        pets.assignAll(fetchedPets);
        selectedPet.value =
            fetchedPets.first; // This will trigger the 'ever' worker
      }
    } catch (e) {
      debugPrint('Error loading pets: $e');
    } finally {
      isLoadingPets.value = false;
    }
  }

  // (Logic moved from _fetchHealthRecords() in records_tab.dart)
  Future<void> _fetchHealthRecords(int petId) async {
    try {
      isLoadingRecords.value = true;
      final records = await _apiService.getHealthRecords(petId);
      healthRecords.assignAll(records);
    } catch (e) {
      // Log detailed error for debugging
      debugPrint('Error fetching health records: $e');
      // Clear records on error
      healthRecords.clear();
      filteredRecords.clear();
    } finally {
      isLoadingRecords.value = false;
    }
  }

  // (Logic moved from _updateFilteredRecords() in records_tab.dart)
  void _updateFilteredRecords() {
    if (selectedFilter.value == 'All') {
      filteredRecords.assignAll(healthRecords);
    } else {
      filteredRecords.assignAll(
        healthRecords
            .where((record) => record.recordType == selectedFilter.value)
            .toList(),
      );
    }
  }

  // --- PUBLIC METHODS (for UI to call) ---

  // Called by the pet dropdown
  void selectPet(Pet? pet) {
    if (pet != null) {
      selectedPet.value = pet;
    }
  }

  // Called by the filter chips
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Called by AddHealthRecordScreen
  Future<void> addNewHealthRecord(
    Map<String, dynamic> payload,
    int petId,
  ) async {
    try {
      await _apiService.addHealthRecord(petId, payload);

      // Refresh the list after adding
      await _fetchHealthRecords(petId);

      Get.back(); // Go back to the previous screen
      Get.snackbar(
        'Success',
        'Health record added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add record: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
