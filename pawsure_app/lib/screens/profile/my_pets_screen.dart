//pawsure_app\lib\screens\profile\my_pets_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/screens/profile/create_pet_profile_screen.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/controllers/navigation_controller.dart';
import 'package:pawsure_app/controllers/pet_controller.dart'; // 🔧 Changed to PetController

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

  // Load pets from database
  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔍 Loading pets from database...');
      final pets = await _apiService.getPets();
      debugPrint('✅ Loaded ${pets.length} pets');

      setState(() {
        _pets = pets;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading pets: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load pets: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🔧 FIXED: Refresh the global PetController (updates Home & Health automatically)
  void _refreshGlobalControllers() {
    if (Get.isRegistered<PetController>()) {
      final PetController petController = Get.find<PetController>();
      petController.loadPets(); // This updates both Home and Health screens
      debugPrint('✅ Global PetController refreshed');
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  /// Handles the confirmation and removal of a pet, calling the API.
  Future<void> _handleRemovePet(int petId, String petName) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Pet'),
        content: Text(
          'Are you sure you want to remove $petName from your pets?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        // 1. Call API to delete pet from the database
        await _apiService.deletePet(petId);

        // 2. 🔑 FIX: Refresh the global state (Home and Health screens)
        _refreshGlobalControllers();

        // 3. Remove locally from MyPetsScreen list
        setState(() {
          _pets.removeWhere((pet) => pet.id == petId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$petName has been removed'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove pet: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handlePetClick(Pet pet) {
    if (!_isEditMode) {
      // Get PetController
      final PetController petController = Get.find<PetController>();
      final NavigationController navController =
          Get.find<NavigationController>();

      // 🔧 FIXED: Select the pet globally (updates both Home and Health)
      petController.selectPet(pet);

      // Navigate to Health tab (index 1)
      navController.changePage(1);

      // Close the My Pets screen
      Navigator.of(context).pop();

      // Show success message
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

    // Refresh the pet list if a new pet was added
    if (result == true) {
      _loadPets();
      // Also refresh global state if a pet was added
      _refreshGlobalControllers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pet List Content
          CustomScrollView(
            slivers: [
              // Custom App Bar
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

              // Loading State
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),

              // Empty State
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
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button below to add your first pet',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Pet List Items
              if (!_isLoading && _pets.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 8.0,
                    bottom: 100,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      final pet = _pets[index];
                      return _buildPetCard(context, pet);
                    }, childCount: _pets.length),
                  ),
                ),
            ],
          ),

          // Fixed "Add Another Pet" Button
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

  /// Builds the Pet Card with robust image loading and fallback logic.
  Widget _buildPetCard(BuildContext context, Pet pet) {
    // 1. Improved URL Validation
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
                // --- FIXED PHOTO AREA ---
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
                            // Proper loading state
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            // Proper error state (Fallback to Initial)
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('❌ Image Load Error: $error');
                              return _buildInitialFallback(pet.name);
                            },
                          )
                        : _buildInitialFallback(pet.name),
                  ),
                ),
                const SizedBox(width: 16),

                // Pet Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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

                // Edit Mode Icon
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

  // Helper widget to show the first letter of the pet's name
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