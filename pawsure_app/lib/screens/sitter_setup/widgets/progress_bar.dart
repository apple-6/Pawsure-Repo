// lib/screens/sitter_setup/widgets/progress_bar.dart

import 'package:flutter/material.dart';

class SitterProgressBar extends StatelessWidget {
  final int currentStep;
  const SitterProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        children: [
          // We create 4 steps and pass 'isActive' to each one
          _ProgressBarStep(isActive: currentStep == 0),
          const SizedBox(width: 8), // Gap between bars
          _ProgressBarStep(isActive: currentStep == 1),
          const SizedBox(width: 8), // Gap between bars
          _ProgressBarStep(isActive: currentStep == 2),
          const SizedBox(width: 8), // Gap between bars
          _ProgressBarStep(isActive: currentStep == 3),
        ],
      ),
    );
  }
}

// This is a helper widget for each bar in the progress bar
class _ProgressBarStep extends StatelessWidget {
  final bool isActive;
  const _ProgressBarStep({required this.isActive});

  @override
  Widget build(BuildContext context) {
    // Each bar is an Expanded widget so it takes up equal space
    return Expanded(
      child: Container(
        height: 6.0, // Height of the bar
        decoration: BoxDecoration(
          // Set the color based on the 'isActive' state
          color: isActive
              ? const Color(0xFF1CCA5B) // Your app's green color
              : Colors.grey.shade300, // Light grey for inactive
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
      ),
    );
  }
}
