import 'package:flutter/material.dart';

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
    );
  }
}
