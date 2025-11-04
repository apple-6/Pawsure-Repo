import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Activity'),
        backgroundColor: Colors.orange[100],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_run, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('Activity Screen Content', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text(
              'Monitor your pet\'s daily activities',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
