// pawsure_app/lib/controllers/health_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/services/api_service.dart';

class HealthController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Get ApiService lazily
  ApiService get _apiService => Get.find<ApiService>();

  // --- STATE VARIABLES ---
  var pets = <Pet>[].obs;
  var selectedPet = Rx<Pet?>(null);
  var isLoadingPets = true.obs;

  var healthRecords = <HealthRecord>[].obs;
  var filteredRecords = <HealthRecord>[].obs;
  var isLoadingRecords = false.obs;
  var selectedFilter = 'All'.obs;

  late TabController tabController;

  // --- LIFECYCLE & WORKERS ---

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    _fetchPets();

    ever(selectedPet, (Pet? pet) {
      if (pet != null) {
        debugPrint('🐕 Selected pet: ${pet.name}, ID: ${pet.id}');
        _fetchHealthRecords(pet.id);
      } else {
        healthRecords.clear();
        filteredRecords.clear();
      }
    });

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

  Future<void> _fetchPets() async {
    try {
      isLoadingPets.value = true;
      debugPrint('🔍 Fetching pets from API...');

      final fetchedPets = await _apiService.getPets();
      debugPrint('📦 Fetched ${fetchedPets.length} pets');

      if (fetchedPets.isNotEmpty) {
        pets.assignAll(fetchedPets);
        selectedPet.value = fetchedPets.first;
        debugPrint('✅ Selected first pet: ${fetchedPets.first.name}');
      } else {
        debugPrint('⚠️ No pets found');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading pets: $e');
      debugPrint('Stack trace: $stackTrace');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          'Failed to load pets: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } finally {
      isLoadingPets.value = false;
    }
  }

  Future<void> _fetchHealthRecords(int petId) async {
    try {
      isLoadingRecords.value = true;
      debugPrint('🔍 Fetching health records for pet ID: $petId');

      final records = await _apiService.getHealthRecords(petId);
      debugPrint('📦 Fetched ${records.length} health records');

      healthRecords.assignAll(records);
      debugPrint('✅ Assigned ${records.length} records to state');
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching health records: $e');
      debugPrint('Stack trace: $stackTrace');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          'Failed to load health records',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });

      healthRecords.clear();
      filteredRecords.clear();
    } finally {
      isLoadingRecords.value = false;
    }
  }

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
    debugPrint(
      '🔧 Filtered to ${filteredRecords.length} records (filter: ${selectedFilter.value})',
    );
  }

  // --- PUBLIC METHODS ---

  void selectPet(Pet? pet) {
    if (pet != null) {
      selectedPet.value = pet;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  /// 🔧 FIXED: Add new health record (no snackbars, just save)
  Future<void> addNewHealthRecord(
    Map<String, dynamic> payload,
    int petId,
  ) async {
    try {
      debugPrint('➕ HealthController: Adding health record for pet ID: $petId');
      debugPrint('📤 HealthController: Payload: $payload');

      // Call API service
      final newRecord = await _apiService.addHealthRecord(petId, payload);
      debugPrint('✅ HealthController: Record created with ID: ${newRecord.id}');

      // Add to local state immediately for instant feedback
      if (selectedPet.value?.id == petId) {
        healthRecords.add(newRecord);
        _updateFilteredRecords();
        debugPrint('✅ HealthController: Added record to local state');
      }

      // Refresh from server to ensure sync
      await _fetchHealthRecords(petId);
      debugPrint('✅ HealthController: Health records refreshed from server');

      // 🔧 CRITICAL: Don't call Get.back() or show snackbar here!
      // Let the screen handle all UI feedback and navigation
    } catch (e, stackTrace) {
      debugPrint('❌ HealthController: Error adding health record: $e');
      debugPrint('Stack trace: $stackTrace');

      // Rethrow to let the screen handle the error
      rethrow;
    }
  }

  Future<void> refreshPets() async {
    await _fetchPets();
  }

  Future<void> refreshHealthRecords() async {
    if (selectedPet.value != null) {
      await _fetchHealthRecords(selectedPet.value!.id);
    }
  }

  /// 🔧 ENHANCED: Fetch health records for a specific pet (used by prefill)
  Future<void> fetchHealthRecords(int petId) async {
    await _fetchHealthRecords(petId);
  }

  /// Reset controller state (call after logout)
  void resetState() {
    pets.clear();
    selectedPet.value = null;
    healthRecords.clear();
    filteredRecords.clear();
    isLoadingPets.value = true;
    isLoadingRecords.value = false;
    selectedFilter.value = 'All';

    if (tabController.index != 0) {
      tabController.index = 0;
    }

    debugPrint('✅ HealthController state reset');

    // Fetch fresh data
    _fetchPets();
  }
}
