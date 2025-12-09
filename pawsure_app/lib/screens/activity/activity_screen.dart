import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ActivityController controller = Get.find<ActivityController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Activity'),
        backgroundColor: Colors.orange[100],
      ),
      body: Obx(() {
        final activities = controller.activities;
        if (activities.isEmpty) {
          return const Center(child: Text('No activities yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final a = activities[index];
            return Card(
              child: ListTile(
                leading: const Icon(
                  Icons.directions_walk,
                  color: Colors.orange,
                ),
                title: Text(a['title'] ?? 'Activity'),
                subtitle: Text('Duration: ${a['durationMinutes']} min'),
                trailing: Text(
                  a['activityDate']?.toString().split('T').first ?? '',
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Placeholder add action: in future replace with a dialog + ActivityService
          final payload = {
            'petId': '1',
            'title': 'Evening Walk',
            'durationMinutes': 20,
            'activityDate': DateTime.now().toIso8601String(),
          };
          await controller.addActivity(payload);
          Get.snackbar('Added', 'Activity added (placeholder)');
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
