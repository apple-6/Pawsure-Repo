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
    // Pawsure Green
    final primaryColor = const Color(0xFF22c55e);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Avatar & Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFFF3F4F6),
                child: Text(petType == 'dog' ? "🐕" : "🐈",
                    style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(petName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _badge(currentMood, "Mood", Colors.grey.shade200),
                      const SizedBox(width: 8),
                      _badge("🔥 $streak", "Days",
                          primaryColor.withValues(alpha: 0.1),
                          textColor: primaryColor),
                    ],
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          // Progress Rings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRing(
                  "Walks", progress['walks']!, goals['walks']!, Colors.blue),
              _buildRing(
                  "Meals", progress['meals']!, goals['meals']!, Colors.green),
              _buildRing("Health", progress['wellbeing']!, goals['wellbeing']!,
                  Colors.purple),
            ],
          )
        ],
      ),
    );
  }

  Widget _badge(String text, String label, Color bg,
      {Color textColor = Colors.black87}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text("$text $label",
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Widget _buildRing(String label, int current, int goal, Color color) {
    return Column(children: [
      SizedBox(
        height: 60,
        width: 60,
        child: CircularProgressIndicator(
            value: current / goal,
            color: color,
            strokeWidth: 6,
            backgroundColor: Colors.grey[100]),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 12))
    ]);
  }
}
