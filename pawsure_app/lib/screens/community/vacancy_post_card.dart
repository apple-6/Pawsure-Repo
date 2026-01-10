import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawsure_app/models/post_model.dart';
import 'package:pawsure_app/screens/sitter_setup/view_pet_profile.dart';

class VacancyPostCard extends StatelessWidget {
  final PostModel post;
  final bool isUserSitter;
  final VoidCallback onApply;
  final Function(PostModel)? onEdit;
  final Function(PostModel)? onDelete;
  final bool showMenuOptions;

  const VacancyPostCard({
    super.key,
    required this.post,
    required this.isUserSitter,
    required this.onApply,
    this.onEdit,
    this.onDelete,
    required this.showMenuOptions,
  });

  // Helper to calculate total based on post data
  String _calculateTotalPay() {
    if (post.startDate == null || post.endDate == null) return "0.00";
    final int days = post.endDate!.difference(post.startDate!).inDays;
    final int nights = days <= 0 ? 1 : days;
    return (nights * post.ratePerNight).toStringAsFixed(2);
  }

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
            // --- TOP ROW: Title and Menu Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Job Vacancy",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (showMenuOptions)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call(post);
                      if (value == 'delete') onDelete?.call(post);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text("Delete", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // --- INFO SECTION ---
            _buildInfoRow(
              Icons.person_outline,
              "Posted by:",
              post.userName ?? "Unknown User",
              valueColor: Colors.blue.shade700,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              "Date:",
              "$startDate - $endDate",
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.payments_outlined,
              "Rate:",
              "RM ${rate.toStringAsFixed(2)} /night",
              valueColor: Colors.green.shade700,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.account_balance_wallet_outlined,
              "Total Pay:",
              "RM ${_calculateTotalPay()}",
              valueColor: Colors.orange.shade800,
            ),
            const SizedBox(height: 8),

            // --- PETS SECTION ---
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
                          if (post.pets.isNotEmpty) {
                            Get.to(
                              () => const PetProfileView(),
                              arguments: {
                                'pet': post.pets[index],
                                'dateRange': "$startDate - $endDate",
                                'estEarning': "RM ${_calculateTotalPay()}",
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

            // --- DESCRIPTION ---
            Text(
              post.content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // --- ACTION BUTTON ---
            if (isUserSitter) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Chat with Owner",
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

  // --- HELPER WIDGET ---
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
