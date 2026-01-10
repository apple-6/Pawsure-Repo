import 'package:flutter/material.dart';
import '../../models/sitter_model.dart';

class SitterPreviewPage extends StatelessWidget {
  final UserProfile user;
  const SitterPreviewPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Colors extracted from your images
    const Color brandColor = Color(0xFF2ECA6A);
    const Color brandLight = Color(0xFFE8F5E9);
    const Color textDark = Color(0xFF1F2937);
    const Color textGrey = Color(0xFF6B7280);
    const Color starColor = Color(0xFFFBBF24);

    return Scaffold(
      // ✅ CHANGE 1: Use a standard "Off-White/Grey" background.
      // This provides the best contrast for white cards.
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Preview as Owner",
          style: TextStyle(color: textGrey, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          children: [
            // --- 1. HEADER CARD ---
            _buildCard(
              child: Column(
                children: [
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: brandLight,
                      child: const Icon(
                        Icons.person_outline,
                        size: 40,
                        color: brandColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.location,
                        style: const TextStyle(color: textGrey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Rating
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: starColor, size: 20),
                      SizedBox(width: 4),
                      Text(
                        "4.9",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text("(32 Reviews)", style: TextStyle(color: textGrey)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Verified Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: brandLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 16,
                              color: brandColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Verified",
                              style: TextStyle(
                                color: brandColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Super Sitter Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: textGrey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Super Sitter",
                              style: TextStyle(
                                color: textGrey,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- 2. ABOUT ME CARD ---
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About Me",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    user.bio,
                    style: const TextStyle(color: textGrey, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _buildStatItem(
                        Icons.access_time,
                        "${user.experienceYears} years exp.",
                        textGrey,
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        Icons.calendar_today_outlined,
                        "${user.staysCompleted} stays completed",
                        textGrey,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- 3. SERVICES & RATES CARD ---
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Services & Rates",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (user.services.isEmpty)
                    const Text(
                      "No services listed yet.",
                      style: TextStyle(color: textGrey),
                    )
                  else
                    ...user.services.where((s) => s.isActive).map((service) {
                      return Column(
                        children: [
                          _buildServiceRow(
                            service.name,
                            "RM ${service.price}${service.unit}",
                            brandColor,
                          ),
                          const Divider(height: 24),
                        ],
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- 4. REVIEWS CARD ---
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Reviews",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      Text("32 total", style: TextStyle(color: textGrey)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildReviewItem(
                    name: "Sarah M.",
                    petName: "Max",
                    date: "Oct 2024",
                    rating: 5,
                    comment:
                        "Aisha was amazing with Max! She sent daily updates and photos. Highly recommend!",
                    starColor: starColor,
                    textGrey: textGrey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- CONTACT BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF86EFAC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Contact Sitter (Preview Only)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  // ✅ CHANGE 3: Improved Card shadow to make it pop against the grey background
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // White card
        borderRadius: BorderRadius.circular(16),
        // Deeper, softer shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Darker opacity
            blurRadius: 15, // Spread the shadow more
            offset: const Offset(0, 5), // Push it down slightly
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }

  Widget _buildServiceRow(String name, String price, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563)),
        ),
        Text(
          price,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem({
    required String name,
    required String petName,
    required String date,
    required int rating,
    required String comment,
    required Color starColor,
    required Color textGrey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Pet: $petName",
                  style: TextStyle(color: textGrey, fontSize: 12),
                ),
              ],
            ),
            Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      size: 16,
                      color: index < rating ? starColor : Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(date, style: TextStyle(color: textGrey, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          comment,
          style: TextStyle(color: textGrey, height: 1.4, fontSize: 14),
        ),
      ],
    );
  }
}
