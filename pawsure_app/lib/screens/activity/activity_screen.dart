// pawsure_app/lib/screens/activity/activity_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';
import 'package:pawsure_app/screens/activity/widgets/activity_stats_card.dart';
import 'package:pawsure_app/screens/activity/widgets/activity_list_item.dart';
import 'package:pawsure_app/screens/activity/widgets/add_activity_modal.dart';
import 'package:pawsure_app/screens/activity/tracking/gps_tracking_screen.dart';

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

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Obx(
                () => Row(
                  children: [
                    _buildFilterChip(controller, 'All'),
                    _buildFilterChip(controller, 'Walk'),
                    _buildFilterChip(controller, 'Run'),
                    _buildFilterChip(controller, 'Play'),
                    _buildFilterChip(controller, 'Swim'),
                    _buildFilterChip(controller, 'Training'),
                  ],
                ),
              ),
            ),

            // Activity List
            Expanded(
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
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Track your first activity!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredActivities.length,
                  itemBuilder: (context, index) {
                    return ActivityListItem(
                      activity: controller.filteredActivities[index],
                    );
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
            onPressed: () => Get.to(() => const GPSTrackingScreen()),
            backgroundColor: Colors.orange,
            icon: const Icon(Icons.gps_fixed),
            label: const Text('Start Tracking'),
          ),
          const SizedBox(height: 12),
          // Manual Add Button
          FloatingActionButton(
            heroTag: 'manual',
            onPressed: () => _showAddActivityModal(context),
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

  void _showAddActivityModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddActivityModal(),
    );
  }
}
