import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/screens/profile/my_pets_screen.dart';
import 'package:pawsure_app/screens/profile/payment_methods_screen.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/controllers/home_controller.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';
import 'package:pawsure_app/services/storage_service.dart';
import 'package:pawsure_app/constants/api_config.dart'; // 1. ADD THIS IMPORT
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        final storageService = Get.find<StorageService>();
        await storageService.deleteToken();

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final userName = profileController.user['name'] as String? ?? '';
        final userEmail = profileController.user['email'] as String? ?? '';
        final userRole = profileController.user['role'] as String? ?? 'owner';
        final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        // --- 2. UPDATED IMAGE LOGIC START ---
        String? avatarPath = profileController.user['avatar'];
        String? fullAvatarUrl;

        // Construct the URL dynamically based on environment (Emulator vs Real Device)
        if (avatarPath != null && avatarPath.isNotEmpty) {
          if (avatarPath.startsWith('http')) {
            fullAvatarUrl = avatarPath; // Use existing full URL
          } else {
            // Combine API Config Base URL + Relative Path
            // e.g. http://10.0.2.2:3000/uploads/image.jpg
            fullAvatarUrl = '${ApiConfig.baseUrl}/$avatarPath';
          }
        }

        final bool hasAvatar = fullAvatarUrl != null;
        // --- UPDATED IMAGE LOGIC END ---

        // Get pets count
        int petsCount = 0;
        if (Get.isRegistered<PetController>()) {
          petsCount = Get.find<PetController>().pets.length;
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF22C55E),
                      Color(0xFF16A34A),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      children: [
                        // Top Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.to(() => const EditProfileScreen());
                              },
                              icon: const Icon(Icons.edit, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Profile Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      // If NO avatar, show the Green Gradient. If avatar exists, remove gradient.
                                      gradient: hasAvatar
                                          ? null
                                          : const LinearGradient(
                                              colors: [Color(0xFF22C55E), Color(0xFF86EFAC)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                      // If avatar exists, show the Image
                                      image: hasAvatar
                                          ? DecorationImage(
                                              image: NetworkImage(fullAvatarUrl!), // Use computed URL
                                              fit: BoxFit.cover,
                                              onError: (exception, stackTrace) {
                                                debugPrint("Error loading avatar: $exception");
                                              },
                                            )
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF22C55E).withOpacity(0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    // If NO avatar, show the "Initial" Text
                                    child: hasAvatar
                                        ? null
                                        : Center(
                                            child: Text(
                                              initial,
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  // User Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName.isNotEmpty ? userName : 'User',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          userEmail,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Role Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: userRole == 'sitter'
                                                ? const Color(0xFFDCFCE7)
                                                : const Color(0xFFEDE9FE),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            userRole == 'sitter'
                                                ? '🐾 Pet Sitter'
                                                : '🏠 Pet Owner',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: userRole == 'sitter'
                                                  ? const Color(0xFF166534)
                                                  : const Color(0xFF7C3AED),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Menu Sections
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet Management Section
                    _buildSectionTitle('Pet Management'),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      children: [
                        _buildMenuItem(
                          icon: Icons.pets,
                          iconBg: const Color(0xFFDCFCE7),
                          iconColor: const Color(0xFF22C55E),
                          title: 'My Pets',
                          subtitle: 'Manage your pets',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MyPetsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          icon: Icons.favorite,
                          iconBg: const Color(0xFFFCE7F3),
                          iconColor: const Color(0xFFEC4899),
                          title: 'Favourite Sitters',
                          subtitle: 'Your saved sitters',
                          onTap: () => _showComingSoon('Favourite Sitters'),
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          icon: Icons.history,
                          iconBg: const Color(0xFFEDE9FE),
                          iconColor: const Color(0xFF8B5CF6),
                          title: 'Booking History',
                          subtitle: 'Past bookings',
                          onTap: () => _showComingSoon('Booking History'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Account Section
                    _buildSectionTitle('Account'),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      children: [
                        _buildMenuItem(
                          icon: Icons.payment,
                          iconBg: const Color(0xFFDCFCE7),
                          iconColor: const Color(0xFF22C55E),
                          title: 'Payment Methods',
                          subtitle: 'Manage your payments',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PaymentMethodsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          icon: Icons.swap_horiz,
                          iconBg: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Switch to Sitter Mode',
                          subtitle: 'Become a pet sitter',
                          onTap: () => profileController.handleSitterSwitch(),
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          icon: Icons.notifications,
                          iconBg:  const Color.fromARGB(160, 178, 230, 224),
                          iconColor: Colors.teal,
                          title: 'Notifications',
                          subtitle: 'Manage alerts',
                          onTap: () => _showComingSoon('Notifications'),
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          icon: Icons.settings,
                          iconBg: const Color(0xFFF3F4F6),
                          iconColor: const Color(0xFF6B7280),
                          title: 'Settings',
                          subtitle: 'App preferences',
                          onTap: () => _showComingSoon('Settings'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Support Section
                    _buildSectionTitle('Support'),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      children: [
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          iconBg: const Color(0xFFDBEAFE),
                          iconColor: const Color(0xFF3B82F6),
                          title: 'Help & Support',
                          subtitle: 'Get assistance',
                          onTap: () => _showComingSoon('Help & Support'),
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          iconBg: const Color(0xFFE0E7FF),
                          iconColor: const Color(0xFF6366F1),
                          title: 'About Pawsure',
                          subtitle: 'Version 1.0.0',
                          onTap: () => _showComingSoon('About'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleLogout(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMenuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey[100]),
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E).withOpacity(0.1),
      colorText: const Color(0xFF166534),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}