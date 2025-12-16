// pawsure_app/lib/screens/health/health_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'tabs/profile_tab.dart';
import 'tabs/records_tab.dart';
import 'tabs/ai_scan_tab.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HealthController controller = Get.isRegistered<HealthController>()
        ? Get.find<HealthController>()
        : Get.put(HealthController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text(
          'Health',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        actions: [
          // Pet Selector Dropdown
          Obx(() {
            if (!controller.isLoadingPets.value && controller.pets.isNotEmpty) {
              return _PetSelectorDropdown(controller: controller);
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(width: 8),
          // Share Button
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Get.snackbar(
                  'Coming Soon',
                  'Share with Vet feature will be available soon!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  colorText: Colors.blue[800],
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              },
              icon: const Icon(
                Icons.share_outlined,
                size: 20,
                color: Color(0xFF6B7280),
              ),
              tooltip: 'Share with Vet',
            ),
          ),
        ],
        toolbarHeight: 64,
      ),
      body: Column(
        children: [
          // Tab Bar Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: controller.tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: const Color(0xFF1F2937),
                unselectedLabelColor: const Color(0xFF9CA3AF),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Records'),
                  Tab(text: 'AI Scan'),
                ],
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                ProfileTab(),
                Obx(() {
                  if (controller.selectedPet.value == null) {
                    return _EmptyStateView(
                      icon: Icons.pets,
                      title: 'No Pet Selected',
                      subtitle: 'Please add or select a pet first.',
                    );
                  }
                  return const RecordsTab();
                }),
                AIScanTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PetSelectorDropdown extends StatelessWidget {
  final HealthController controller;

  const _PetSelectorDropdown({required this.controller});

  String _getAnimalEmoji(Pet? pet) {
    if (pet == null) return '🐾';
    return pet.species?.toLowerCase() == 'dog' ? '🐕' : '🐈';
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Object>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_getAnimalEmoji(controller.selectedPet.value)} ${controller.selectedPet.value?.name ?? ""}',
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
                if (controller.selectedPet.value?.id == pet.id)
                  const Icon(
                    Icons.check,
                    size: 18,
                    color: Color(0xFF22C55E),
                  ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
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
  }
}

class _EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
