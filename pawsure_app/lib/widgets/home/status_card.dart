import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String petName;
  final String petType;
  final String currentMood;
  final int streak;
  final Map<String, int> progress;
  final Map<String, int> goals;
  final String? photoUrl; // 🔧 NEW: Add photoUrl parameter

  const StatusCard({
    super.key,
    required this.petName,
    required this.petType,
    required this.currentMood,
    required this.streak,
    required this.progress,
    required this.goals,
    this.photoUrl, // 🔧 NEW: Optional photo URL
  });

  String _getPetEmoji() {
    final type = petType.toLowerCase();
    if (type == 'dog' || type == 'dogs') return '🐕';
    if (type == 'cat' || type == 'cats') return '🐈';
    return '🐾';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pet Info Row
          Row(
            children: [
              // 🔧 UPDATED: Pet Avatar with photo support
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
                          width: 56,
                          height: 56,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to emoji if image fails to load
                            return Center(
                              child: Text(
                                _getPetEmoji(),
                                style: const TextStyle(fontSize: 28),
                              ),
                            );
                          },
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
              // Pet Name & Badges
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Mood Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentMood == '❓' ? '?' : currentMood,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: currentMood == '❓'
                                      ? const Color(0xFFEC4899)
                                      : const Color(0xFF7C3AED),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Mood',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Streak Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                '$streak day streak',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress Rings Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressRing(
                'Walks',
                progress['walks'] ?? 0,
                goals['walks'] ?? 2,
                const Color(0xFF3B82F6),
              ),
              _buildProgressRing(
                'Meals',
                progress['meals'] ?? 0,
                goals['meals'] ?? 2,
                const Color(0xFF22C55E),
              ),
              _buildProgressRing(
                'Well-being',
                progress['wellbeing'] ?? 0,
                goals['wellbeing'] ?? 1,
                const Color(0xFFA855F7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(String label, int current, int goal, Color color) {
    final double progressValue = goal > 0
        ? (current / goal).clamp(0.0, 1.0)
        : 0.0;
    final bool isComplete = current >= goal;

    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color.withOpacity(0.15),
                  ),
                ),
              ),
              // Progress ring
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Center content
              if (isComplete)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: color, size: 24),
                )
              else
                Text(
                  '$current/$goal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
