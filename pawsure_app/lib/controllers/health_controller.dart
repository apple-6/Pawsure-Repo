// pawsure_app/lib/controllers/health_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';

class HealthController extends GetxController
    with GetSingleTickerProviderStateMixin {
  ApiService get _apiService => Get.find<ApiService>();
  PetController get _petController => Get.find<PetController>();

  // --- STATE VARIABLES ---
  RxList<Pet> get pets => _petController.pets;
  Rx<Pet?> get selectedPet => _petController.selectedPet;
  RxBool get isLoadingPets => _petController.isLoadingPets;

  var healthRecords = <HealthRecord>[].obs;
  var filteredRecords = <HealthRecord>[].obs;
  var isLoadingRecords = false.obs;
  var selectedFilter = 'All'.obs;

  late TabController tabController;

  // --- LIFECYCLE ---
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);

    ever(_petController.selectedPet, (Pet? pet) {
      if (pet != null) {
        debugPrint('🐕 HealthController: Global pet changed to ${pet.name}');
        _fetchHealthRecords(pet.id);
      } else {
        healthRecords.clear();
        filteredRecords.clear();
      }
    });

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
  Future<void> _fetchHealthRecords(int petId) async {
    try {
      isLoadingRecords.value = true;
      final records = await _apiService.getHealthRecords(petId);
      healthRecords.assignAll(records);
    } catch (e) {
      debugPrint('❌ Error fetching health records: $e');
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
  }

  // --- PUBLIC METHODS ---

  /// ✅ NEW: Helper to switch tabs programmatically
  void changeTab(int index) {
    if (index >= 0 && index < tabController.length) {
      tabController.animateTo(index);
      debugPrint('🔄 HealthController: Switched to tab index $index');
    }
  }

  void selectPet(Pet? pet) {
    if (pet != null) {
      _petController.selectPet(pet);
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> addNewHealthRecord(
    Map<String, dynamic> payload,
    int petId,
  ) async {
    try {
      final newRecord = await _apiService.addHealthRecord(petId, payload);
      if (selectedPet.value?.id == petId) {
        healthRecords.add(newRecord);
        _updateFilteredRecords();
      }
      await _fetchHealthRecords(petId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshPets() async {
    await _petController.refreshPets();
  }

  Future<void> refreshHealthRecords() async {
    if (selectedPet.value != null) {
      await _fetchHealthRecords(selectedPet.value!.id);
    }
  }

  Future<void> fetchHealthRecords(int petId) async {
    await _fetchHealthRecords(petId);
  }

  void resetState() {
    healthRecords.clear();
    filteredRecords.clear();
    isLoadingRecords.value = false;
    selectedFilter.value = 'All';
    if (tabController.index != 0) {
      tabController.index = 0;
    }
  }

  Future<void> updateHealthRecord(
    int recordId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final updatedRecord = await _apiService.updateHealthRecord(
        recordId,
        payload,
      );
      final index = healthRecords.indexWhere((r) => r.id == recordId);
      if (index != -1) {
        healthRecords[index] = updatedRecord;
        _updateFilteredRecords();
      }
      if (selectedPet.value != null) {
        await _fetchHealthRecords(selectedPet.value!.id);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHealthRecord(int recordId) async {
    try {
      await _apiService.deleteHealthRecord(recordId);
      healthRecords.removeWhere((r) => r.id == recordId);
      _updateFilteredRecords();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadPets() async {
    try {
      await _petController.loadPets();
      if (selectedPet.value != null) {
        await _fetchHealthRecords(selectedPet.value!.id);
      }
    } catch (e) {
      debugPrint('❌ Error loading pets: $e');
    }
  }
}
