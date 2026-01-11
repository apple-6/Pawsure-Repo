// pawsure_app/lib/screens/activity/activity_history_screen.dart
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

  // ✅ CONSTANTS FROM HOME SCREEN
  final Color _backgroundColor = const Color(0xFFF9FAFB); // Soft off-white
  final Color _brandColor = const Color(0xFF22C55E); // Brand Green

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // ✅ Match Home background
      appBar: AppBar(
        backgroundColor: _backgroundColor, // ✅ Match Home AppBar
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Activity History',
          style: TextStyle(
            fontSize: 24, // ✅ Match Home Title Size
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          // Period Filter (Styled like a small button)
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.calendar_month_rounded,
                color: Colors.grey[700],
                size: 20,
              ),
              tooltip: 'Filter by Date',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              offset: const Offset(0, 45),
              onSelected: (value) {
                setState(() => _selectedPeriod = value);
              },
              itemBuilder: (context) =>
                  ['All Time', 'This Week', 'This Month', 'This Year']
                      .map(
                        (period) => PopupMenuItem(
                          value: period,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                period,
                                style: TextStyle(
                                  fontWeight: _selectedPeriod == period
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedPeriod == period
                                      ? _brandColor
                                      : Colors.black87,
                                ),
                              ),
                              if (_selectedPeriod == period)
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: _brandColor,
                                ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (Floating on the grey background)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildModernFilterChip('All', Icons.grid_view_rounded),
                  const SizedBox(width: 12),
                  _buildModernFilterChip('Walk', Icons.directions_walk_rounded),
                  const SizedBox(width: 12),
                  _buildModernFilterChip('Run', Icons.directions_run_rounded),
                ],
              ),
            ),
          ),

          // Activity List
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: _brandColor),
                );
              }

              if (_petController.selectedPet.value == null) {
                return const Center(child: Text('Please select a pet'));
              }

              // Filter Logic
              var activities = List.from(_controller.activities);

              // 1. Type Filter
              if (_selectedFilter != 'All') {
                activities = activities
                    .where(
                      (a) =>
                          a.activityType.toLowerCase() ==
                          _selectedFilter.toLowerCase(),
                    )
                    .toList();
              }

              // 2. Period Filter
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

              // Sort (Newest first)
              activities.sort(
                (a, b) => b.activityDate.compareTo(a.activityDate),
              );

              if (activities.isEmpty) {
                return _buildEmptyState();
              }

              // Group by Date
              final groupedActivities = _groupActivitiesByDate(activities);

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                physics: const BouncingScrollPhysics(),
                itemCount: groupedActivities.length,
                itemBuilder: (context, index) {
                  final dateGroup = groupedActivities[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Header (Text on Grey Background)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 4,
                          bottom: 8,
                          top: 12,
                        ),
                        child: Text(
                          dateGroup['date'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      // ✅ CARD STYLE: Activities inside a white rounded card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: List.generate(
                            dateGroup['activities'].length,
                            (i) {
                              final activity = dateGroup['activities'][i];
                              final isLast =
                                  i == dateGroup['activities'].length - 1;
                              return Column(
                                children: [
                                  ActivityListItem(activity: activity),
                                  if (!isLast)
                                    Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      color: Colors.grey[100],
                                      indent: 16,
                                      endIndent: 16,
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No activities found',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.w600,
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

  Widget _buildModernFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          // White background for inactive to pop off the grey scaffold
          color: isSelected ? _brandColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _brandColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: isSelected ? _brandColor : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[500],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
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
        dateKey = DateFormat('EEEE').format(activityDate);
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
