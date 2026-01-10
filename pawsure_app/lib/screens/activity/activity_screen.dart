// pawsure_app/lib/screens/activity/activity_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';
import 'package:pawsure_app/controllers/home_controller.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/screens/activity/widgets/activity_stats_card.dart';
import 'package:pawsure_app/screens/activity/widgets/activity_list_item.dart';
import 'package:pawsure_app/screens/activity/widgets/add_activity_modal.dart';
import 'package:pawsure_app/screens/activity/tracking/gps_tracking_screen.dart';
import 'package:pawsure_app/screens/activity/activity_history_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ActivityController controller = Get.find<ActivityController>();
    final PetController petController = Get.find<PetController>();

    // Brand colors & Styles matching Home Screen
    const brandColor = Color(0xFF22C55E);
    const backgroundColor = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: backgroundColor, // ✅ Consistent off-white background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor, // ✅ Flat AppBar matching background
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Activity Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        actions: [
          // ✅ Pet Selector (Matches Home Screen "Pill" style)
          Obx(() {
            if (petController.pets.isNotEmpty) {
              final selectedPet = petController.selectedPet.value;
              final emoji = selectedPet?.species?.toLowerCase() == 'dog'
                  ? '🐕'
                  : '🐈';

              return PopupMenuButton<Pet>(
                tooltip: 'Switch Pet',
                offset: const Offset(0, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (Pet pet) {
                  petController.selectPet(pet);
                },
                // The Trigger Button (Capsule Style)
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6), // Matching Home Screen grey
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 18)),
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
                // Dropdown Items
                itemBuilder: (context) => petController.pets
                    .map(
                      (pet) => PopupMenuItem<Pet>(
                        value: pet,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color:
                                    petController.selectedPet.value?.id ==
                                        pet.id
                                    ? brandColor.withOpacity(0.1)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  pet.species?.toLowerCase() == 'dog'
                                      ? '🐕'
                                      : '🐈',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                pet.name,
                                style: TextStyle(
                                  fontWeight:
                                      petController.selectedPet.value?.id ==
                                          pet.id
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (petController.selectedPet.value?.id == pet.id)
                              const Icon(
                                Icons.check_circle,
                                size: 20,
                                color: brandColor,
                              ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (petController.selectedPet.value == null) {
          return const Center(child: Text('Please select a pet'));
        }

        return Column(
          children: [
            // Statistics Card
            const ActivityStatsCard(),

            // Filter Chips - Only Walk and Run
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Obx(
                () => Row(
                  children: [
                    _buildFilterChip(controller, 'All'),
                    _buildFilterChip(controller, 'Walk'),
                    _buildFilterChip(controller, 'Run'),
                  ],
                ),
              ),
            ),

            // Recent Activities Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        Get.to(() => const ActivityHistoryScreen()),
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('View All'),
                    style: TextButton.styleFrom(foregroundColor: Colors.orange),
                  ),
                ],
              ),
            ),

            // Activity List - Show only last 5 activities
            Flexible(
              child: Obx(() {
                if (controller.filteredActivities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_walk,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No activities yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Track your first activity!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sort activities by date (most recent first) and take only 5
                final sortedActivities = List.from(
                  controller.filteredActivities,
                )..sort((a, b) => b.activityDate.compareTo(a.activityDate));

                final recentActivities = sortedActivities.take(5).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recentActivities.length,
                  itemBuilder: (context, index) {
                    return ActivityListItem(activity: recentActivities[index]);
                  },
                );
              }),
            ),
          ],
        );
      }),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Start GPS Tracking Button
          FloatingActionButton.extended(
            heroTag: 'gps',
            onPressed: () async {
              await Get.to(() => const GPSTrackingScreen());
              if (Get.isRegistered<HomeController>()) {
                Get.find<HomeController>().refreshHomeData();
              }
            },
            backgroundColor: Colors.orange,
            icon: const Icon(Icons.gps_fixed),
            label: const Text('Start Tracking'),
          ),
          const SizedBox(height: 12),
          // Manual Add Button
          FloatingActionButton(
            heroTag: 'manual',
            onPressed: () async {
              await _showAddActivityModal(context);
              if (Get.isRegistered<HomeController>()) {
                Get.find<HomeController>().refreshHomeData();
              }
            },
            backgroundColor: brandColor, // Consistent Green
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED: Cleaner Filter Chips
  Widget _buildFilterChip(ActivityController controller, String label) {
    final isSelected = controller.selectedFilter.value == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.orange.shade900 : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => controller.setFilter(label),
        backgroundColor: Colors.white,
        selectedColor: Colors.orange.withOpacity(0.2),
        checkmarkColor: Colors.orange,
        shape: const StadiumBorder(side: BorderSide.none), // Cleaner look
        elevation: 0,
      ),
    );
  }

  Future<void> _showAddActivityModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddActivityModal(),
    );
  }
}
