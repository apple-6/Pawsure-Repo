import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pet_controller.dart';
import '../../models/pet_model.dart';

class PetProfileView extends StatelessWidget {
  const PetProfileView({super.key});

  static const Color _accent = Color(0xFF1CCA5B);

  @override
  Widget build(BuildContext context) {
    final petController = Get.find<PetController>();

    // Retrieve arguments (The Pet model object from your Dashboard)
    final Pet pet = Get.arguments['pet'];
    final String dateRange = Get.arguments['dateRange'] ?? "N/A";
    final String estEarning = Get.arguments['estEarning'] ?? "RM 0.00";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Pet Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Section
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                image: pet.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(pet.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: pet.photoUrl == null
                  ? const Icon(Icons.pets, size: 80, color: Colors.grey)
                  : null,
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    pet.breed ?? "Unknown Breed",
                    style: const TextStyle(
                      fontSize: 16,
                      color: _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "🐾 About",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Stats (Age and Weight Only)
                  Row(
                    children: [
                      // No more error here because calculateAge now accepts String?
                      _buildStatItem(
                        "Age",
                        petController.calculateAge(pet.dob),
                      ),
                      _buildStatItem("Weight", "${pet.weight ?? '-'} kg"),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "📝 Notes:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Allergy Note
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      "Allergies: ${pet.allergies ?? 'None reported'}",
                      style: const TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Booking Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        _buildBookingRow(
                          Icons.calendar_today,
                          "Booking Date",
                          dateRange,
                        ),
                        const Divider(height: 24),
                        _buildBookingRow(
                          Icons.payments,
                          "Est. Earning",
                          estEarning,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButton(
                    "Accept Booking",
                    _accent,
                    Colors.white,
                    () {
                      Get.snackbar(
                        "Success",
                        "Booking for ${pet.name} accepted!",
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    "Decline Booking",
                    Colors.red.shade50,
                    Colors.red,
                    () {
                      Get.back(); // Simple go back for now
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    "Message Owner",
                    Colors.white,
                    Colors.black,
                    () {},
                    isOutlined: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingRow(IconData icon, String title, String val) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _accent),
        const SizedBox(width: 8),
        Text("$title: ", style: const TextStyle(color: Colors.grey)),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButton(
    String text,
    Color bg,
    Color textCol,
    VoidCallback tap, {
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: isOutlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: tap,
              child: Text(
                text,
                style: TextStyle(color: textCol, fontWeight: FontWeight.bold),
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: tap,
              child: Text(
                text,
                style: TextStyle(color: textCol, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
