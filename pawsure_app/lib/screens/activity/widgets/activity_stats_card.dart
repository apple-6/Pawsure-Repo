// pawsure_app/lib/screens/activity/widgets/activity_stats_card.dart
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
            // 🔧 FIX: Better responsive header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Activity Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // 🔧 FIX: Constrained width for period selector
                Obx(
                  () => SizedBox(
                    width: 160, // Fixed width to prevent overflow
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'day',
                          label: Text('Day', style: TextStyle(fontSize: 11)),
                        ),
                        ButtonSegment(
                          value: 'week',
                          label: Text('Week', style: TextStyle(fontSize: 11)),
                        ),
                        ButtonSegment(
                          value: 'month',
                          label: Text('Mon', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                      selected: {controller.selectedPeriod.value},
                      onSelectionChanged: (Set<String> selection) {
                        controller.setPeriod(selection.first);
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 0,
                          ),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
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
      padding: const EdgeInsets.all(12), // Reduced from 16
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28), // Reduced from 32
          const SizedBox(height: 6), // Reduced from 8
          FittedBox(
            // 🔧 FIX: Auto-scale text to fit
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18, // Reduced from 20
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          FittedBox(
            // 🔧 FIX: Auto-scale label
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
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
