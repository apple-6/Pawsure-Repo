import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Map<String, String> data,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Colors.green),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...data.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text(
                      '${e.key}:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildInfoCard(
          context: context,
          icon: Icons.monitor_heart,
          title: 'Vitals',
          data: {'Weight': '15.2 kg', 'Height': '45 cm', 'Pulse': '88 bpm'},
        ),
        _buildInfoCard(
          context: context,
          icon: Icons.perm_identity,
          title: 'Identification',
          data: {
            'Microchip Number': '9820 3983 1293 3812',
            'Breed': 'Golden Retriever',
          },
        ),
        _buildInfoCard(
          context: context,
          icon: Icons.restaurant_menu,
          title: 'Dietary Information',
          data: {
            'Food Brand': 'Royal Canin',
            'Notes': 'No grains, chicken allergy',
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Edit Profile Information'),
        ),
      ],
    );
  }
}
