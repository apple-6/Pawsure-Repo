import 'package:flutter/material.dart';
import 'package:pawsure_app/screens/profile/create_pet_profile_screen.dart';

// 1. Define the Pet model (Data Structure)
class Pet {
  final String id;
  final String name;
  final String breed;
  final String? photoUrl;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    this.photoUrl,
  });
}

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  // 2. Initial Pet Data (State)
  List<Pet> _pets = [
    Pet(
      id: '1',
      name: 'Buddy',
      breed: 'Golden Retriever',
      photoUrl:
          'https://images.unsplash.com/photo-1633722715463-d30f4f325e24?w=200',
    ),
    Pet(
      id: '2',
      name: 'Luna',
      breed: 'Persian Cat',
      photoUrl: null, // Placeholder for no photo
    ),
    Pet(
      id: '3',
      name: 'Max',
      breed: 'German Shepherd',
      photoUrl:
          'https://images.unsplash.com/photo-1568572933382-74d440642117?w=200',
    ),
  ];

  bool _isEditMode = false;

  // 3. Handlers
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _handleRemovePet(String petId, String petName) {
    setState(() {
      _pets.removeWhere((pet) => pet.id == petId);
    });
    // Use a SnackBar for the "toast" equivalent in Flutter
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$petName has been removed from your pets.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePetClick(Pet pet) {
    if (!_isEditMode) {
      // Navigate to the pet's health screen
      // Assuming you have a route defined for '/owner/health'
      // Replace '/owner/health' with your actual route name
      Navigator.of(context).pushNamed('/owner/health', arguments: pet.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Switched to this pet\'s health records.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleAddPet() {
    // Navigate to the add pet screen (e.g., '/setup/owner')
    // Replace '/setup/owner' with your actual route name
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                const CreatePetProfileScreen(), // <-- NEW SCREEN
          ),
        )
        .then((_) {
          // Optional: Refresh the pet list if a new pet was added
        });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complete the setup to add another pet.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The Add Pet button will be fixed at the bottom
      body: Stack(
        children: [
          // Pet List Content
          CustomScrollView(
            slivers: [
              // 4. Custom App Bar
              SliverAppBar(
                automaticallyImplyLeading: false, // Remove default back button
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

              // 5. Pet List Items
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 8.0,
                  bottom: 100,
                ), // Bottom padding for fixed button
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

              if (_pets.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        "You haven't added any pets yet",
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // 6. Fixed "Add Another Pet" Button
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
                label: const Text(
                  'Add Another Pet',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green, // Matching the green button from the image
                  foregroundColor: Colors.white,
                  minimumSize: const Size(
                    double.infinity,
                    56,
                  ), // Full width, larger height
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
                // Pet Photo/Avatar
                CircleAvatar(
                  radius: 36,
                  backgroundColor: pet.photoUrl == null
                      ? Colors
                            .green
                            .shade100 // Fallback color for missing photo
                      : Colors.transparent,
                  backgroundImage: pet.photoUrl != null
                      ? NetworkImage(pet.photoUrl!)
                      : null,
                  child: pet.photoUrl == null
                      ? Text(
                          pet.name.isNotEmpty ? pet.name[0].toUpperCase() : 'P',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
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
                      Text(
                        pet.breed,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit Mode Icon (Remove/Drag Handle)
                if (_isEditMode)
                  // Remove Icon
                  pet.id != '100'
                      ? // You can add logic to prevent removing certain pets
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                            size: 30,
                          ),
                          onPressed: () {
                            _handleRemovePet(pet.id, pet.name);
                          },
                        )
                      // Drag Handle placeholder for reordering
                      : const Icon(Icons.drag_handle, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
