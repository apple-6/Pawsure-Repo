// pawsure_app/lib/screens/activity/widgets/activity_list_item.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawsure_app/models/activity_log_model.dart';
import 'package:pawsure_app/screens/activity/widgets/edit_activity_modal.dart';
import 'package:pawsure_app/screens/activity/tracking/route_view_screen.dart'; // 1. Added Import

class ActivityListItem extends StatelessWidget {
  final ActivityLog activity;

  const ActivityListItem({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showEditModal(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Activity Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _getActivityColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _getActivityColor().withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        activity.activityIcon,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title and Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title ?? activity.activityType.capitalize!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          // ✅ CRITICAL FIX: Convert UTC to local before formatting
                          DateFormat(
                            'MMM d, yyyy • h:mm a',
                          ).format(activity.activityDate.toLocal()),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Duration Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getActivityColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getActivityColor().withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      activity.formattedDuration,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _getActivityColor(),
                      ),
                    ),
                  ),
                ],
              ),

              // Stats Row
              if (activity.distanceKm != null ||
                  activity.caloriesBurned != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (activity.distanceKm != null)
                        _buildStatItem(
                          icon: Icons.straighten,
                          label: 'Distance',
                          value:
                              '${activity.distanceKm!.toStringAsFixed(2)} km',
                        ),
                      if (activity.distanceKm != null &&
                          activity.caloriesBurned != null)
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey[300],
                        ),
                      if (activity.caloriesBurned != null)
                        _buildStatItem(
                          icon: Icons.local_fire_department,
                          label: 'Calories',
                          value: '${activity.caloriesBurned} cal',
                        ),
                    ],
                  ),
                ),
              ],

              // Description
              if (activity.description != null &&
                  activity.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Route Badge - Clickable (2. Updated Section)
              if (activity.routeData != null &&
                  activity.routeData!.isNotEmpty) ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _showRouteOnMap(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.route, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 6),
                        Text(
                          'GPS Route Saved',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Color _getActivityColor() {
    switch (activity.activityType.toLowerCase()) {
      case 'walk':
        return Colors.blue;
      case 'run':
        return Colors.orange;
      case 'play':
        return Colors.purple;
      case 'swim':
        return Colors.cyan;
      case 'training':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditActivityModal(activity: activity),
    );
  }

  // 3. Added Navigation Method
  void _showRouteOnMap(BuildContext context) {
    Get.to(
      () => RouteViewScreen(activity: activity),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }
}
