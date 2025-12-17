import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/constants/api_endpoints.dart';

class SitterDetailsScreen extends StatefulWidget {
  final String sitterId;

  const SitterDetailsScreen({super.key, required this.sitterId});

  @override
  State<SitterDetailsScreen> createState() => _SitterDetailsScreenState();
}

class _SitterDetailsScreenState extends State<SitterDetailsScreen> {
  late Future<Map<String, dynamic>> _sitterFuture;

  // Use centralized API endpoint
  String get baseUrl => ApiEndpoints.baseUrl;

  @override
  void initState() {
    super.initState();
    _sitterFuture = _fetchSitterData();
  }

  Future<Map<String, dynamic>> _fetchSitterData() async {
    final url = '$baseUrl/sitters/${widget.sitterId}';

    try {
      print("Attempting to fetch: $url"); // Debug print to see exact URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      // Re-throw with a clearer message for the UI
      throw Exception('Failed to connect to $url.\n\nError: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<Map<String, dynamic>>(
        future: _sitterFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF34D399)),
            );
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Connection Error",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _sitterFuture = _fetchSitterData();
                        });
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Sitter not found"));
          }

          // 3. Data Loaded - Map JSON to your existing UI variables
          final data = snapshot.data!;
          final user = data['user'] ?? {};
          final List<dynamic> reviewsData = data['reviews'] ?? [];

          // --- MAPPING BACKEND DATA TO UI ---

          // Logic to handle photo_gallery (comma separated string) -> First Image
          String? galleryImage;
          if (data['photo_gallery'] != null &&
              data['photo_gallery'].toString().isNotEmpty) {
            galleryImage = data['photo_gallery']
                .toString()
                .split(',')
                .first
                .trim();
          }
          final String imageUrl =
              galleryImage ??
              user['profile_picture'] ??
              'https://via.placeholder.com/400';

          final bool isVerified = data['status'] == 'approved';
          final String name = user['name'] ?? 'Sitter Name';

          // Handle ratings that might come as int or double
          final double rating = (data['rating'] ?? data['avgRating'] ?? 0)
              .toDouble();
          final int reviewCount =
              data['reviews_count'] ?? data['reviewCount'] ?? 0;

          final String location =
              data['address'] ?? data['location'] ?? 'Unknown Location';

          // Handle price parsing safely
          final double price =
              double.tryParse(data['ratePerNight'].toString()) ??
              double.tryParse(data['price'].toString()) ??
              0.0;

          final String bio = data['bio'] ?? 'No bio available';
          final String houseType = data['houseType'] ?? 'Apartment';

          // Logic for bookings
          final int bookingsLen = (data['bookings'] as List? ?? []).length;
          final String bookingsCompleted = "$bookingsLen+ bookings";

          // Mapped services from backend instead of hardcoded
          final String servicesString =
              data['experience'] ??
              data['services'] ??
              "House Sitting,Dog Walking";
          final List<String> petTypes = [
            "Dog",
            "Cat",
          ]; // This can remain hardcoded or fetched if API has it

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. Top Image & Back Button ---
                Stack(
                  children: [
                    SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[300]),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back, size: 20),
                          ),
                        ),
                      ),
                    ),
                    if (isVerified)
                      Positioned(
                        top: 40,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF34D399,
                            ), // Green verify color
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Verified",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                // --- 2. Profile Details Content ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFF34D399),
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$rating ($reviewCount reviews)",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // --- 3. Rate & Booking Card ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE6F7F0,
                          ), // Very light green background
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Nightly Rate",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "RM${price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF34D399),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Booking feature coming soon!",
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF34D399),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Book Now",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- 4. Experience (Combined About Me + Experience) ---
                      _buildSectionCard(
                        title: "Experience",
                        icon: Icons.pets,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bio,
                              style: const TextStyle(
                                color: Colors.black87,
                                height: 1.5,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              bookingsCompleted,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- 5. Pet Sitting Environment ---
                      _buildSectionCard(
                        title: "Pet Sitting Environment",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display House Type here
                            Row(
                              children: [
                                const Icon(
                                  Icons.home_work_outlined,
                                  size: 18,
                                  color: Color(0xFF34D399),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Property Type: $houseType",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Photos Row
                            Row(
                              children: [
                                _buildEnvironmentPlaceholder(),
                                const SizedBox(width: 12),
                                _buildEnvironmentPlaceholder(),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- 6. Services Offered ---
                      _buildSectionCard(
                        title: "Services Offered",
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: servicesString
                              .split(',')
                              .map((service) => _buildChip(service.trim()))
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // --- 8. Rate / Reviews ---
                      _buildSectionCard(
                        title: "Reviews",
                        trailing: GestureDetector(
                          onTap: () {
                            // Navigation to full review list would go here
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("See more clicked")),
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              "See more",
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        child: Column(
                          // Only show first 2 reviews here
                          children: reviewsData
                              .take(2)
                              .map((review) => _buildReviewItem(review))
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    IconData? icon,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: const Color(0xFF34D399), size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isGreen = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isGreen ? const Color(0xFF34D399) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isGreen ? Colors.white : Colors.black87,
          fontSize: 13,
          fontWeight: isGreen ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEnvironmentPlaceholder() {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Icon(Icons.camera_alt_outlined, color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildReviewItem(dynamic reviewData) {
    // Parsing review data safely
    final String userName = reviewData['userName'] ?? 'User';
    // Handle date formatting as needed
    final String date = reviewData['created_at'] != null
        ? reviewData['created_at'].toString().substring(0, 10)
        : 'Recent';
    final double rating = (reviewData['rating'] ?? 5).toDouble();
    final String comment = reviewData['comment'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  child: Icon(Icons.person_outline, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
