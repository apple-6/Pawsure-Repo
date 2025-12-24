import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';

class ActivityStatsCard extends StatelessWidget {
  const ActivityStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ActivityController controller = Get.find<ActivityController>();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔧 FIX 2: Header Row with Flexible Text & Compact SegmentedButton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Activity Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // 🔧 UPDATED: Used SegmentedButton for better spacing control
                Obx(
                  () => SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'day',
                        label: Text('Day', style: TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: 'week',
                        label: Text('Wk', style: TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: 'month',
                        label: Text('Mo', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    selected: {controller.selectedPeriod.value},
                    onSelectionChanged: (Set<String> selection) {
                      controller.setPeriod(selection.first);
                    },
                    style: ButtonStyle(
                      visualDensity:
                          VisualDensity.compact, // Reduces vertical height
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats Grid
            Obx(() {
              final stats = controller.stats.value;

              if (stats == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          icon: Icons.directions_walk,
                          label: 'Activities',
                          value: stats.totalActivities.toString(),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatBox(
                          icon: Icons.timer,
                          label: 'Duration',
                          value: _formatDuration(stats.totalDuration),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          icon: Icons.straighten,
                          label: 'Distance',
                          value: '${stats.totalDistance.toStringAsFixed(1)} km',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatBox(
                          icon: Icons.local_fire_department,
                          label: 'Calories',
                          value: stats.totalCalories.toString(),
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}
