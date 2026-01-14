import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/pet_controller.dart';
import '../../controllers/navigation_controller.dart';

class DailyCareHub extends StatelessWidget {
  const DailyCareHub({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final PetController petController = Get.find<PetController>();

    return Obx(() {
      final pet = petController.selectedPet.value;
      if (pet == null) return const SizedBox.shrink();

      // Calculate Daily Progress
      final progressMap = controller.dailyProgress;
      final goalsMap = controller.dailyGoals;

      final double walksProgress =
          (progressMap['walks'] ?? 0) / (goalsMap['walks'] ?? 1);
      final double mealsProgress =
          (progressMap['meals'] ?? 0) / (goalsMap['meals'] ?? 1);
      final double wellbeingProgress =
          (progressMap['wellbeing'] ?? 0) / (goalsMap['wellbeing'] ?? 1);

      final double totalProgress =
          ((walksProgress + mealsProgress + wellbeingProgress) / 3).clamp(
            0.0,
            1.0,
          );
      final int progressPercent = (totalProgress * 100).round();

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
            // HEADER (Pet Image, Name, Streak)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[200]!, width: 2),
                      image: pet.photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(pet.photoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: pet.photoUrl == null
                        ? Center(
                            child: Text(
                              pet.name.isNotEmpty
                                  ? pet.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pet.breed ?? 'Unknown Breed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          '${controller.currentStreak.value}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // PROGRESS BAR SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Goals',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: totalProgress >= 1.0
                              ? Colors.green
                              : Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: totalProgress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        totalProgress >= 1.0 ? Colors.green : Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    totalProgress >= 1.0
                        ? "🎉 Amazing! You've hit all goals today!"
                        : "Keep it up! You're doing great with ${pet.name}.",
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ACTION GRID (Walk, Meal, Mood)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align tops
                children: [
                  // --- WALK ACTION (FIXED) ---
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.directions_walk,
                      color: Colors.blue,
                      title: 'Walk',
                      // 🔧 FIX: Using a Column to stack Minutes and Calories vertically
                      // 🔧 FIX: Fonts are now consistent (same size/weight/color)
                      content: (() {
                        final stats = controller.todayActivityStats.value;
                        final duration = stats?.totalDuration ?? 0;
                        final calories = stats?.totalCalories ?? 0;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$duration min',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                height: 1.2,
                              ),
                            ),
                            Text(
                              '$calories cal',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                height: 1.2,
                              ),
                            ),
                          ],
                        );
                      })(),
                      onTap: () {
                        final navController = Get.find<NavigationController>();
                        navController.changePage(2);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // --- FOOD ACTION ---
                  Expanded(child: _buildFoodAction(context, controller)),
                  const SizedBox(width: 12),

                  // --- MOOD ACTION ---
                  Expanded(
                    child: _buildActionCard(
                      icon: null,
                      emoji: controller.currentMood.value == '❓'
                          ? '😶'
                          : controller.currentMood.value,
                      color: Colors.purple,
                      title: 'Mood',
                      content: Text(
                        controller.currentMood.value == '❓'
                            ? 'Pending'
                            : 'Update',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => _showMoodSelector(context, controller),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // EXPANSION TILE (Details)
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: const Text(
                  "Today's Activity Details",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: (() {
                      final stats = controller.todayActivityStats.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (controller.isLoadingActivityStats.value)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (stats != null && stats.totalActivities > 0)
                            Column(
                              children: [
                                _buildProgressItem(
                                  icon: Icons.directions_walk,
                                  label: 'Activities Today',
                                  value: '${stats.totalActivities}',
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 8),
                                _buildProgressItem(
                                  icon: Icons.timer,
                                  label: 'Time Active',
                                  value: '${stats.totalDuration} min',
                                  color: Colors.orange,
                                ),
                                if (stats.totalDistance > 0) ...[
                                  const SizedBox(height: 8),
                                  _buildProgressItem(
                                    icon: Icons.straighten,
                                    label: 'Distance',
                                    value:
                                        '${stats.totalDistance.toStringAsFixed(1)} km',
                                    color: Colors.green,
                                  ),
                                ],
                                if (stats.totalCalories > 0) ...[
                                  const SizedBox(height: 8),
                                  _buildProgressItem(
                                    icon: Icons.local_fire_department,
                                    label: 'Calories',
                                    value: '${stats.totalCalories} cal',
                                    color: Colors.red,
                                  ),
                                ],
                              ],
                            )
                          else
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.directions_walk,
                                    size: 48,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No activities today',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: () {
                                      final navController =
                                          Get.find<NavigationController>();
                                      navController.changePage(2);
                                    },
                                    child: const Text('Track Activity'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    })(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // Helper method for progress items
  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.grey[700])),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  // 🔧 REFACTORED: Increased height to 140 to prevent overflow
  Widget _buildActionCard({
    IconData? icon,
    String? emoji,
    required Color color,
    required String title,
    required Widget content,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // 1. Increased height from 130 to 140 to fix "Bottom overflowed by 5.0 pixels"
        height: 140,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emoji != null)
              Text(emoji, style: const TextStyle(fontSize: 28))
            else
              Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 6),
            content,
          ],
        ),
      ),
    );
  }

  // 🔧 REFACTORED: Matched height to 140 so all cards align
  Widget _buildFoodAction(BuildContext context, HomeController controller) {
    final hour = DateTime.now().hour;
    final isMorning = hour < 16;
    final mealLabel = isMorning ? "Breakfast" : "Dinner";

    final mealsLogged = controller.dailyProgress['meals'] ?? 0;
    bool isDone = false;

    if (isMorning) {
      isDone = mealsLogged >= 1;
    } else {
      isDone = mealsLogged >= 2;
    }

    return GestureDetector(
      onTap: () {
        _showLogMealDialog(context, controller);
      },
      child: Container(
        // 1. Match height to 140
        height: 140,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDone
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone
                ? Colors.green.withOpacity(0.2)
                : Colors.orange.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.restaurant,
              color: isDone ? Colors.green : Colors.orange,
              size: 28, // Match icon size
            ),
            const SizedBox(height: 8),
            Text(
              mealLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isDone ? "Done" : "Pending",
              style: TextStyle(
                fontSize: 13,
                color: isDone ? Colors.green : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogMealDialog(BuildContext context, HomeController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Log Meal",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildMealOption(
                  context,
                  controller,
                  "Breakfast",
                  Icons.wb_sunny_outlined,
                ),
                const SizedBox(height: 12),
                _buildMealOption(
                  context,
                  controller,
                  "Dinner",
                  Icons.nightlight_round,
                ),
                const SizedBox(height: 12),
                _buildMealOption(
                  context,
                  controller,
                  "Snack",
                  Icons.cookie_outlined,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealOption(
    BuildContext context,
    HomeController controller,
    String label,
    IconData icon,
  ) {
    final isLogged = controller.loggedMeals.contains(label);

    return InkWell(
      onTap: isLogged
          ? null
          : () {
              controller.logMeal(label);
              Get.back();
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isLogged ? Colors.green.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isLogged ? Colors.green.withOpacity(0.3) : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isLogged ? Icons.check_circle : icon,
              color: isLogged ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isLogged ? FontWeight.bold : FontWeight.w500,
                color: isLogged ? Colors.green[800] : Colors.black87,
              ),
            ),
            const Spacer(),
            if (!isLogged)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showMoodSelector(BuildContext context, HomeController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "How is your pet feeling?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMoodOption(controller, "Happy", "😊", "happy"),
                _buildMoodOption(controller, "Neutral", "😐", "neutral"),
                _buildMoodOption(controller, "Sad", "😢", "sad"),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodOption(
    HomeController controller,
    String label,
    String emoji,
    String value,
  ) {
    return GestureDetector(
      onTap: () {
        controller.logMood(value);
        Get.back();
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
