import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () => _showSOSDialog(context),
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFDC2626),
          size: 22,
        ),
        tooltip: 'Emergency SOS',
      ),
    );
  }

  void _showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFDC2626),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Emergency SOS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select an emergency option:',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            _SOSOption(
              icon: Icons.local_hospital,
              title: 'Find Nearby Vet',
              subtitle: 'Locate emergency vet clinics',
              color: const Color(0xFFEF4444),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Finding Vets',
                  'Searching for nearby veterinary clinics...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
                  colorText: const Color(0xFFDC2626),
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              },
            ),
            const SizedBox(height: 12),
            _SOSOption(
              icon: Icons.phone,
              title: 'Call Emergency Hotline',
              subtitle: 'Connect to pet emergency services',
              color: const Color(0xFFF59E0B),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Coming Soon',
                  'Emergency hotline feature will be available soon!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  colorText: Colors.blue[800],
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              },
            ),
            const SizedBox(height: 12),
            _SOSOption(
              icon: Icons.medical_services,
              title: 'First Aid Guide',
              subtitle: 'Quick pet first aid instructions',
              color: const Color(0xFF22C55E),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Coming Soon',
                  'First aid guide will be available soon!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  colorText: Colors.blue[800],
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SOSOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SOSOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color.withOpacity(0.6),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
