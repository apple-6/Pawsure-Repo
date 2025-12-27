import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PetProfileView extends StatelessWidget {
  const PetProfileView({super.key});

  static const Color _accent = Color(0xFF1CCA5B);
  static const Color _bgGrey = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    // Retrieving arguments passed from Get.to()
    final Map<String, dynamic> petData = Get.arguments ?? {};

    // Mock behavior notes logic
    final List<Map<String, dynamic>> behaviorNotes = [
      {
        'type': 'warning',
        'text': 'Gets tired easily',
        'icon': Icons.report_problem_outlined,
      },
      {
        'type': 'success',
        'text': 'Eat 3 times a day',
        'icon': Icons.check_circle_outline,
      },
      {
        'type': 'danger',
        'text': 'Can get anxious around new people',
        'icon': Icons.cancel_outlined,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
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
            // Pet Photo Section
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey.shade200,
              child: const Center(
                child: Text("🐕", style: TextStyle(fontSize: 80)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Breed
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            petData['petName'] ?? "Bella",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Border Collie",
                            style: TextStyle(
                              fontSize: 16,
                              color: _accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("❤️", style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    "🐾",
                    "About ${petData['petName'] ?? 'Bella'}",
                  ),
                  const SizedBox(height: 12),

                  // Stats Grid
                  Row(
                    children: [
                      _buildStatItem("Age", "1y 4m"),
                      _buildStatItem("Weight", "7.5 kg"),
                      _buildStatItem("Height", "54 cm"),
                      _buildStatItem("Color", "Black"),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "My first dog which was gifted by my mother for my 20th birthday.",
                    style: TextStyle(color: Colors.black54, height: 1.5),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle("🎯", "Behavior Notes"),
                  const SizedBox(height: 12),

                  // Behavior Notes List
                  ...behaviorNotes
                      .map((note) => _buildBehaviorNote(note))
                      .toList(),

                  const SizedBox(height: 24),
                  // Booking Details Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _bgGrey,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          Icons.calendar_month,
                          "Booking Date",
                          "25 - 27 October 2025",
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          Icons.access_time_filled,
                          "Pet Sitting Duration",
                          "2 Days",
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          Icons.monetization_on,
                          "Rate",
                          "RM30.00/h",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () =>
                          Get.snackbar("Success", "Booking Accepted"),
                      child: const Text(
                        "Accept Booking",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Message Owner",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
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
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorNote(Map<String, dynamic> note) {
    Color bgColor;
    Color iconColor;

    switch (note['type']) {
      case 'warning':
        bgColor = Colors.orange.shade50;
        iconColor = Colors.orange.shade700;
        break;
      case 'success':
        bgColor = Colors.green.shade50;
        iconColor = Colors.green.shade700;
        break;
      case 'danger':
        bgColor = Colors.red.shade50;
        iconColor = Colors.red.shade700;
        break;
      default:
        bgColor = Colors.grey.shade50;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(note['icon'], size: 20, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(note['text'], style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _accent, size: 22),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
