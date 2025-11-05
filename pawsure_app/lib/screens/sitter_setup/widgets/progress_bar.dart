// lib/screens/sitter_setup/widgets/progress_bar.dart

import 'package:flutter/material.dart';

class SitterProgressBar extends StatelessWidget {
  final int currentStep;
  const SitterProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
  // Colors are derived where used to avoid unused_local_variable lint

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        children: [
          _StepDot(
            label: 'Basic',
            isActive: currentStep >= 0,
          ),
          _StepConnector(isActive: currentStep >= 1),
          _StepDot(
            label: 'Environment',
            isActive: currentStep >= 1,
          ),
          _StepConnector(isActive: currentStep >= 2),
          _StepDot(
            label: 'Verification',
            isActive: currentStep >= 2,
          ),
          _StepConnector(isActive: currentStep >= 3),
          _StepDot(
            label: 'Rates',
            isActive: currentStep >= 3,
          ),
        ],
      ),
    );
  }
}

// --- NEW HELPER WIDGETS ---
// (These replace the old _StepIcon)

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;

  const _StepDot({
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        isActive ? Theme.of(context).primaryColor : Colors.grey.shade300;
    
    // Align the text under the dot
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isActive;
  const _StepConnector({required this.isActive});

  @override
  Widget build(BuildContext context) {
    // This is the line between the dots
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4.0), // Add some margin
        color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade300,
      ),
    );
  }
}