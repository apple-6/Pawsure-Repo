// pawsure_app/lib/screens/profile/my_pets_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/screens/profile/create_pet_profile_screen.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/controllers/navigation_controller.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';
import 'package:pawsure_app/controllers/health_controller.dart'; // ✅ Import HealthController

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  final ApiService _apiService = Get.find<ApiService>();

  List<Pet> _pets = [];
  bool _isLoading = true;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pets = await _apiService.getPets();
      if (mounted) {
        setState(() {
          _pets = pets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load pets: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _refreshGlobalControllers() {
    if (Get.isRegistered<PetController>()) {
      Get.find<PetController>().loadPets();
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _handleRemovePet(int petId, String petName) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Pet'),
        content: Text('Are you sure you want to remove $petName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _apiService.deletePet(petId);
        _refreshGlobalControllers();
        setState(() {
          _pets.removeWhere((pet) => pet.id == petId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$petName removed'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // --- 🔧 FIXED FUNCTION ---
  void _handlePetClick(Pet pet) {
    if (!_isEditMode) {
      final PetController petController = Get.find<PetController>();
      final NavigationController navController =
          Get.find<NavigationController>();

      // 1. Select the pet globally
      petController.selectPet(pet);

      // 2. Reset Health Screen to Profile Tab (Index 0)
      if (Get.isRegistered<HealthController>()) {
        final HealthController healthController = Get.find<HealthController>();
        healthController.changeTab(0); // ✅ Uses the new helper method
        debugPrint('✅ Reset Health Screen to Profile Tab');
      }

      // 3. Navigate to Health tab (index 1 of main nav)
      navController.changePage(1);

      // 4. Close the My Pets screen
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Viewing ${pet.name}\'s health records'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleAddPet() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreatePetProfileScreen()),
    );
    if (result == true) {
      _loadPets();
      _refreshGlobalControllers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                title: const Text(
                  'My Pets',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  if (_pets.isNotEmpty)
                    TextButton(
                      onPressed: _toggleEditMode,
                      child: Text(
                        _isEditMode ? 'Done' : 'Edit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isEditMode
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_isLoading && _pets.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "You haven't added any pets yet",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_isLoading && _pets.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildPetCard(context, _pets[index]);
                    }, childCount: _pets.length),
                  ),
                ),
            ],
          ),

          // Fixed "Add Pet" Button (No flicker)
          if (!_isLoading)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: ElevatedButton.icon(
                  onPressed: _handleAddPet,
                  icon: const Icon(Icons.add, size: 24),
                  label: Text(
                    _pets.isEmpty ? 'Add Your First Pet' : 'Add Another Pet',
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, Pet pet) {
    final bool hasValidPhotoUrl =
        pet.photoUrl != null &&
        pet.photoUrl!.isNotEmpty &&
        pet.photoUrl!.startsWith('http') &&
        !pet.photoUrl!.contains('undefined');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: InkWell(
          onTap: () => _handlePetClick(pet),
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: hasValidPhotoUrl
                        ? Image.network(
                            pet.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) =>
                                _buildInitialFallback(pet.name),
                          )
                        : _buildInitialFallback(pet.name),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (pet.species != null && pet.breed != null)
                            ? '${pet.species} • ${pet.breed}'
                            : (pet.species ?? pet.breed ?? 'Pet'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isEditMode)
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                      size: 30,
                    ),
                    onPressed: () => _handleRemovePet(pet.id, pet.name),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialFallback(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'P',
        style: TextStyle(
          fontSize: 28,
          color: Colors.green.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
