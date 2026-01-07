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
    final double rate = post.ratePerNight;
    final List<String> petNames = post.petNames;

    final String startDate = post.startDate != null
        ? DateFormat('MMM d').format(post.startDate!)
        : 'N/A';
    final String endDate = post.endDate != null
        ? DateFormat('MMM d').format(post.endDate!)
        : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Standardized Title
            const Text(
              "Job Vacancy",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Date Row
            _buildInfoRow(
              Icons.calendar_today_outlined,
              "Date:",
              "$startDate - $endDate",
            ),
            const SizedBox(height: 8),

            // Rate Row
            _buildInfoRow(
              Icons.payments_outlined,
              "Rate:",
              "RM ${rate.toStringAsFixed(2)} /night",
              valueColor: Colors.green.shade700,
            ),
            const SizedBox(height: 8),

            // Pets to Sit Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.pets_outlined, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  "Pets to sit: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(petNames.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          if (post.pets != null && post.pets!.isNotEmpty) {
                            Get.to(
                              () => const PetProfileView(),
                              arguments: {
                                'pet': post.pets![index],
                                'dateRange': "$startDate - $endDate",
                                'estEarning': "RM ${rate.toStringAsFixed(2)}",
                              },
                            );
                          }
                        },
                        child: Text(
                          "${petNames[index]}${index < petNames.length - 1 ? ',' : ''}",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            // Short Description/Content
            Text(
              post.content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Apply Button - Visible for sitters only
            if (isUserSitter) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Apply Now",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper widget for consistent rows
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
