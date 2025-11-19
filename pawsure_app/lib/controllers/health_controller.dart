import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Keep your model imports.
// Ensure your Pet model 'id' is a String, not an int!
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/models/pet_model.dart';

class HealthController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // 1. Replace ApiService with direct Supabase Client
  final _supabase = Supabase.instance.client;

  // --- STATE VARIABLES ---

  // From health_screen.dart
  var pets = <Pet>[].obs;
  var selectedPet = Rx<Pet?>(null);
  var isLoadingPets = true.obs;

  // From records_tab.dart
  var healthRecords = <HealthRecord>[].obs; // Master list
  var filteredRecords = <HealthRecord>[].obs; // UI list
  var isLoadingRecords = false.obs;
  var selectedFilter = 'All'.obs;

  // For the TabBar
  late TabController tabController;

  // --- LIFECYCLE & WORKERS ---

  @override
  void onInit() {
    super.onInit();
    // Initialize TabController (4 tabs: Overview, Vaccine, Medical, etc.)
    tabController = TabController(length: 4, vsync: this);

    _fetchPets();

    // Worker: Listens to 'selectedPet' changes
    ever(selectedPet, (Pet? pet) {
      if (pet != null) {
        _fetchHealthRecords(pet.id);
      } else {
        healthRecords.clear();
        filteredRecords.clear();
      }
    });

    // Worker: Re-runs filter when data or filter type changes
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

  // 2. Fetch Pets directly from Supabase
  Future<void> _fetchPets() async {
    try {
      isLoadingPets.value = true;
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) return;

      // Fetch from 'pets' table
      final response =
          await _supabase.from('pets').select().eq('owner_id', userId);

      final List<dynamic> data = response;

      // Convert JSON to Pet Models
      final fetchedPets = data.map((json) => Pet.fromJson(json)).toList();

      if (fetchedPets.isNotEmpty) {
        pets.assignAll(fetchedPets);
        // Select the first pet automatically
        selectedPet.value = fetchedPets.first;
      }
    } catch (e) {
      debugPrint('Error loading pets: $e');
    } finally {
      isLoadingPets.value = false;
    }
  }

  // 3. Fetch Records directly from Supabase
  // NOTE: Changed petId type from int to String (Supabase UUIDs are strings)
  Future<void> _fetchHealthRecords(String petId) async {
    try {
      isLoadingRecords.value = true;

      // Fetch from 'health_records' table
      // Note: If you were using a 'vaccines' table before, ensure you have
      // migrated to a 'health_records' table, or change the table name below.
      final response = await _supabase
          .from('health_records')
          .select()
          .eq('pet_id', petId)
          .order('date', ascending: false); // Assuming 'date' column exists

      final List<dynamic> data = response;

      final records = data.map((json) => HealthRecord.fromJson(json)).toList();
      healthRecords.assignAll(records);
    } catch (e) {
      debugPrint('Error fetching health records: $e');
      healthRecords.clear();
      filteredRecords.clear();
    } finally {
      isLoadingRecords.value = false;
    }
  }

  // Filter Logic (Stays the same)
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

  // --- PUBLIC METHODS (for UI) ---

  void selectPet(Pet? pet) {
    if (pet != null) {
      selectedPet.value = pet;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  // 4. Add Record directly to Supabase
  Future<void> addNewHealthRecord(
    Map<String, dynamic> payload,
    String petId, // Changed to String
  ) async {
    try {
      // Ensure payload has the pet_id
      payload['pet_id'] = petId;

      await _supabase.from('health_records').insert(payload);

      // Refresh the list
      await _fetchHealthRecords(petId);

      Get.back();
      Get.snackbar(
        'Success',
        'Health record added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add record: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
