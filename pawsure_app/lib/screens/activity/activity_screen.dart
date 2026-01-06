// pawsure_app/lib/screens/activity/activity_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';
import 'package:pawsure_app/controllers/home_controller.dart'; // 🆕 IMPORTED
import 'package:pawsure_app/controllers/pet_controller.dart';
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Activity Tracker'),
        actions: [
          // Pet Selector
          Obx(() {
            if (petController.pets.isNotEmpty) {
              return PopupMenuButton(
                icon: const Icon(Icons.pets),
                onSelected: (pet) => petController.selectPet(pet),
                itemBuilder: (context) => petController.pets
                    .map(
                      (pet) => PopupMenuItem(
                        value: pet,
                        child: Row(
                          children: [
                            if (petController.selectedPet.value?.id == pet.id)
                              const Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.green,
                              ),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            // 🆕 FIX: Await GPS screen result, then refresh Home data
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
            // 🆕 FIX: Await Modal result, then refresh Home data
            onPressed: () async {
              await _showAddActivityModal(context);
              if (Get.isRegistered<HomeController>()) {
                Get.find<HomeController>().refreshHomeData();
              }
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ActivityController controller, String label) {
    final isSelected = controller.selectedFilter.value == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.setFilter(label),
        selectedColor: Colors.orange.withOpacity(0.2),
        checkmarkColor: Colors.orange,
      ),
    );
  }

  // 🆕 FIX: Changed to return Future<void> so we can await it
  Future<void> _showAddActivityModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddActivityModal(),
    );
  }
}
