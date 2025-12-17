import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ActivityController controller = Get.find<ActivityController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text(
          'Activity',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Get.snackbar(
                  'Coming Soon',
                  'Activity statistics will be available soon!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  colorText: Colors.blue[800],
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              },
              icon: const Icon(
                Icons.bar_chart_rounded,
                size: 20,
                color: Color(0xFF6B7280),
              ),
              tooltip: 'Statistics',
            ),
          ),
        ],
        toolbarHeight: 64,
      ),
      body: Obx(() {
        final activities = controller.activities;

        if (activities.isEmpty) {
          return _EmptyActivityView();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: activities.length + 1, // +1 for header
          itemBuilder: (context, index) {
            if (index == 0) {
              return _ActivitySummaryCard(activities: activities);
            }

            final a = activities[index - 1];
            return _ActivityCard(activity: a);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActivitySheet(context, controller),
        backgroundColor: const Color(0xFF22C55E),
        elevation: 2,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Log Activity',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showAddActivitySheet(
      BuildContext context, ActivityController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Log Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActivityTypeOption(
                  icon: Icons.directions_walk,
                  label: 'Walk',
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    Navigator.pop(context);
                    _logActivity(controller, 'Walk', 30);
                  },
                ),
                _ActivityTypeOption(
                  icon: Icons.pets,
                  label: 'Play',
                  color: const Color(0xFF22C55E),
                  onTap: () {
                    Navigator.pop(context);
                    _logActivity(controller, 'Play', 20);
                  },
                ),
                _ActivityTypeOption(
                  icon: Icons.pool,
                  label: 'Swim',
                  color: const Color(0xFF06B6D4),
                  onTap: () {
                    Navigator.pop(context);
                    _logActivity(controller, 'Swim', 15);
                  },
                ),
                _ActivityTypeOption(
                  icon: Icons.hiking,
                  label: 'Hike',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(context);
                    _logActivity(controller, 'Hike', 60);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _logActivity(
      ActivityController controller, String title, int duration) async {
    final payload = {
      'petId': '1',
      'title': title,
      'durationMinutes': duration,
      'activityDate': DateTime.now().toIso8601String(),
    };
    await controller.addActivity(payload);
    Get.snackbar(
      'Activity Logged! 🎉',
      '$title activity logged successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E).withOpacity(0.1),
      colorText: const Color(0xFF166534),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

class _ActivitySummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const _ActivitySummaryCard({required this.activities});

  @override
  Widget build(BuildContext context) {
    int totalMinutes = 0;
    for (var a in activities) {
      totalMinutes += (a['durationMinutes'] as int?) ?? 0;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This Week',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${activities.length} Activities',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalMinutes min total',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_run,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;

  const _ActivityCard({required this.activity});

  IconData _getActivityIcon(String? title) {
    switch (title?.toLowerCase()) {
      case 'walk':
        return Icons.directions_walk;
      case 'play':
        return Icons.pets;
      case 'swim':
        return Icons.pool;
      case 'hike':
        return Icons.hiking;
      default:
        return Icons.directions_walk;
    }
  }

  Color _getActivityColor(String? title) {
    switch (title?.toLowerCase()) {
      case 'walk':
        return const Color(0xFF3B82F6);
      case 'play':
        return const Color(0xFF22C55E);
      case 'swim':
        return const Color(0xFF06B6D4);
      case 'hike':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = activity['title'] as String?;
    final duration = activity['durationMinutes'] as int?;
    final dateStr = activity['activityDate']?.toString();
    String formattedDate = '';

    if (dateStr != null) {
      try {
        final date = DateTime.parse(dateStr);
        formattedDate = DateFormat('MMM d, h:mm a').format(date);
      } catch (_) {
        formattedDate = dateStr.split('T').first;
      }
    }

    final color = _getActivityColor(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getActivityIcon(title),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'Activity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${duration ?? 0} min',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActivityTypeOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivityView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_run,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Activities Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging activities to track\nyour pet\'s exercise routine',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
