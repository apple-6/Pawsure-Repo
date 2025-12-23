import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';
import 'package:fl_chart/fl_chart.dart';

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
            // Period Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'day', label: Text('Day')),
                      ButtonSegment(value: 'week', label: Text('Week')),
                      ButtonSegment(value: 'month', label: Text('Month')),
                    ],
                    selected: {controller.selectedPeriod.value},
                    onSelectionChanged: (Set<String> selection) {
                      controller.setPeriod(selection.first);
                    },
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
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return Column(
                children: [
                  // Main Stats
                  Row(
                    children: [
                      _buildStatBox(
                        icon: Icons.directions_walk,
                        label: 'Activities',
                        value: stats.totalActivities.toString(),
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBox(
                        icon: Icons.timer,
                        label: 'Duration',
                        value: _formatDuration(stats.totalDuration),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatBox(
                        icon: Icons.straighten,
                        label: 'Distance',
                        value: '${stats.totalDistance.toStringAsFixed(1)} km',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBox(
                        icon: Icons.local_fire_department,
                        label: 'Calories',
                        value: stats.totalCalories.toString(),
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Activity Type Breakdown Chart
                  if (stats.byType.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Activity Breakdown',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(stats.byType),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: stats.byType.entries.map((entry) {
                        return _buildLegendItem(
                          entry.key,
                          entry.value,
                          _getColorForType(entry.key),
                        );
                      }).toList(),
                    ),
                  ],
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
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
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> data) {
    final total = data.values.fold(0, (sum, val) => sum + val);
    return data.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '$percentage%',
        color: _getColorForType(entry.key),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegendItem(String type, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '${type.capitalize} ($count)',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
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

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }
}
