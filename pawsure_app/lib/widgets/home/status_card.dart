import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String petName;
  final String petType;
  final String currentMood;
  final int streak;
  final Map<String, int> progress;
  final Map<String, int> goals;

  const StatusCard({
    super.key,
    required this.petName,
    required this.petType,
    required this.currentMood,
    required this.streak,
    required this.progress,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF22C55E);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar & Info Row
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    petType.toLowerCase() == 'dog' ? "🐕" : "🐈",
                    style: const TextStyle(fontSize: 32),
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _badge(
                          currentMood,
                          "Mood",
                          const Color(0xFFFEF3C7),
                          textColor: const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        _badge(
                          "🔥 $streak day streak",
                          "",
                          primaryColor.withOpacity(0.1),
                          textColor: primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Progress Rings with Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressRing(
                label: "Walks",
                current: progress['walks'] ?? 0,
                goal: goals['walks'] ?? 2,
                color: const Color(0xFF3B82F6),
                icon: Icons.directions_walk,
              ),
              _buildProgressRing(
                label: "Meals",
                current: progress['meals'] ?? 0,
                goal: goals['meals'] ?? 2,
                color: const Color(0xFF22C55E),
                icon: Icons.restaurant,
                isComplete: (progress['meals'] ?? 0) >= (goals['meals'] ?? 2),
              ),
              _buildProgressRing(
                label: "Well-being",
                current: progress['wellbeing'] ?? 0,
                goal: goals['wellbeing'] ?? 1,
                color: const Color(0xFFA855F7),
                icon: Icons.favorite,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, String label, Color bg, {Color textColor = Colors.black87}) {
    final displayText = label.isNotEmpty ? "$text $label" : text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildProgressRing({
    required String label,
    required int current,
    required int goal,
    required Color color,
    required IconData icon,
    bool isComplete = false,
  }) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final isCompleted = current >= goal;

    return Column(
      children: [
        SizedBox(
          height: 72,
          width: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                height: 72,
                width: 72,
                child: CircularProgressIndicator(
                  value: 1,
                  color: color.withOpacity(0.15),
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Progress circle
              SizedBox(
                height: 72,
                width: 72,
                child: CircularProgressIndicator(
                  value: progress,
                  color: color,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.transparent,
                ),
              ),
              // Icon or checkmark in center
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted ? color.withOpacity(0.1) : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          color: color,
                          size: 24,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              color: color,
                              size: 20,
                            ),
                            Text(
                              '$current/$goal',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isCompleted ? color : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
