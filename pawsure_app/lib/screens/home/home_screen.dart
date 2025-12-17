// pawsure_app/lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/home/status_card.dart';
import '../../widgets/home/sos_button.dart';
import '../../widgets/home/upcoming_events_card.dart';
import '../../widgets/home/quick_actions_card.dart';
import '../../models/pet_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: Obx(
          () => Text(
            "Hello, ${controller.userName.value}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        actions: [
          // Pet Selector Dropdown with animal icons
          Obx(() {
            if (!controller.isLoadingPets.value && controller.pets.isNotEmpty) {
              return _PetSelectorDropdown(controller: controller);
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(width: 8),
          const SOSButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingPets.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF22C55E),
            ),
          );
        }

        if (controller.pets.isEmpty) {
          return _EmptyPetsView();
        }

        final pet = controller.selectedPet.value!;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Obx(() => StatusCard(
                      petName: pet.name,
                      petType: pet.species ?? 'Pet',
                      currentMood: controller.currentMood.value,
                      streak: pet.streak,
                      progress: controller.dailyProgress,
                      goals: controller.dailyGoals,
                    )),

                const SizedBox(height: 28),

                // Upcoming Events
                UpcomingEventsCard(petId: pet.id),

                const SizedBox(height: 28),

                // Quick Actions
                QuickActionsCard(
                  onLogWalk: () => _showLogWalkDialog(context, controller),
                  onRateMood: () => _showMoodBottomSheet(context, controller),
                  onAiScan: () => Get.toNamed('/health'),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/health'),
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 4,
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }

  void _showMoodBottomSheet(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'How is ${controller.selectedPet.value?.name ?? "your pet"} feeling?',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MoodOption(
                  emoji: '😊',
                  label: 'Happy',
                  color: const Color(0xFF22C55E),
                  onTap: () {
                    Navigator.pop(context);
                    controller.logMood('happy');
                  },
                ),
                _MoodOption(
                  emoji: '😐',
                  label: 'Neutral',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(context);
                    controller.logMood('neutral');
                  },
                ),
                _MoodOption(
                  emoji: '😢',
                  label: 'Sad',
                  color: const Color(0xFFEF4444),
                  onTap: () {
                    Navigator.pop(context);
                    controller.logMood('sad');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLogWalkDialog(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Log Walk',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _WalkDurationOption(
                  duration: '15',
                  label: 'Quick',
                  icon: Icons.directions_walk,
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    Navigator.pop(context);
                    _logWalk(controller, 15);
                  },
                ),
                _WalkDurationOption(
                  duration: '30',
                  label: 'Normal',
                  icon: Icons.pets,
                  color: const Color(0xFF22C55E),
                  onTap: () {
                    Navigator.pop(context);
                    _logWalk(controller, 30);
                  },
                ),
                _WalkDurationOption(
                  duration: '60+',
                  label: 'Long',
                  icon: Icons.hiking,
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(context);
                    _logWalk(controller, 60);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _logWalk(HomeController controller, int duration) {
    // Update walks progress
    final currentWalks = controller.dailyProgress['walks'] ?? 0;
    controller.dailyProgress['walks'] = currentWalks + 1;
    controller.dailyProgress.refresh();

    Get.snackbar(
      'Walk Logged! 🐕',
      '$duration min walk logged for ${controller.selectedPet.value?.name ?? "your pet"}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E).withOpacity(0.1),
      colorText: const Color(0xFF166534),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

class _PetSelectorDropdown extends StatelessWidget {
  final HomeController controller;

  const _PetSelectorDropdown({required this.controller});

  String _getAnimalEmoji(Pet? pet) {
    if (pet == null) return '🐾';
    return pet.species?.toLowerCase() == 'dog' ? '🐕' : '🐈';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedPet = controller.selectedPet.value;
      return PopupMenuButton<Object>(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_getAnimalEmoji(selectedPet)} ${selectedPet?.name ?? ""}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF6B7280),
                size: 20,
              ),
            ],
          ),
        ),
        tooltip: 'Switch Pet',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          if (value is Pet) {
            controller.selectPet(value);
          } else if (value == 'add_pet') {
            Get.toNamed('/profile/create-pet');
          }
        },
        itemBuilder: (context) => [
          // Pet list items
          ...controller.pets.map(
            (pet) => PopupMenuItem<Object>(
              value: pet,
              child: Row(
                children: [
                  Text(
                    pet.species?.toLowerCase() == 'dog' ? "🐕" : "🐈",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(pet.name)),
                  if (selectedPet?.id == pet.id)
                    const Icon(
                      Icons.check,
                      size: 18,
                      color: Color(0xFF22C55E),
                    ),
                ],
              ),
            ),
          ),
          // Divider
          const PopupMenuDivider(),
          // Add Pet option
          PopupMenuItem<Object>(
            value: 'add_pet',
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add Pet',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _EmptyPetsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐾', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No pets added yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first pet to get started!',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/profile/create-pet'),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Pet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodOption extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkDurationOption extends StatelessWidget {
  final String duration;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WalkDurationOption({
    required this.duration,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              '$duration min',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
