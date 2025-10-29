import 'package:flutter/material.dart';
import 'add_health_record_screen.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Health'),
        backgroundColor: Colors.green[100],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('Health Screen Content', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text(
              'Track your pet\'s health records',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // TODO: replace with a real petId you have in DB
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddHealthRecordScreen(petId: 1),
            ),
          );
          if (created == true) {
            // Optional: refresh your list later (APPLE-57), for now show feedback
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Health record added')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
    );
  }
}
