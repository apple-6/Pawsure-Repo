import 'package:flutter/material.dart';

class EmergencyHelpDialog extends StatelessWidget {
  const EmergencyHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Emergency Help',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Emergency Buttons
            Row(
              children: [
                Expanded(
                  child: _buildEmergencyButton(
                    icon: Icons.location_on,
                    label: 'Nearest 24/7 Vet',
                    color: Colors.red,
                    onTap: () {
                      // TODO: Open maps to find nearest vet
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Finding nearest vet...')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEmergencyButton(
                    icon: Icons.phone,
                    label: 'Call Hotline',
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      // TODO: Implement phone call functionality with url_launcher package
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling emergency hotline: 1800-123-456')),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // First Aid Guides Section
            const Text(
              'First Aid Guides',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // First Aid Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildFirstAidCard(
                  emoji: '🚨',
                  label: 'Choking',
                  onTap: () => _showGuide(context, 'Choking'),
                ),
                _buildFirstAidCard(
                  emoji: '💊',
                  label: 'Wounds & Bleeding',
                  onTap: () => _showGuide(context, 'Wounds & Bleeding'),
                ),
                _buildFirstAidCard(
                  emoji: '☠️',
                  label: 'Poisoning',
                  onTap: () => _showGuide(context, 'Poisoning'),
                ),
                _buildFirstAidCard(
                  emoji: '⚡',
                  label: 'Seizures',
                  onTap: () => _showGuide(context, 'Seizures'),
                ),
                _buildFirstAidCard(
                  emoji: '😰',
                  label: 'Difficulty Breathing',
                  onTap: () => _showGuide(context, 'Difficulty Breathing'),
                ),
                _buildFirstAidCard(
                  emoji: '🌡️',
                  label: 'Heatstroke',
                  onTap: () => _showGuide(context, 'Heatstroke'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'In case of severe emergency, immediately contact your local veterinary emergency service or call emergency services.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstAidCard({
    required String emoji,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuide(BuildContext context, String topic) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$topic guide coming soon!')),
    );
  }
}

