// pawsure_app/lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../widgets/home/status_card.dart';
import '../../widgets/home/sos_button.dart';
import '../../widgets/home/upcoming_events_card.dart';
import '../../models/pet_model.dart';
import 'booking_card.dart';
import '../../controllers/booking_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final BookingController bookingController = Get.put(BookingController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: Obx(
          () => Text(
            "Hello, ${controller.userName.value}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          // Pet Selector Dropdown
          Obx(() {
            if (!controller.isLoadingPets.value && controller.pets.isNotEmpty) {
              return PopupMenuButton<Pet>(
                icon: const Icon(Icons.pets, color: Colors.black),
                tooltip: 'Switch Pet',
                onSelected: (Pet pet) {
                  controller.selectPet(pet);
                },
                itemBuilder: (context) => controller.pets
                    .map(
                      (pet) => PopupMenuItem<Pet>(
                        value: pet,
                        child: Row(
                          children: [
                            if (controller.selectedPet.value?.id == pet.id)
                              const Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.green,
                              ),
                            const SizedBox(width: 8),
                            Text(pet.name),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(width: 8),
          const SOSButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingPets.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.pets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No pets added yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first pet to get started!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed('/home');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Pet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final pet = controller.selectedPet.value!;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Pet Info Row
                Row(
                  children: [
                    Text(
                      "Viewing: ${pet.name}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      pet.species ?? 'Pet',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Status Card (Reactive)
                StatusCard(
                  petName: pet.name,
                  petType: pet.species ?? 'Pet',
                  currentMood: controller.currentMood.value,
                  streak: pet.streak,
                  progress: controller.dailyProgress,
                  goals: controller.dailyGoals,
                ),

                const SizedBox(height: 24),

                // 🆕 Daily Activity Progress Card
                _buildDailyActivityCard(controller),

                const SizedBox(height: 24),

                // Upcoming Events Card
                UpcomingEventsCard(petId: pet.id),
                const SizedBox(height: 24),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "My Bookings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Obx(() {
                  if (bookingController.isLoadingBookings.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final filteredBookings = bookingController.userBookings.where(
                    (booking) {
                      final bId = booking['pet']?['id'];
                      final sId = controller.selectedPet.value?.id;
                      return bId.toString() == sId.toString();
                    },
                  ).toList();

                  if (filteredBookings.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: const Center(
                        child: Text(
                          "No bookings scheduled for this pet.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filteredBookings
                        .map((booking) => BookingCard(booking: booking))
                        .toList(),
                  );
                }),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }

  // 🆕 Daily Activity Progress Card Widget
  Widget _buildDailyActivityCard(HomeController controller) {
    return Obx(() {
      final progress = controller.calculateDailyProgress();
      final stats = controller.todayActivityStats.value;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Activity Progress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

              // Progress Bar
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

              // Activity Stats Summary
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
                          // Navigate to Activity tab
                          final navController =
                              Get.find<NavigationController>();
                          navController.changePage(2); // Activity tab index
                        },
                        child: const Text('Track Activity'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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
}
