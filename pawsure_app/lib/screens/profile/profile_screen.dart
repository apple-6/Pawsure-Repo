//pawsure_app\lib\screens\profile\profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/screens/profile/my_pets_screen.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/controllers/home_controller.dart';
import 'package:pawsure_app/services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Logout function
  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        final storageService = Get.find<StorageService>();
        await storageService.deleteToken();

        // Reset all controller states before logout
        if (Get.isRegistered<HealthController>()) {
          Get.find<HealthController>().resetState();
        }
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().resetState();
        }
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().resetState();
        }

        Get.deleteAll(force: false);
        Get.offAllNamed('/login');

        Get.snackbar(
          'Success',
          'You have been logged out',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        debugPrint('❌ Error during logout: $e');
        Get.snackbar(
          'Error',
          'Failed to logout: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        backgroundColor: Colors.teal[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'Edit profile feature will be available soon!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue.withOpacity(0.1),
                colorText: Colors.blue[800],
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final userName = profileController.user['name'] as String? ?? '';
        final userRole =
            profileController.user['role'] as String? ?? 'Pet Owner';
        final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green,
                    child: Text(
                      initial,
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : 'User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userRole,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.teal[100]),
                    onPressed: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Edit profile feature will be available soon!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        colorText: Colors.blue[800],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Menu List
              _buildMenuItem(
                context,
                title: 'My Pets',
                icon: Icons.pets,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MyPetsScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                title: 'My Favourite Sitters',
                icon: Icons.favorite_border,
                onTap: () {
                  Get.snackbar(
                    'Coming Soon',
                    'Favourite Sitters feature will be available soon!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    colorText: Colors.blue[800],
                  );
                },
              ),
              _buildMenuItem(
                context,
                title: 'Payment Methods',
                icon: Icons.payment,
                onTap: () {
                  Get.snackbar(
                    'Coming Soon',
                    'Payment Methods feature will be available soon!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    colorText: Colors.blue[800],
                  );
                },
              ),
              _buildMenuItem(
                context,
                title: 'Settings',
                icon: Icons.settings,
                onTap: () {
                  Get.snackbar(
                    'Coming Soon',
                    'Settings feature will be available soon!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    colorText: Colors.blue[800],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Role Section
              const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text(
                  'ROLE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              _buildMenuItem(
                context,
                title: 'Become a Sitter',
                icon: Icons.arrow_forward,
                onTap: () {
                  Get.snackbar(
                    'Coming Soon',
                    'Sitter registration will be available soon!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    colorText: Colors.blue[800],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Help and Log Out Section
              _buildMenuItem(
                context,
                title: 'Help & Support',
                icon: Icons.help_outline,
                onTap: () {
                  Get.snackbar(
                    'Coming Soon',
                    'Help & Support feature will be available soon!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    colorText: Colors.blue[800],
                  );
                },
              ),
              _buildMenuItem(
                context,
                title: 'Log Out',
                icon: Icons.exit_to_app,
                onTap: () => _handleLogout(context),
                color: Colors.red,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(title),
      onTap: onTap,
    );
  }
}
