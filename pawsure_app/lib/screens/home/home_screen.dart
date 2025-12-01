import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'widgets/pet_card.dart';
import 'widgets/upcoming_events.dart';
import 'widgets/quick_actions.dart';
import 'widgets/emergency_help_dialog.dart';
import 'widgets/pet_selector_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User';
  int _selectedPetIndex = 0;
  
  // Temporary pet data - will be replaced with actual data from backend
  final List<Map<String, dynamic>> _pets = [
    {
      'name': 'Max',
      'type': 'Dog',
      'emoji': '🐕',
      'mood': '?',
      'streak': 7,
      'walks': {'current': 1, 'total': 2},
      'meals': true,
      'wellbeing': true,
    },
    {
      'name': 'Luna',
      'type': 'Cat',
      'emoji': '🐈',
      'mood': '😊',
      'streak': 5,
      'walks': {'current': 0, 'total': 1},
      'meals': true,
      'wellbeing': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService().profile();
      if (profile != null && mounted) {
        setState(() {
          _userName = profile['name'] ?? 'User';
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _showPetSelector() {
    showDialog(
      context: context,
      builder: (context) => PetSelectorDialog(
        pets: _pets,
        selectedIndex: _selectedPetIndex,
        onPetSelected: (index) {
          setState(() {
            _selectedPetIndex = index;
          });
          Navigator.pop(context);
        },
        onAddPet: () {
          Navigator.pop(context);
          // TODO: Navigate to add pet screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add pet feature coming soon!')),
          );
        },
      ),
    );
  }

  void _showEmergencyHelp() {
    showDialog(
      context: context,
      builder: (context) => const EmergencyHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPet = _pets.isNotEmpty ? _pets[_selectedPetIndex] : null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Greeting and Pet Selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $_userName',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Pet Selector Button
                      InkWell(
                        onTap: _showPetSelector,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedPet?['emoji'] ?? '🐾',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                selectedPet?['name'] ?? 'Select Pet',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Emergency Help Button
                  GestureDetector(
                    onTap: _showEmergencyHelp,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Pet Card
              if (selectedPet != null)
                PetCard(pet: selectedPet),
              
              const SizedBox(height: 24),
              
              // Upcoming Events Section
              const UpcomingEventsSection(),
              
              const SizedBox(height: 24),
              
              // Quick Actions Section
              const QuickActionsSection(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
