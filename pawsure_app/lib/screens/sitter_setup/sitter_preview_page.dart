import 'package:flutter/material.dart';

class SitterPreviewPage extends StatelessWidget {
  const SitterPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors extracted from your images
    const Color brandColor = Color(0xFF2ECA6A);
    const Color brandLight = Color(0xFFE8F5E9);
    const Color textDark = Color(0xFF1F2937);
    const Color textGrey = Color(0xFF6B7280);
    const Color starColor = Color(0xFFFBBF24);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
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
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: brandLight,
                      child: Icon(
                        Icons.person_outline,
                        size: 40,
                        color: brandColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  const Text(
                    "Aisha B.",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: textGrey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Petaling Jaya, Selangor",
                        style: TextStyle(color: textGrey),
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
                  const Text(
                    "Hi! I'm Aisha, an experienced pet sitter with over 3 years of caring for furry friends. I grew up with dogs and cats, so I understand their needs and behaviors. I treat every pet like my own family member and ensure they receive the love and attention they deserve.",
                    style: TextStyle(color: textGrey, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Stats Row
                  Row(
                    children: [
                      _buildStatItem(
                        Icons.access_time,
                        "3 years exp.",
                        textGrey,
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        Icons.calendar_today_outlined,
                        "32 stays completed",
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
                  _buildServiceRow("Dog Boarding", "RM 80/night", brandColor),
                  const Divider(height: 24),
                  _buildServiceRow("Dog Walking", "RM 25/hour", brandColor),
                  const Divider(height: 24),
                  _buildServiceRow("Pet Sitting", "RM 60/visit", brandColor),
                  const Divider(height: 24),
                  _buildServiceRow(
                    "Overnight Care",
                    "RM 100/night",
                    brandColor,
                  ),
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

                  // Review 1
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
                  const Divider(height: 30),

                  // Review 2
                  _buildReviewItem(
                    name: "John D.",
                    petName: "Bella",
                    date: "Sep 2024",
                    rating: 5,
                    comment:
                        "Very professional and caring. Bella loved staying with her.",
                    starColor: starColor,
                    textGrey: textGrey,
                  ),
                  const Divider(height: 30),

                  // Review 3
                  _buildReviewItem(
                    name: "Lisa K.",
                    petName: "Charlie",
                    date: "Aug 2024",
                    rating: 5,
                    comment:
                        "Great communication throughout the stay. Would book again.",
                    starColor: starColor,
                    textGrey: textGrey,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- 5. BOTTOM BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {}, // Disabled for preview or show snackbar
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF86EFAC,
                  ), // Lighter green as seen in image
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

  // 1. Generic Card Container
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // 2. Stat Item (Icon + Text)
  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }

  // 3. Service Row (Name .... Price)
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

  // 4. Review Item
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
