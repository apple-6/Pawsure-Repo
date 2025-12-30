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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => SegmentedButton<String>(
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
                        label: Text('Month', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                    selected: {controller.selectedPeriod.value},
                    onSelectionChanged: (Set<String> selection) {
                      controller.setPeriod(selection.first);
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Compact Stats Grid
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

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCompactStat(
                    icon: Icons.directions_walk,
                    value: stats.totalActivities.toString(),
                    label: 'Activities',
                    color: Colors.blue,
                  ),
                  _buildCompactStat(
                    icon: Icons.timer,
                    value: _formatDuration(stats.totalDuration),
                    label: 'Duration',
                    color: Colors.orange,
                  ),
                  _buildCompactStat(
                    icon: Icons.straighten,
                    value: '${stats.totalDistance.toStringAsFixed(1)}',
                    label: 'km',
                    color: Colors.green,
                  ),
                  _buildCompactStat(
                    icon: Icons.local_fire_department,
                    value: stats.totalCalories.toString(),
                    label: 'cal',
                    color: Colors.red,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ),
      ],
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
