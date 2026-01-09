// pawsure_app/lib/screens/community/sitter_details.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/screens/community/booking_modal.dart';
import 'package:pawsure_app/constants/api_config.dart';

class SitterDetailsScreen extends StatefulWidget {
  final String sitterId;
  final DateTime? startDate;
  final DateTime? endDate;

  const SitterDetailsScreen({
    super.key,
    required this.sitterId,
    this.startDate,
    this.endDate,
  });

  @override
  State<SitterDetailsScreen> createState() => _SitterDetailsScreenState();
}

class _SitterDetailsScreenState extends State<SitterDetailsScreen> {
  late Future<Map<String, dynamic>> _sitterFuture;

  @override
  void initState() {
    super.initState();
    _sitterFuture = _fetchSitterData();
  }

  Future<Map<String, dynamic>> _fetchSitterData() async {
    final url = '${ApiConfig.baseUrl}/sitters/${widget.sitterId}';

    try {
      print("Attempting to fetch: $url");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
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

          // 3. Data Loaded
          final data = snapshot.data!;
          final user = data['user'] ?? {};
          final List<dynamic> reviewsData = data['reviews'] ?? [];

         String? rawFilename;
          final dynamic gallery = data['photo_gallery'];

          if (gallery != null) {
            if (gallery is List && gallery.isNotEmpty) {
              // If backend returns a List (e.g. ["url1", "url2"])
              rawFilename = gallery.first.toString();
            } else if (gallery is String && gallery.isNotEmpty) {
              // If backend returns a String (e.g. "url1,url2")
              // Remove brackets just in case it's a stringified list "[url1]"
              String cleanString = gallery.replaceAll('[', '').replaceAll(']', '');
              rawFilename = cleanString.split(',').first.trim();
            }
          }

          // Construct the Full URL
          String imageUrl;
          if (rawFilename != null && rawFilename.isNotEmpty) {
            if (rawFilename.startsWith('http')) {
              imageUrl = rawFilename;
            } else {
              // Fallback for Supabase paths if needed
              imageUrl = "${ApiConfig.supabaseUrl}/storage/v1/object/public/sitter_gallery/$rawFilename";
            }
          } else {
            // Fallback to profile picture or placeholder
            imageUrl = user['profile_picture'] ?? 
                       'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=400&q=80';
          }
          // ---------------------------
          final bool isVerified = data['status'] == 'approved';
          final String name = user['name'] ?? 'Sitter Name';

          final double rating = (data['rating'] ?? data['avgRating'] ?? 0)
              .toDouble();
         final int reviewCount = data['reviewCount'] ?? 
                                  data['reviews_count'] ?? 
                                  data['review_count'] ?? 
                                  0;

          final String location =
              data['address'] ?? data['location'] ?? 'Unknown Location';

          final double price =
              double.tryParse(data['ratePerNight'].toString()) ??
              double.tryParse(data['price'].toString()) ??
              0.0;

          final String bio = data['bio'] ?? 'No bio available';
          // 1. Fetch the raw string from the database (e.g., "condo", "apartment")
          String rawHouseType = data['houseType']?.toString() ?? 'Apartment';

          // 2. Capitalize the first letter (e.g., convert "condo" -> "Condo")
          final String houseType = rawHouseType.isNotEmpty
              ? "${rawHouseType[0].toUpperCase()}${rawHouseType.substring(1)}"
              : rawHouseType;

          final int bookingsLen = (data['bookings'] as List? ?? []).length;
          final String bookingsCompleted = "$bookingsLen+ bookings";

          // --- MODIFIED: PARSE SERVICES (Now captures Price & Unit) ---
          List<Map<String, dynamic>> servicesList = [];
          final dynamic rawServices = data['services'];

          if (rawServices is List) {
            // Case 1: Database returns a JSON List
            for (var item in rawServices) {
              if (item is Map && item['name'] != null) {
                if (item['isActive'] != false) {
                  servicesList.add({
                    'name': item['name'].toString(),
                    'price':
                        item['price']?.toString() ??
                        price.toStringAsFixed(0), // Fallback to base price
                    'unit': item['unit']?.toString() ?? '', // e.g. "/hr"
                  });
                }
              }
            }
          } else if (rawServices is String) {
            // Case 2: Fallback for JSON strings
            if (rawServices.trim().startsWith('[')) {
              try {
                final List decoded = jsonDecode(rawServices);
                for (var item in decoded) {
                  if (item is Map &&
                      item['name'] != null &&
                      item['isActive'] != false) {
                    servicesList.add({
                      'name': item['name'].toString(),
                      'price':
                          item['price']?.toString() ?? price.toStringAsFixed(0),
                      'unit': item['unit']?.toString() ?? '',
                    });
                  }
                }
              } catch (_) {}
            }
          }

          String rawExp = data['experience']?.toString() ?? "1";

          String yearsExp = rawExp.replaceAll(RegExp(r'[^0-9]'), '');
          if (yearsExp.isEmpty) yearsExp = "0";

          final String experienceText = "$yearsExp Years Experience";

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            child: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Colors.black87,
                            ),
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
                            color: const Color(0xFF34D399),
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
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                          color: const Color(0xFFE6F7F0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        // Removed Column and price Text widgets, keeping only the button
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => BookingModal(
                                  sitterId: widget.sitterId,
                                  sitterName: name,
                                  ratePerNight: price,
                                  startDate: widget.startDate,
                                  endDate: widget.endDate,
                                  services: servicesList,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF34D399),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                      ),

                      const SizedBox(height: 24),

                      // --- 4. Experience ---
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
                            const SizedBox(height: 16),

                            // 2. Stats Row (Bookings & Years of Experience)
                            Row(
                              children: [
                                // Bookings Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF0FDF4,
                                    ), // Light Green
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFDCFCE7),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Color(0xFF059669),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        bookingsCompleted,
                                        style: const TextStyle(
                                          color: Color(0xFF059669),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Years of Experience Badge (Moved Here)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 16,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        experienceText,
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                        // Check if list is empty
                        child: servicesList.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "No specific services offered at this time.",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            : Column(
                                children: servicesList.map((service) {
                                  return Column(
                                    children: [
                                      _buildServiceRow(
                                        service['name'],
                                        "RM ${service['price']}${service['unit']}",
                                        const Color(0xFF34D399),
                                      ),
                                      // Only show divider if it's not the last item (optional polish)
                                      if (service != servicesList.last)
                                        const Divider(height: 24),
                                    ],
                                  );
                                }).toList(),
                              ),
                      ),

                      const SizedBox(height: 16),

                      // --- 8. Reviews ---
                      // _buildSectionCard(
                      //   title: "Reviews",
                      //   trailing: GestureDetector(
                      //     onTap: () {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         const SnackBar(content: Text("See more clicked")),
                      //       );
                      //     },
                      //     behavior: HitTestBehavior.opaque,
                      //     child: const Padding(
                      //       padding: EdgeInsets.only(left: 8.0),
                      //       child: Text(
                      //         "See more",
                      //         style: TextStyle(
                      //           color: Color(0xFF34D399),
                      //           fontWeight: FontWeight.bold,
                      //           fontSize: 14,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      //   child: Column(
                      //     children: reviewsData
                      //         .take(2)
                      //         .map((review) => _buildReviewItem(review))
                      //         .toList(),
                      //   ),
                      // ),
                     _buildSectionCard(
                        title: "Reviews",
                        // ✅ OPTIONAL IMPROVEMENT: Only show "See more" if there are more than 2 reviews
                        trailing: reviewsData.length > 2 
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AllReviewsScreen(reviews: reviewsData),
                                    ),
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
                              )
                            : null, // Hide button if 2 or fewer reviews
                        child: Column(
                          children: reviewsData
                              .take(2)
                              .map((review) => ReviewCard(reviewData: review))
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

// Widget _buildReviewItem(dynamic reviewData) {
//     final owner = reviewData['owner'];
//     final String userName = owner != null ? (owner['name'] ?? 'Anonymous') : 'User';
    
//     // ---------------------------------------------------------
//     // 1. Image Logic: Construct the full URL
//     // ---------------------------------------------------------
//     String? finalProfileUrl;
    
//     if (owner != null && owner['profile_picture'] != null) {
//       String rawPic = owner['profile_picture'].toString();
      
//       if (rawPic.isNotEmpty) {
//         if (rawPic.startsWith('http')) {
//           // Case A: It's already a full URL (like PostCard)
//           finalProfileUrl = rawPic;
//         } else {
//           // Case B: It's just a filename. We MUST prepend the Supabase path.
//           // Note: Ensure 'profile_pictures' matches your Supabase bucket name for users
//           finalProfileUrl = "${ApiConfig.supabaseUrl}/storage/v1/object/public/profile_pictures/$rawPic";
//         }
//       }
//     }
//     // ---------------------------------------------------------

//     final String date = reviewData['created_at'] != null
//         ? reviewData['created_at'].toString().substring(0, 10)
//         : 'Recent';
//     final double rating = (reviewData['rating'] ?? 5).toDouble();
//     final String comment = reviewData['comment'] ?? '';

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade200),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 // ------------------------------------------------
//                 // 2. Display Logic (Matches PostCard style)
//                 // ------------------------------------------------
//                 CircleAvatar(
//                   backgroundColor: Colors.grey[200],
//                   radius: 20,
//                   // If we successfully built a URL, display it
//                   backgroundImage: (finalProfileUrl != null)
//                       ? NetworkImage(finalProfileUrl)
//                       : null,
//                   // If no URL, show the fallback icon
//                   child: (finalProfileUrl == null)
//                       ? Icon(Icons.person_outline, color: Colors.grey[600])
//                       : null,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             userName,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                           Text(
//                             date,
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: List.generate(5, (index) {
//                           return Icon(
//                             index < rating ? Icons.star : Icons.star_border,
//                             color: Colors.amber,
//                             size: 14,
//                           );
//                         }),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               comment,
//               style: const TextStyle(fontSize: 13, color: Colors.black87),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

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

// ---------------------------------------------------------------------------
// 1. New Screen to display ALL reviews
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// 2. Reusable Widget for a single review (Logic extracted from your previous code)
// ---------------------------------------------------------------------------
class ReviewCard extends StatelessWidget {
  final dynamic reviewData;

  const ReviewCard({super.key, required this.reviewData});

  @override
  Widget build(BuildContext context) {
    final owner = reviewData['owner'];
    final String userName = owner != null ? (owner['name'] ?? 'Anonymous') : 'User';

    // --- Image Logic (Reused) ---
    String? finalProfileUrl;
    if (owner != null && owner['profile_picture'] != null) {
      String rawPic = owner['profile_picture'].toString();
      if (rawPic.isNotEmpty) {
        if (rawPic.startsWith('file:') || rawPic.contains('C:/') || rawPic.contains('/Users/')) {
          finalProfileUrl = null;
        } else if (rawPic.startsWith('http')) {
          finalProfileUrl = rawPic;
        } else {
          finalProfileUrl = "${ApiConfig.supabaseUrl}/storage/v1/object/public/profile_pictures/$rawPic";
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
                  // 1. Provide the image (or null)
                  foregroundImage: (finalProfileUrl != null)
                      ? NetworkImage(finalProfileUrl)
                      : null,
                  
                  // 2. ✅ FIX: Only provide the error handler if the image is NOT null
                  onForegroundImageError: (finalProfileUrl != null) 
                      ? (_, __) {} 
                      : null, 

                  // 3. Fallback child (shown if image is null or fails to load)
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            date,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
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
