
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/pet_controller.dart';
import '../../controllers/navigation_controller.dart';
import 'package:intl/intl.dart';

class DailyCareHub extends StatelessWidget {
  const DailyCareHub({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    // Ensure PetController is available
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
          ((walksProgress + mealsProgress + wellbeingProgress) / 3)
              .clamp(0.0, 1.0);
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
            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Pet Image/Initial
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
                  // Name & Breed
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
                  // Streak Badge
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

            // PROGRESS SECTION
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

            // ACTION GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Walk Action
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.directions_walk,
                      color: Colors.blue,
                      title: 'Walk',
                      subtitle: (() {
                        final stats = controller.todayActivityStats.value;
                        if (stats == null) return '0 min • 0 cal';
                        
                        // Try to get specific walk stats if available in breakdown
                        // Note: Breakdown keys depend on backend, assuming 'walk' or similar
                        final walkDuration = stats.activityBreakdown?['walk'] ?? 0; // Duration or count? 
                        // Actually the breakdown usually gives count per type, but let's stick to total duration 
                        // for simplicity as 'walk' is the primary activity usually.
                        // Or just show total duration/calories for the day as requested contextually.
                        
                        return '${stats.totalDuration} min • ${stats.totalCalories} cal';
                      })(),
                      onTap: () {
                         // Navigate to Activity Screen (index 2 usually in main navigation)
                         final navController = Get.find<NavigationController>();
                         navController.changePage(2);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Food Action
                  Expanded(
                    child: _buildFoodAction(context, controller),
                  ),
                  const SizedBox(width: 12),
                  // Mood Action
                  Expanded(
                    child: _buildActionCard(
                      icon: null, // Use emoji instead
                      emoji: controller.currentMood.value == '❓'
                          ? '😶'
                          : controller.currentMood.value,
                      color: Colors.purple,
                      title: 'Mood',
                      subtitle: controller.currentMood.value == '❓' ? 'Pending' : 'Update',
                      onTap: () => _showMoodSelector(context, controller),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // EXPANSION TILE
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: (() {
                      final progress = controller.calculateDailyProgress();
                      final stats = controller.todayActivityStats.value;
                      final todayStr = DateFormat('EEEE, MMM d').format(DateTime.now());

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                todayStr,
                                style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '$progress%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: progress >= 100 ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              minHeight: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress >= 100 ? Colors.green : Colors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

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
                                    value: '${stats.totalDistance.toStringAsFixed(1)} km',
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

  Widget _buildActionCard({
    IconData? icon,
    String? emoji,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            if (emoji != null)
              Text(emoji, style: const TextStyle(fontSize: 24))
            else
              Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodAction(BuildContext context, HomeController controller) {
    final hour = DateTime.now().hour;
    final isMorning = hour < 16; // Before 4 PM is "Morning" for this logic
    final mealLabel = isMorning ? "Breakfast" : "Dinner";
    
    // Simple logic: 
    // < 1 meal logged -> Breakfast pending (if morning)
    // >= 1 meal logged -> Breakfast done (if morning) or Dinner pending (if evening)
    // >= 2 meals logged -> All done
    
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDone ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.restaurant,
              color: isDone ? Colors.green : Colors.orange,
              size: 24,
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
            const SizedBox(height: 4),
            Text(
              isDone ? "Done" : "Pending",
              style: TextStyle(
                fontSize: 12,
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
          child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Log Meal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildMealOption(context, controller, "Breakfast", Icons.wb_sunny_outlined),
              const SizedBox(height: 12),
              _buildMealOption(context, controller, "Dinner", Icons.nightlight_round),
              const SizedBox(height: 12),
              _buildMealOption(context, controller, "Snack", Icons.cookie_outlined),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildMealOption(BuildContext context, HomeController controller, String label, IconData icon) {
    final isLogged = controller.loggedMeals.contains(label);
    
    return InkWell(
      onTap: isLogged ? null : () {
        controller.logMeal(label);
        Get.back();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isLogged ? Colors.green.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: isLogged ? Colors.green.withOpacity(0.3) : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isLogged ? Icons.check_circle : icon, 
              color: isLogged ? Colors.green : Colors.orange
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

  void _showLogWalkDialog(BuildContext context, HomeController controller) {
    final TextEditingController durationController = TextEditingController();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Log Walk",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Duration (minutes)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixText: "min",
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final duration = int.tryParse(durationController.text);
                      if (duration != null && duration > 0) {
                        // TODO: Call controller.logActivity()
                        // Since LogActivity is usually complex, we might want to redirect to activity page
                        // or call a specific service method.
                        // For this prototype, we'll close and show a message.
                         Get.back();
                         Get.snackbar(
                          "Walk Logged",
                          "Added $duration mins walk!",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          colorText: Colors.blue[800],
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
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
