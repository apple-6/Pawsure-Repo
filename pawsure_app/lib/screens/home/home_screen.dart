// pawsure_app/lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/home/status_card.dart';
import '../../widgets/home/sos_button.dart';
import '../../widgets/home/upcoming_events_card.dart';
import '../../models/pet_model.dart';
import 'booking_card.dart';
import '../../controllers/booking_controller.dart'; // 🆕 Import

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

                // 🆕 Upcoming Events Card
                UpcomingEventsCard(petId: pet.id),
                const SizedBox(height: 24),

                Obx(() {
                  // We wrap the entire logic in the Obx so the whole container can react to loading states
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(20),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Now "My Bookings" is INSIDE the white container
                        const Text(
                          "My Bookings",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Logic for Loading, Empty, or List
                        if (bookingController.isLoadingBookings.value)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else ...[
                          // Filter bookings
                          (() {
                            final filteredBookings = bookingController
                                .userBookings
                                .where((booking) {
                                  final bId = booking['pet']?['id'];
                                  final sId = controller.selectedPet.value?.id;
                                  return bId.toString() == sId.toString();
                                })
                                .toList();

                            if (filteredBookings.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 32,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "No bookings scheduled for this pet.",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: filteredBookings
                                  .map(
                                    (booking) => BookingCard(booking: booking),
                                  )
                                  .toList(),
                            );
                          })(),
                        ],
                      ],
                    ),
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
}
