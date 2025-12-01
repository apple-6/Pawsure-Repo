import 'package:flutter/material.dart';

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all events
              },
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Events List
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildEventCard(
                title: 'Vet Visit',
                time: 'Tomorrow at 10 AM',
                icon: Icons.calendar_today,
                isUrgent: true,
                color: const Color(0xFFFFEBEE),
                iconColor: const Color(0xFFE57373),
              ),
              const SizedBox(width: 12),
              _buildEventCard(
                title: 'Flea Treatment',
                time: 'In 5 days',
                icon: Icons.calendar_today,
                isUrgent: false,
                color: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFFFB74D),
              ),
              const SizedBox(width: 12),
              _buildEventCard(
                title: 'Grooming',
                time: 'In 2 weeks',
                icon: Icons.calendar_today,
                isUrgent: false,
                color: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF64B5F6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard({
    required String title,
    required String time,
    required IconData icon,
    required bool isUrgent,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: isUrgent
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (isUrgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

