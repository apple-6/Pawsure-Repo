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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar & Info Row
          Row(
            children: [
              // Pet Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    petType.toLowerCase() == 'dog' ? "🐕" : "🐈",
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
                        _MoodBadge(mood: currentMood),
                        const SizedBox(width: 8),
                        // Streak Badge
                        _StreakBadge(streak: streak),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Progress Rings Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProgressRing(
                label: "Walks",
                current: progress['walks'] ?? 0,
                goal: goals['walks'] ?? 1,
                color: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFDBEAFE),
              ),
              _ProgressRing(
                label: "Meals",
                current: progress['meals'] ?? 0,
                goal: goals['meals'] ?? 1,
                color: const Color(0xFF22C55E),
                bgColor: const Color(0xFFDCFCE7),
              ),
              _ProgressRing(
                label: "Well-being",
                current: progress['wellbeing'] ?? 0,
                goal: goals['wellbeing'] ?? 1,
                color: const Color(0xFFA855F7),
                bgColor: const Color(0xFFF3E8FF),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodBadge extends StatelessWidget {
  final String mood;

  const _MoodBadge({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mood == "❓" ? "❓" : mood,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            "Mood",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.red[400],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("🔥", style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            "$streak day streak",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final Color color;
  final Color bgColor;

  const _ProgressRing({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final double progressValue = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final bool isComplete = current >= goal;

    return Column(
      children: [
        SizedBox(
          height: 64,
          width: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              SizedBox(
                height: 64,
                width: 64,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 5,
                  color: bgColor,
                  backgroundColor: Colors.transparent,
                ),
              ),
              // Progress ring
              SizedBox(
                height: 64,
                width: 64,
                child: CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 5,
                  color: color,
                  backgroundColor: Colors.transparent,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Center content
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: isComplete
                      ? Icon(
                          Icons.check,
                          color: color,
                          size: 24,
                        )
                      : Text(
                          "$current/$goal",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
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
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
