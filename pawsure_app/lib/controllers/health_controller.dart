// pawsure_app/lib/controllers/health_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/controllers/pet_controller.dart'; // 1. Import PetController

class HealthController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Get ApiService lazily
  ApiService get _apiService => Get.find<ApiService>();

  // 2. Inject the Central PetController
  PetController get _petController => Get.find<PetController>();

  // --- STATE VARIABLES ---

  // 3. Bridge state to PetController (Source of Truth)
  // Instead of maintaining separate lists, we point to the central ones.
  RxList<Pet> get pets => _petController.pets;
  Rx<Pet?> get selectedPet => _petController.selectedPet;
  RxBool get isLoadingPets => _petController.isLoadingPets;

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

    // 4. LISTEN TO GLOBAL PET CHANGES
    // When Home/Activity/PetController changes the pet, this fires automatically.
    ever(_petController.selectedPet, (Pet? pet) {
      if (pet != null) {
        debugPrint('🐕 HealthController: Global pet changed to ${pet.name}');
        _fetchHealthRecords(pet.id);
      } else {
        healthRecords.clear();
        filteredRecords.clear();
      }
    });

    // Initial Load: If a pet is already selected globally, load data immediately
    if (_petController.selectedPet.value != null) {
      _fetchHealthRecords(_petController.selectedPet.value!.id);
    }

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

  // Note: _fetchPets() is removed because PetController handles it.

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
        // Kept silent or minimal error handling to avoid noise during transitions
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
      // 5. Update Global Controller instead of local variable
      _petController.selectPet(pet);
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
      // selectedPet is now a getter, so this checks against the global pet
      if (selectedPet.value?.id == petId) {
        healthRecords.add(newRecord);
        _updateFilteredRecords();
        debugPrint('✅ HealthController: Added record to local state');
      }

      // Refresh from server to ensure sync
      await _fetchHealthRecords(petId);
      debugPrint('✅ HealthController: Health records refreshed from server');
    } catch (e, stackTrace) {
      debugPrint('❌ HealthController: Error adding health record: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> refreshPets() async {
    // Delegate to central controller
    await _petController.refreshPets();
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
    // 6. Only reset Health specific data.
    // Pet data is cleared by PetController.resetState() which AuthService calls.
    healthRecords.clear();
    filteredRecords.clear();
    isLoadingRecords.value = false;
    selectedFilter.value = 'All';

    if (tabController.index != 0) {
      tabController.index = 0;
    }

    debugPrint('✅ HealthController state reset');
  }

  /// 🆕 Update an existing health record
  Future<void> updateHealthRecord(
    int recordId,
    Map<String, dynamic> payload,
  ) async {
    try {
      debugPrint('🔄 HealthController: Updating health record $recordId...');
      debugPrint('📤 HealthController: Payload: $payload');

      // Call API service
      final updatedRecord = await _apiService.updateHealthRecord(
        recordId,
        payload,
      );
      debugPrint(
        '✅ HealthController: Record updated with ID: ${updatedRecord.id}',
      );

      // Update local state
      final index = healthRecords.indexWhere((r) => r.id == recordId);
      if (index != -1) {
        healthRecords[index] = updatedRecord;
        _updateFilteredRecords();
        debugPrint('✅ HealthController: Updated record in local state');
      }

      // Refresh from server to ensure sync
      if (selectedPet.value != null) {
        await _fetchHealthRecords(selectedPet.value!.id);
      }
      debugPrint('✅ HealthController: Health records refreshed from server');
    } catch (e, stackTrace) {
      debugPrint('❌ HealthController: Error updating health record: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 🆕 Delete a health record
  Future<void> deleteHealthRecord(int recordId) async {
    try {
      debugPrint('🗑️ HealthController: Deleting health record $recordId...');

      // Call API service
      await _apiService.deleteHealthRecord(recordId);
      debugPrint('✅ HealthController: Record deleted from server');

      // Remove from local state
      healthRecords.removeWhere((r) => r.id == recordId);
      _updateFilteredRecords();
      debugPrint('✅ HealthController: Removed record from local state');
    } catch (e, stackTrace) {
      debugPrint('❌ HealthController: Error deleting health record: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Loads pets from the database.
  /// 🔧 FIXED: Delegates to central PetController to ensure consistency.
  Future<void> loadPets() async {
    try {
      // Delegate to PetController which handles fetching and selection logic
      await _petController.loadPets();

      // If a pet is selected after load, ensure records are fetched
      if (selectedPet.value != null) {
        await _fetchHealthRecords(selectedPet.value!.id);
      }
    } catch (e) {
      debugPrint('❌ HealthController: Error loading pets (delegated): $e');
    }
  }
}
