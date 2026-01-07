import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:pawsure_app/models/post_model.dart';
import 'package:pawsure_app/screens/sitter_setup/view_pet_profile.dart';

class VacancyPostCard extends StatelessWidget {
  final PostModel post; // Your post data object
  final bool
  isUserSitter; // Pass true if user role is 'sitter', false for 'owner'
  final VoidCallback onApply;

  const VacancyPostCard({
    super.key,
    required this.post,
    required this.isUserSitter,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    // Extracting data from the post object
    final String content = post.content;
    final double rate = post.ratePerNight;
    final List<String> petNames = post.petNames;

    final String startDate = post.startDate != null
        ? DateFormat('MMM d').format(post.startDate!)
        : '';
    final String endDate = post.endDate != null
        ? DateFormat('MMM d').format(post.endDate!)
        : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Dates and Rate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "$startDate - $endDate",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Rate Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    "\$$rate/night",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              content,
              style: const TextStyle(fontSize: 15),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Pets List
            if (petNames.isNotEmpty) ...[
              const Text(
                "Pets to sit:",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(petNames.length, (index) {
                  final name = petNames[index];

                  return GestureDetector(
                    onTap: () {
                      // Check if full pet objects exist in the post model
                      if (post.pets != null && post.pets!.isNotEmpty) {
                        Get.to(
                          () => const PetProfileView(),
                          arguments: {
                            'pet': post.pets![index], // Passes full Pet model
                            'dateRange': "$startDate - $endDate",
                            'estEarning':
                                "\$${post.ratePerNight.toStringAsFixed(2)}",
                          },
                        );
                      } else {
                        debugPrint(
                          "⚠️ No detailed pet data available for $name",
                        );
                      }
                    },
                    child: Chip(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.blue.withOpacity(
                        0.05,
                      ), // Light blue tint
                      side: BorderSide(color: Colors.blue.withOpacity(0.2)),
                      avatar: const Icon(
                        Icons.pets,
                        size: 14,
                        color: Colors.blue,
                      ),
                      label: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          //decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ] else ...[
              const Text(
                "No pets specified",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],

            // Apply Button - Only visible for sitters
            if (isUserSitter) ...[
              const SizedBox(height: 12),
              const Divider(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Apply Now"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
