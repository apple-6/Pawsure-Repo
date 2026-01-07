//pawsure_app\lib\screens\activity\activity_history_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';
import 'package:pawsure_app/screens/activity/widgets/activity_list_item.dart';
import 'package:intl/intl.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final ActivityController _controller = Get.find<ActivityController>();
  final PetController _petController = Get.find<PetController>();

  String _selectedFilter = 'All';
  String _selectedPeriod = 'All Time';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        actions: [
          // Period filter
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
            },
            itemBuilder: (context) =>
                ['All Time', 'This Week', 'This Month', 'This Year']
                    .map(
                      (period) => PopupMenuItem(
                        value: period,
                        child: Row(
                          children: [
                            if (_selectedPeriod == period)
                              const Icon(Icons.check, size: 20),
                            if (_selectedPeriod == period)
                              const SizedBox(width: 8),
                            Text(period),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips - Walk, Run, All
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('All', Icons.list_alt),
                  _buildFilterChip('Walk', Icons.directions_walk),
                  _buildFilterChip('Run', Icons.directions_run),
                ],
              ),
            ),
          ),

          // Activity List
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_petController.selectedPet.value == null) {
                return const Center(child: Text('Please select a pet'));
              }

              // Get all activities
              var activities = List.from(_controller.activities);

              // Apply type filter
              if (_selectedFilter != 'All') {
                activities = activities
                    .where(
                      (a) =>
                          a.activityType.toLowerCase() ==
                          _selectedFilter.toLowerCase(),
                    )
                    .toList();
              }

              // Apply period filter
              final now = DateTime.now();
              switch (_selectedPeriod) {
                case 'This Week':
                  final startOfWeek = now.subtract(
                    Duration(days: now.weekday - 1),
                  );
                  activities = activities
                      .where(
                        (a) => a.activityDate.isAfter(
                          startOfWeek.subtract(const Duration(days: 1)),
                        ),
                      )
                      .toList();
                  break;
                case 'This Month':
                  activities = activities
                      .where(
                        (a) =>
                            a.activityDate.year == now.year &&
                            a.activityDate.month == now.month,
                      )
                      .toList();
                  break;
                case 'This Year':
                  activities = activities
                      .where((a) => a.activityDate.year == now.year)
                      .toList();
                  break;
              }

              // Sort by date (most recent first)
              activities.sort(
                (a, b) => b.activityDate.compareTo(a.activityDate),
              );

              if (activities.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No activities found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              // Group activities by date
              final groupedActivities = _groupActivitiesByDate(activities);

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedActivities.length,
                itemBuilder: (context, index) {
                  final dateGroup = groupedActivities[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Header
                      Padding(
                        padding: EdgeInsets.only(
                          left: 4,
                          bottom: 12,
                          top: index == 0 ? 0 : 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateGroup['date'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Activities for this date
                      ...dateGroup['activities'].map<Widget>((activity) {
                        return ActivityListItem(activity: activity);
                      }).toList(),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.orange : Colors.grey[600],
        ),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedFilter = label);
        },
        selectedColor: Colors.orange.withOpacity(0.2),
        checkmarkColor: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }

  List<Map<String, dynamic>> _groupActivitiesByDate(List activities) {
    final Map<String, List> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var activity in activities) {
      final activityDate = DateTime(
        activity.activityDate.year,
        activity.activityDate.month,
        activity.activityDate.day,
      );

      String dateKey;
      if (activityDate == today) {
        dateKey = 'Today';
      } else if (activityDate == yesterday) {
        dateKey = 'Yesterday';
      } else if (activityDate.isAfter(
        today.subtract(const Duration(days: 7)),
      )) {
        dateKey = DateFormat('EEEE').format(activityDate); // Day of week
      } else {
        dateKey = DateFormat('MMM d, yyyy').format(activityDate);
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(activity);
    }

    return grouped.entries
        .map((e) => {'date': e.key, 'activities': e.value})
        .toList();
  }
}
