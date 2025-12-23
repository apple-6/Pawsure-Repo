import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawsure_app/models/activity_log_model.dart';
import 'package:pawsure_app/screens/activity/widgets/edit_activity_modal.dart';

class ActivityListItem extends StatelessWidget {
  final ActivityLog activity;

  const ActivityListItem({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEditModal(context),
        borderRadius: BorderRadius.circular(12),
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getActivityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        activity.activityIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title ?? activity.activityType.capitalize!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'MMM d, yyyy • h:mm a',
                          ).format(activity.activityDate),
                          style: TextStyle(
                            fontSize: 12,
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
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getActivityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getActivityColor().withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      activity.formattedDuration,
                      style: TextStyle(
                        fontSize: 12,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (activity.distanceKm != null) ...[
                      Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${activity.distanceKm!.toStringAsFixed(2)} km',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (activity.caloriesBurned != null) ...[
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${activity.caloriesBurned} cal',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ],
                ),
              ],

              // Description
              if (activity.description != null &&
                  activity.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  activity.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Route Badge
              if (activity.routeData != null &&
                  activity.routeData!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.route, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'GPS Route Saved',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
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
}
