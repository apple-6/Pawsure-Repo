import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/sitter_model.dart';
import '../../constants/api_config.dart';

class SitterPreviewPage extends StatefulWidget {
  final UserProfile user;
  final List<dynamic> initialReviews; // Renamed to initialReviews

  const SitterPreviewPage({
    super.key,
    required this.user,
    this.initialReviews = const [],
  });

  @override
  State<SitterPreviewPage> createState() => _SitterPreviewPageState();
}

class _SitterPreviewPageState extends State<SitterPreviewPage> {
  late List<dynamic> _reviews;
  bool _isLoadingReviews = false;

  // Colors
  final Color brandColor = const Color(0xFF2ECA6A);
  final Color brandLight = const Color(0xFFE8F5E9);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF6B7280);
  final Color starColor = const Color(0xFFFBBF24);

  @override
  void initState() {
    super.initState();
    // Initialize with passed reviews, then fetch fresh ones
    _reviews = widget.initialReviews;
    _fetchReviews();
  }

  // ✅ FETCH REVIEWS FROM BACKEND
  Future<void> _fetchReviews() async {
    if (_reviews.isNotEmpty) return; // Optional: Skip if we already passed data

    setState(() => _isLoadingReviews = true);

    try {
      // Assuming widget.user.id is the USER ID. 
      // We hit the endpoint that gets sitter profile by User ID.
      final url = Uri.parse('${ApiConfig.baseUrl}/sitters/user/${widget.user.id}');
      
      print("Fetching reviews from: $url");
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['reviews'] != null) {
          setState(() {
            _reviews = data['reviews'];
          });
        }
      } else {
        print("Failed to load reviews: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching reviews: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Preview as Owner",
          style: TextStyle(color: textGrey, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textDark),
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
                      child: Icon(
                        Icons.person_outline,
                        size: 40,
                        color: brandColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(
                    widget.user.name,
                    style: TextStyle(
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
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.user.location,
                        style: TextStyle(color: textGrey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: starColor, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.user.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // ✅ UPDATED: Use _reviews.length
                      Text(
                        "(${_reviews.length} Reviews)", 
                        style: TextStyle(color: textGrey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: brandLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 16,
                              color: brandColor,
                            ),
                            const SizedBox(width: 4),
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
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: textGrey,
                            ),
                            const SizedBox(width: 4),
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
                  Text(
                    "About Me",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user.bio,
                    style: TextStyle(color: textGrey, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildStatItem(
                        Icons.access_time,
                        "${widget.user.experienceYears} years exp.",
                        textGrey,
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        Icons.calendar_today_outlined,
                        "${widget.user.staysCompleted} stays completed",
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
                  Text(
                    "Services & Rates",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.user.services.isEmpty)
                    Text("No services listed yet.",
                        style: TextStyle(color: textGrey))
                  else
                    ...widget.user.services
                        .where((s) => s.isActive)
                        .map((service) {
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
                    }).toList(),
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
                    children: [
                      Text(
                        "Reviews",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      // Only show "See more" if > 2 reviews
                      if (_reviews.length > 2)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AllReviewsScreen(reviews: _reviews),
                              ),
                            );
                          },
                          child: Text(
                            "See more",
                            style: TextStyle(
                              color: brandColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                        Text("${_reviews.length} total",
                            style: TextStyle(color: textGrey)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Show Loading or Data
                  if (_isLoadingReviews)
                    const Center(child: CircularProgressIndicator())
                  else if (_reviews.isEmpty)
                    Text("No reviews yet.",
                        style: TextStyle(
                            color: textGrey, fontStyle: FontStyle.italic))
                  else
                    Column(
                      children: _reviews
                          .take(2)
                          .map((review) => ReviewCard(reviewData: review))
                          .toList(),
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

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
}

// ===========================================================================
// EXTERNAL CLASSES
// ===========================================================================

class AllReviewsScreen extends StatelessWidget {
  final List<dynamic> reviews;

  const AllReviewsScreen({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("All Reviews", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: reviews.isEmpty
          ? const Center(child: Text("No reviews yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ReviewCard(reviewData: reviews[index]);
              },
            ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final dynamic reviewData;

  const ReviewCard({super.key, required this.reviewData});

  @override
  Widget build(BuildContext context) {
    final owner = reviewData['owner'];
    final String userName =
        owner != null ? (owner['name'] ?? 'Anonymous') : 'User';

    // --- Image Logic ---
    String? finalProfileUrl;
    if (owner != null && owner['profile_picture'] != null) {
      String rawPic = owner['profile_picture'].toString();
      if (rawPic.isNotEmpty) {
        if (rawPic.startsWith('file:') ||
            rawPic.contains('C:/') ||
            rawPic.contains('/Users/')) {
          finalProfileUrl = null;
        } else if (rawPic.startsWith('http')) {
          finalProfileUrl = rawPic;
        } else {
          finalProfileUrl =
              "${ApiConfig.supabaseUrl}/storage/v1/object/public/profile_pictures/$rawPic";
        }
      }
    }
    // ----------------------------

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
                  backgroundColor: Colors.grey[200],
                  radius: 20,
                  foregroundImage: (finalProfileUrl != null)
                      ? NetworkImage(finalProfileUrl)
                      : null,
                  onForegroundImageError: (finalProfileUrl != null)
                      ? (_, __) {}
                      : null,
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
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
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