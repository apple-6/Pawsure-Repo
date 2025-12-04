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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
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
                  Text("Mood: $currentMood  |  🔥 $streak days",
                      style: const TextStyle(color: Colors.grey)),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          // Simplified Progress Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRing(
                  "Walks", progress['walks']!, goals['walks']!, Colors.blue),
              _buildRing(
                  "Meals", progress['meals']!, goals['meals']!, Colors.green),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRing(String label, int current, int goal, Color color) {
    return Column(children: [
      CircularProgressIndicator(
          value: current / goal,
          color: color,
          backgroundColor: Colors.grey[200]),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 12))
    ]);
  }
}
