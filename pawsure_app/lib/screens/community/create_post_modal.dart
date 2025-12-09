import 'package:flutter/material.dart';

class CreatePostModal extends StatefulWidget {
  final VoidCallback onPostCreated;

  const CreatePostModal({super.key, required this.onPostCreated});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  // State to manage the urgent toggle
  bool isUrgent = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Post',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                hintText: 'What\'s new with your pet?',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            
            // --- NEW: Urgent Toggle ---
            SwitchListTile(
              title: const Text('Mark as Urgent (Lost Pet, Blood Need, etc.)'),
              subtitle: const Text('This post will appear in the Urgent tab.'),
              value: isUrgent,
              onChanged: (bool value) {
                setState(() {
                  isUrgent = value;
                });
              },
              activeColor: Colors.red,
              contentPadding: EdgeInsets.zero,
            ),
            // --- END NEW ---

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Here you would call an API to create the post
                    // and pass the `isUrgent` status.
                    
                    // Simulate post creation logic
                    Navigator.pop(context);
                    widget.onPostCreated();
                  },
                  child: const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}