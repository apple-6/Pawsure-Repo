// pawsure_app/lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../widgets/home/daily_care_hub.dart';
import '../../widgets/home/sos_button.dart';
import '../../widgets/home/upcoming_events_card.dart';
import 'package:pawsure_app/widgets/home/quick_actions.dart';
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
            if (!controller.isLoadingPets.value) {
              final selectedPet = controller.selectedPet.value;
              final emoji = selectedPet?.species?.toLowerCase() == 'dog'
                  ? '🐕'
                  : '🐈';

              return PopupMenuButton<String>(
                tooltip: 'Switch Pet',
                onSelected: (String value) {
                  if (value == 'add_pet') {
                    Get.toNamed('/profile');
                  } else {
                    final pet = controller.pets.firstWhere(
                      (p) => p.id.toString() == value,
                    );
                    controller.selectPet(pet);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                offset: const Offset(0, 45),
                itemBuilder: (context) => [
                  // Pet list items
                  ...controller.pets.map(
                    (pet) => PopupMenuItem<String>(
                      value: pet.id.toString(),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: controller.selectedPet.value?.id == pet.id
                                  ? const Color(0xFF22C55E).withOpacity(0.1)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                pet.species?.toLowerCase() == 'dog'
                                    ? '🐕'
                                    : '🐈',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pet.name,
                              style: TextStyle(
                                fontWeight:
                                    controller.selectedPet.value?.id == pet.id
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (controller.selectedPet.value?.id == pet.id)
                            const Icon(
                              Icons.check,
                              size: 18,
                              color: Color(0xFF22C55E),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Divider
                  const PopupMenuDivider(),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedPet != null) ...[
                        Text(emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          selectedPet.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.pets,
                          size: 18,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Select Pet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                    ],
                  ),
                ),
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

                // NEW Daily Care Hub
                const DailyCareHub(),

                const SizedBox(height: 24),

                // Quick Actions
                const QuickActions(),

                const SizedBox(height: 24),

                // Upcoming Events Card
                UpcomingEventsCard(petId: pet.id),
                const SizedBox(height: 24),

                // Bookings Section
                Obx(() {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "My Bookings",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (!bookingController.isLoadingBookings.value)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${bookingController.userBookings.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        if (bookingController.isLoadingBookings.value)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (bookingController.userBookings.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 32,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "No bookings yet.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: bookingController.userBookings
                                .map(
                                  (booking) => BookingCard(
                                    booking: booking,
                                    onPaymentComplete: () {
                                      bookingController.fetchMyBookings();
                                    },
                                  ),
                                )
                                .toList(),
                          ),
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
    );
  }
}
