import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal[100],
      ),
      body: Obx(() {
        final user = controller.user;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                      radius: 36, child: Icon(Icons.person, size: 36)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user['firstName']} ${user['lastName']}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(user['email'] ?? '',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // TODO: Replace with profile edit screen and backend call
                  await controller.updateProfile(
                      {'firstName': 'Updated', 'lastName': 'User'});
                  Get.snackbar(
                      'Updated', 'Profile updated locally (placeholder)');
                },
                child: const Text('Edit Profile (placeholder)'),
              )
            ],
          ),
        );
      }),
    );
  }
}
