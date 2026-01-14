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

    // ✅ Brand colors & Styles matching Activity History Screen
    const brandColor = Color(0xFF22C55E);
    const backgroundColor = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
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
          // Pet Selector
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
                child: Container(
                  // 1. Constrained width to prevent app bar overflow
                  constraints: const BoxConstraints(maxWidth: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      // 2. Flexible Text to prevent weird truncation
                      Flexible(
                        child: Text(
                          selectedPet?.name ?? 'Select',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                          overflow: TextOverflow.ellipsis,
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
      body: Column(
        children: [
          // 1. SCROLLABLE CONTENT (Stats, Filter, List)
          Expanded(
            child: Obx(() {
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

                  // Merged Filters (Left) + View All (Right)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        // Compact Filters
                        Obx(
                          () => Row(
                            children: [
                              _buildCompactFilter(
                                controller,
                                'All',
                                brandColor,
                              ),
                              const SizedBox(width: 8),
                              _buildCompactFilter(
                                controller,
                                'Walk',
                                brandColor,
                              ),
                              const SizedBox(width: 8),
                              _buildCompactFilter(
                                controller,
                                'Run',
                                brandColor,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // View All Button
                        TextButton.icon(
                          onPressed: () =>
                              Get.to(() => const ActivityHistoryScreen()),
                          icon: const Icon(Icons.history, size: 16),
                          label: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: brandColor, // ✅ Changed to Green
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(60, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
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
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final sortedActivities =
                          List.from(controller.filteredActivities)..sort(
                            (a, b) => b.activityDate.compareTo(a.activityDate),
                          );

                      final recentActivities = sortedActivities
                          .take(5)
                          .toList();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: recentActivities.length,
                        itemBuilder: (context, index) {
                          return ActivityListItem(
                            activity: recentActivities[index],
                          );
                        },
                      );
                    }),
                  ),
                ],
              );
            }),
          ),

          // 2. STICKY BOTTOM ACTION BAR (FIXED)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Manual Log Button
                // 3. Changed to Expanded(flex: 1) for equal width
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _showAddActivityModal(context);
                      if (Get.isRegistered<HomeController>()) {
                        Get.find<HomeController>().refreshHomeData();
                      }
                    },
                    icon: const Icon(Icons.edit_note, size: 20),
                    label: const Text(
                      'Manual Log',
                      overflow:
                          TextOverflow.ellipsis, // Protect against overflow
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Start Tracking Button
                // 4. Changed from flex: 2 to flex: 1 (50/50 split)
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Get.to(() => const GPSTrackingScreen());
                      if (Get.isRegistered<HomeController>()) {
                        Get.find<HomeController>().refreshHomeData();
                      }
                    },
                    icon: const Icon(Icons.directions_run, size: 20),
                    label: const Text(
                      'Start Tracking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom Compact Filter Widget
  Widget _buildCompactFilter(
    ActivityController controller,
    String label,
    Color color,
  ) {
    final isSelected = controller.selectedFilter.value == label;
    return GestureDetector(
      onTap: () => controller.setFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
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
