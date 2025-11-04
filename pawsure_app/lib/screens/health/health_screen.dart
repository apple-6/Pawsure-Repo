import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'tabs/profile_tab.dart';
import 'tabs/records_tab.dart';
import 'tabs/calendar_tab.dart';
import 'tabs/ai_scan_tab.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller. Get.put() was already called in main_navigation.dart
    final HealthController controller = Get.find<HealthController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Wrap the title in Obx() to be reactive
        title: Obx(() {
          if (controller.isLoadingPets.value) {
            return const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          if (controller.pets.isEmpty) {
            return const Text('No Pets Available');
          }
          return Text(controller.selectedPet.value?.name ?? 'Select Pet');
        }),
        actions: [
          // Wrap PopupMenuButton in Obx() to react to pets list changes
          Obx(() {
            if (!controller.isLoadingPets.value && controller.pets.isNotEmpty) {
              return PopupMenuButton<Pet>(
                icon: const Icon(Icons.pets),
                onSelected: (Pet pet) {
                  controller.selectPet(pet);
                },
                itemBuilder: (context) => controller.pets
                    .map(
                      (pet) => PopupMenuItem<Pet>(
                        value: pet,
                        child: Row(
                          children: [
                            if (controller.selectedPet.value?.id == pet.id)
                              const Icon(Icons.check, size: 20),
                            const SizedBox(width: 8),
                            Text(pet.name),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            }
            return const SizedBox.shrink();
          }),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share with Vet feature coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.share_outlined, size: 20),
            label: const Text('Share with Vet'),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
        ],
        automaticallyImplyLeading: true,
        toolbarHeight: 64,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F6F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller:
                    controller.tabController, // Use controller's TabController
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Records'),
                  Tab(text: 'Calendar'),
                  Tab(text: 'AI Scan'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller:
                  controller.tabController, // Use controller's TabController
              children: [
                ProfileTab(),
                // RecordsTab no longer needs petId passed to it!
                // It will find the controller itself.
                Obx(() {
                  if (controller.selectedPet.value == null) {
                    return const Center(child: Text('Please select a pet.'));
                  }
                  return const RecordsTab();
                }),
                CalendarTab(),
                AIScanTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
