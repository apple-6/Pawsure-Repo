import 'package:flutter/material.dart';

class AIScanTab extends StatelessWidget {
  const AIScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.orange.shade50,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.analytics_outlined,
                          size: 38,
                          color: Colors.orange,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Analyze Poop/Fur',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.teal.shade50,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.directions_walk_outlined,
                          size: 38,
                          color: Colors.teal,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Check Posture/Gait',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.grey.shade100,
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This is an informational tool and does not replace professional veterinary advice.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Past Scans',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.analytics_outlined, color: Colors.orange),
            title: const Text('Stool Analysis'),
            subtitle: const Text('12 Aug 2025 • Normal'),
            trailing: Chip(
              label: Text('Normal'),
              backgroundColor: Colors.green[50],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.analytics_outlined, color: Colors.orange),
            title: const Text('Fur Analysis'),
            subtitle: const Text('21 July 2025 • Attention'),
            trailing: Chip(
              label: Text('Attention'),
              backgroundColor: Colors.orange[50],
              labelStyle: TextStyle(color: Colors.orange),
            ),
          ),
        ),
      ],
    );
  }
}
