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
    // FIX: Safely find the controller, or create it if it's missing.
    // This prevents "HealthController not found" crashes.
    final HealthController controller = Get.isRegistered<HealthController>()
        ? Get.find<HealthController>()
        : Get.put(HealthController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // 1. Title reacts to selected pet
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
          // Display name of selected pet, or default text
          return Text(controller.selectedPet.value?.name ?? 'Select Pet');
        }),
        actions: [
          // 2. Dropdown menu to switch pets
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
                            // Show a checkmark next to the currently active pet
                            if (controller.selectedPet.value?.id == pet.id)
                              const Icon(Icons.check,
                                  size: 20, color: Colors.green),
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

          // Share Button (Placeholder)
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share with Vet feature coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.share_outlined, size: 20),
            label: const Text('Share'),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
        ],
        automaticallyImplyLeading: true,
        toolbarHeight: 64,
      ),
      body: Column(
        children: [
          // 3. Tab Bar Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F6F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: controller.tabController, // Connected to Controller
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
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

          // 4. Tab Views
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                // Assuming you have these widgets created in /tabs/
                ProfileTab(),

                // Wrap RecordsTab in Obx to handle null checks
                Obx(() {
                  if (controller.selectedPet.value == null) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pets, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Please add or select a pet first.'),
                        ],
                      ),
                    );
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
