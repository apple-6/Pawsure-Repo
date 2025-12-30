import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/navigation_controller.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/controllers/home_controller.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback? onLogWalk;
  final VoidCallback? onAddMeal;
  final VoidCallback? onRateMood;
  final VoidCallback? onAiScan;

  const QuickActions({
    super.key,
    this.onLogWalk,
    this.onAddMeal,
    this.onRateMood,
    this.onAiScan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        // 2x2 Grid of actions
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.show_chart,
                label: 'Log Walk',
                iconColor: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
                onTap: onLogWalk ?? () => _navigateToActivity(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add,
                label: 'Add Meal',
                iconColor: const Color(0xFF22C55E),
                bgColor: const Color(0xFFDCFCE7),
                onTap: onAddMeal ?? () => _navigateToHealthRecords(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.favorite_border,
                label: 'Rate Mood',
                iconColor: const Color(0xFFA855F7),
                bgColor: const Color(0xFFF3E8FF),
                onTap: onRateMood ?? () => _showMoodDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.camera_alt_outlined,
                label: 'AI Scan',
                iconColor: const Color(0xFFF97316),
                bgColor: const Color(0xFFFFF7ED),
                onTap: onAiScan ?? () => _navigateToAiScan(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Navigate to Activity page (index 2 in bottom nav)
  void _navigateToActivity() {
    if (Get.isRegistered<NavigationController>()) {
      final navController = Get.find<NavigationController>();
      navController.changePage(2); // Activity is index 2
    }
  }

  /// Navigate to Health page, Records tab
  void _navigateToHealthRecords() {
    if (Get.isRegistered<NavigationController>()) {
      final navController = Get.find<NavigationController>();
      navController.changePage(1); // Health is index 1
      
      // Switch to Records tab (index 1)
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isRegistered<HealthController>()) {
          final healthController = Get.find<HealthController>();
          healthController.tabController.animateTo(1);
        }
      });
    }
  }

  /// Navigate to Health page, AI Scan tab
  void _navigateToAiScan() {
    if (Get.isRegistered<NavigationController>()) {
      final navController = Get.find<NavigationController>();
      navController.changePage(1); // Health is index 1
      
      // Switch to AI Scan tab (index 2)
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isRegistered<HealthController>()) {
          final healthController = Get.find<HealthController>();
          healthController.tabController.animateTo(2);
        }
      });
    }
  }

  /// Show mood rating dialog
  void _showMoodDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _MoodRatingSheet(),
    );
  }
}

class _MoodRatingSheet extends StatelessWidget {
  const _MoodRatingSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          const Text(
            'How is your pet feeling today?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rate their mood to track their well-being',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          // Mood Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MoodOption(
                emoji: '😢',
                label: 'Sad',
                color: const Color(0xFFFEE2E2),
                borderColor: const Color(0xFFEF4444),
                onTap: () => _selectMood(context, 'sad'),
              ),
              _MoodOption(
                emoji: '😐',
                label: 'Neutral',
                color: const Color(0xFFFEF3C7),
                borderColor: const Color(0xFFF59E0B),
                onTap: () => _selectMood(context, 'neutral'),
              ),
              _MoodOption(
                emoji: '😊',
                label: 'Happy',
                color: const Color(0xFFDCFCE7),
                borderColor: const Color(0xFF22C55E),
                onTap: () => _selectMood(context, 'happy'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _selectMood(BuildContext context, String mood) {
    Navigator.pop(context);
    
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      homeController.logMood(mood);
      
      // Update wellbeing progress
      homeController.dailyProgress['wellbeing'] = 1;
      homeController.dailyProgress.refresh();
    }
  }
}

class _MoodOption extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 3),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: borderColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              // Label
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
