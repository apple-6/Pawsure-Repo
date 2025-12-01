import 'package:flutter/material.dart';
import 'dart:math' as math;

class PetCard extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetCard({super.key, required this.pet});

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
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pet Info Row
          Row(
            children: [
              // Pet Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    pet['emoji'] ?? '🐾',
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Pet Name and Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet['name'] ?? 'Pet',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Mood and Streak Chips
                    Row(
                      children: [
                        _buildChip(
                          icon: '❓',
                          label: 'Mood',
                          color: Colors.purple[50]!,
                          textColor: Colors.purple[700]!,
                        ),
                        const SizedBox(width: 8),
                        _buildChip(
                          icon: '🔥',
                          label: '${pet['streak'] ?? 0} day streak',
                          color: Colors.orange[50]!,
                          textColor: Colors.orange[700]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Progress Indicators Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressIndicator(
                label: 'Walks',
                current: pet['walks']?['current'] ?? 0,
                total: pet['walks']?['total'] ?? 2,
                color: const Color(0xFF2196F3),
                showFraction: true,
              ),
              _buildProgressIndicator(
                label: 'Meals',
                isComplete: pet['meals'] ?? false,
                color: const Color(0xFF4CAF50),
              ),
              _buildProgressIndicator(
                label: 'Well-being',
                isComplete: pet['wellbeing'] ?? false,
                color: const Color(0xFF9C27B0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator({
    required String label,
    int? current,
    int? total,
    bool? isComplete,
    required Color color,
    bool showFraction = false,
  }) {
    final double progress = showFraction
        ? (current ?? 0) / (total ?? 1)
        : (isComplete ?? false) ? 1.0 : 0.0;

    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Circle
              CustomPaint(
                size: const Size(70, 70),
                painter: CircleProgressPainter(
                  progress: progress,
                  progressColor: color,
                  backgroundColor: color.withOpacity(0.15),
                  strokeWidth: 6,
                ),
              ),
              // Content
              if (showFraction)
                Text(
                  '$current/$total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (isComplete ?? false) ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: (isComplete ?? false)
                        ? null
                        : Border.all(color: color.withOpacity(0.3), width: 2),
                  ),
                  child: (isComplete ?? false)
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  CircleProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

