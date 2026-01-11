// pawsure_app/lib/controllers/pet_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/services/api_service.dart';

/// 🎯 Centralized Pet Controller
/// This controller manages pet selection across the entire app.
/// When a pet is selected in any screen, all other screens update automatically.
class PetController extends GetxController {
  ApiService get _apiService => Get.find<ApiService>();

  // --- State Variables ---
  var pets = <Pet>[].obs;
  var selectedPet = Rx<Pet?>(null);
  var isLoadingPets = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPets();

    // Log pet changes for debugging
    ever(selectedPet, (Pet? pet) {
      if (pet != null) {
        debugPrint(
          '🐾 Global Pet Selection Changed: ${pet.name} (ID: ${pet.id})',
        );
      }
    });
  }

  /// Load all pets from the database
  Future<void> loadPets() async {
    try {
      isLoadingPets.value = true;
      debugPrint('🔍 PetController: Loading pets...');

      final fetchedPets = await _apiService.getPets();
      debugPrint('📦 PetController: Fetched ${fetchedPets.length} pets');

      if (fetchedPets.isNotEmpty) {
        pets.assignAll(fetchedPets);

        // Auto-select first pet if none selected or current selection is invalid
        if (selectedPet.value == null ||
            !fetchedPets.any((p) => p.id == selectedPet.value?.id)) {
          selectedPet.value = fetchedPets.first;
          debugPrint('✅ Auto-selected: ${fetchedPets.first.name}');
        } else {
          // Update the selected pet data if it still exists
          final updatedPet = fetchedPets.firstWhere(
            (p) => p.id == selectedPet.value?.id,
          );
          selectedPet.value = updatedPet;
          debugPrint('✅ Updated selected pet: ${updatedPet.name}');
        }
      } else {
        pets.clear();
        selectedPet.value = null;
        debugPrint('⚠️ No pets found');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading pets: $e');
      debugPrint('Stack trace: $stackTrace');
      pets.clear();
      selectedPet.value = null;
    } finally {
      isLoadingPets.value = false;
    }
  }

  /// Select a specific pet (updates globally across all screens)
  void selectPet(Pet pet) {
    if (selectedPet.value?.id != pet.id) {
      selectedPet.value = pet;
      debugPrint('✅ Pet selected: ${pet.name}');
    }
  }

  /// 🆕 Update a pet's streak in the list and if selected
  void updatePetStreak(int petId, int newStreak) {
    // 1. Update in the list
    final index = pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      pets[index] = pets[index].copyWith(streak: newStreak);
      debugPrint('🔥 Updated streak for ${pets[index].name} to $newStreak');
    }

    // 2. Update selectedPet if it's the same pet
    if (selectedPet.value?.id == petId) {
      selectedPet.value = selectedPet.value!.copyWith(streak: newStreak);
    }
  }

  /// Refresh pets from database
  Future<void> refreshPets() async {
    await loadPets();
  }

  /// Reset state (call on logout)
  void resetState() {
    pets.clear();
    selectedPet.value = null;
    isLoadingPets.value = true;
    debugPrint('✅ PetController state reset');
  }

  // Inside PetController
  String calculateAge(String? dobString) {
    if (dobString == null || dobString.isEmpty) return "N/A";

    try {
      // Convert the String dob into a DateTime object
      DateTime dob = DateTime.parse(dobString);
      DateTime now = DateTime.now();

      int years = now.year - dob.year;
      int months = now.month - dob.month;

      if (months < 0 || (months == 0 && now.day < dob.day)) {
        years--;
        months = (months < 0) ? months + 12 : months;
      }

      if (years == 0) return "$months m";
      return "${years}y ${months}m";
    } catch (e) {
      debugPrint("❌ Error parsing DOB string: $e");
      return "N/A";
    }
  }

  // 2. ADD: Booking Actions (Calling your NestJS backend)
  Future<void> acceptBooking(String bookingId) async {
    try {
      // await _apiService.updateBookingStatus(bookingId, 'accepted');
      Get.snackbar(
        "Success",
        "Booking accepted!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to accept booking");
    }
  }
}