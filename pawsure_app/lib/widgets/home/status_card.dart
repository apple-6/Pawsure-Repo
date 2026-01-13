import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String petName;
  final String petType;
  final String currentMood;
  final int streak;
  final Map<String, int> progress;
  final Map<String, int> goals;
  final String? photoUrl;

  final int walkMinutes;
  final int walkCalories;

  const StatusCard({
    super.key,
    required this.petName,
    required this.petType,
    required this.currentMood,
    required this.streak,
    required this.progress,
    required this.goals,
    this.photoUrl,
    this.walkMinutes = 40,
    this.walkCalories = 50,
  });

  String _getPetEmoji() {
    final type = petType.toLowerCase();
    if (type == 'dog' || type == 'dogs') return '🐕';
    if (type == 'cat' || type == 'cats') return '🐈';
    return '🐾';
  }

  @override
  Widget build(BuildContext context) {
    // Calculate overall daily progress for the linear bar
    int totalGoals = goals.values.fold(0, (sum, val) => sum + val);
    int totalProgress = progress.values.fold(0, (sum, val) => sum + val);
    double overallProgress = totalGoals > 0
        ? (totalProgress / totalGoals).clamp(0.0, 1.0)
        : 0.0;
    int percentage = (overallProgress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER ROW (Avatar, Name, Streak)
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: photoUrl != null && photoUrl!.isNotEmpty
                      ? Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              _getPetEmoji(),
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            _getPetEmoji(),
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      petType,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Fire Streak Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '$streak',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. DAILY GOALS HEADER + PROGRESS BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Goals',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: overallProgress,
              backgroundColor: const Color(0xFFF3F4F6),
              color: const Color(0xFF7C3AED), // Purple brand color
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Keep it up! You\'re doing great with $petName.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 24),

          // 3. GOAL CARDS ROW (Walk, Breakfast, Mood)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- WALK CARD (UPDATED) ---
              Expanded(
                child: _buildGoalCard(
                  title: 'Walk',
                  // 🔧 FIX: Stacked vertically, removed dot
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$walkMinutes min',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700, // Bolder for top line
                          color: Color(0xFF1F2937),
                          height: 1.2,
                        ),
                      ),
                      Text(
                        '$walkCalories cal',
                        style: const TextStyle(
                          fontSize: 12, // Slightly smaller for sub-info
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  icon: Icons.directions_run,
                  iconColor: const Color(0xFF3B82F6), // Blue
                  bgColor: const Color(0xFFEFF6FF), // Light Blue
                  isPending: false,
                ),
              ),
              const SizedBox(width: 12),

              // --- BREAKFAST CARD ---
              Expanded(
                child: _buildGoalCard(
                  title: 'Breakfast',
                  content: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  icon: Icons.restaurant,
                  iconColor: const Color(0xFFF59E0B), // Orange
                  bgColor: const Color(0xFFFFFBEB), // Light Orange
                  isPending: true,
                ),
              ),
              const SizedBox(width: 12),

              // --- MOOD CARD ---
              Expanded(
                child: _buildGoalCard(
                  title: 'Mood',
                  content: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  icon: Icons.sentiment_satisfied_alt,
                  iconColor: const Color(0xFFEAB308), // Yellow
                  bgColor: const Color(0xFFFEFCE8), // Light Yellow
                  isPending: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widget for the Cards
  Widget _buildGoalCard({
    required String title,
    required Widget content,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required bool isPending,
  }) {
    return Container(
      height: 125, // 🔧 Increased height slightly to accommodate vertical text
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPending ? Colors.white : bgColor,
        borderRadius: BorderRadius.circular(16),
        border: isPending
            ? Border.all(color: Colors.grey.shade100, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          content,
        ],
      ),
    );
  }
}
