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
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          // Dropdown menu to switch pets
          Obx(() {
            if (!controller.isLoadingPets.value && controller.pets.isNotEmpty) {
              final selectedPet = controller.selectedPet.value;
              final emoji = selectedPet?.species?.toLowerCase() == 'dog' ? '🐕' : '🐈';
              
              return PopupMenuButton<Pet>(
                onSelected: (Pet pet) {
                  controller.selectPet(pet);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                offset: const Offset(0, 45),
                itemBuilder: (context) => controller.pets
                    .map(
                      (pet) => PopupMenuItem<Pet>(
                        value: pet,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: controller.selectedPet.value?.id == pet.id
                                    ? const Color(0xFF22C55E).withOpacity(0.1)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  pet.species?.toLowerCase() == 'dog' ? '🐕' : '🐈',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                pet.name,
                                style: TextStyle(
                                  fontWeight: controller.selectedPet.value?.id == pet.id
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (controller.selectedPet.value?.id == pet.id)
                              const Icon(
                                Icons.check_circle,
                                size: 20,
                                color: Color(0xFF22C55E),
                              ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedPet?.name ?? 'Select',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Share Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share with Vet feature coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.share_outlined, size: 20, color: Color(0xFF6B7280)),
              tooltip: 'Share with Vet',
            ),
          ),
        ],
        toolbarHeight: 64,
      ),
      body: Column(
        children: [
          // 🎨 IMPROVED TAB BAR: Better pill-shaped indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F6F9),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(4), // Padding around tabs
              child: TabBar(
                controller: controller.tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // Smoother radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent, // Remove divider line
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                labelPadding: EdgeInsets.zero, // Remove extra padding
                tabs: const [
                  Tab(height: 40, child: Center(child: Text('Profile'))),
                  Tab(height: 40, child: Center(child: Text('Records'))),
                  Tab(height: 40, child: Center(child: Text('AI Scan'))),
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

                AIScanTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
