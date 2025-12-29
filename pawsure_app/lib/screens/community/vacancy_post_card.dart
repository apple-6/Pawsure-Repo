import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VacancyPostCard extends StatelessWidget {
  final dynamic post; // Use your Post model, but ensure it has vacancy fields
  final VoidCallback onApply;

  const VacancyPostCard({super.key, required this.post, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Header
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.profilePicture),
                ),
                const SizedBox(width: 12),
                Text(
                  post.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Badge(label: Text("JOB"), backgroundColor: Colors.green),
              ],
            ),
            const Divider(height: 24),

            // Job Details Section
            // Inside VacancyPostCard build method
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  // Use the actual dates from the post object instead of .add(Duration(days: 2))
                  "${DateFormat('MMM d').format(post.startDate)} - ${DateFormat('MMM d').format(post.endDate)}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.content), // The caption

            const SizedBox(height: 16),

            // Application Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Apply Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
