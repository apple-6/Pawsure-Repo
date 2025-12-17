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

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFEE2E2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
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
          backgroundColor: const Color(0xFF22C55E).withOpacity(0.1),
          colorText: const Color(0xFF166534),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } catch (e) {
        debugPrint('❌ Error during logout: $e');
        Get.snackbar(
          'Error',
          'Failed to logout: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Get.snackbar(
                  'Coming Soon',
                  'Settings will be available soon!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  colorText: Colors.blue[800],
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              },
              icon: const Icon(
                Icons.settings_outlined,
                size: 20,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
        toolbarHeight: 64,
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF22C55E),
            ),
          );
        }

        final userName = profileController.user['name'] as String? ?? '';
        final userEmail = profileController.user['email'] as String? ?? '';
        final userRole =
            profileController.user['role'] as String? ?? 'Pet Owner';
        final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isNotEmpty ? userName : 'User',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              userRole,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Get.snackbar(
                            'Coming Soon',
                            'Edit profile feature will be available soon!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            colorText: Colors.blue[800],
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.pets,
                      label: 'Pets',
                      value: '2',
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.favorite,
                      label: 'Favorites',
                      value: '5',
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_today,
                      label: 'Bookings',
                      value: '3',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Menu Section
              const Text(
                'Account',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              _MenuCard(
                items: [
                  _MenuItem(
                    icon: Icons.pets,
                    title: 'My Pets',
                    subtitle: 'Manage your pets',
                    iconColor: const Color(0xFF22C55E),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MyPetsScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.favorite_border,
                    title: 'Favourite Sitters',
                    subtitle: 'Your saved sitters',
                    iconColor: const Color(0xFFEF4444),
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Favourite Sitters feature will be available soon!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        colorText: Colors.blue[800],
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    subtitle: 'Manage payment options',
                    iconColor: const Color(0xFF3B82F6),
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Payment Methods feature will be available soon!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        colorText: Colors.blue[800],
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Role',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              _MenuCard(
                items: [
                  _MenuItem(
                    icon: Icons.person_add_outlined,
                    title: 'Become a Sitter',
                    subtitle: 'Start earning as a pet sitter',
                    iconColor: const Color(0xFFF59E0B),
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Sitter registration will be available soon!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        colorText: Colors.blue[800],
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Support',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              _MenuCard(
                items: [
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and FAQs',
                    iconColor: const Color(0xFF6B7280),
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Help & Support feature will be available soon!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        colorText: Colors.blue[800],
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.logout,
                    title: 'Log Out',
                    subtitle: 'Sign out of your account',
                    iconColor: const Color(0xFFDC2626),
                    onTap: () => _handleLogout(context),
                    showDivider: false,
                    isDestructive: true,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // App Version
              Center(
                child: Text(
                  'Pawsure v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
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
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;
  final bool showDivider;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
    this.showDivider = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: showDivider
              ? null
              : const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
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
        if (showDivider)
          Divider(
            height: 1,
            indent: 74,
            endIndent: 16,
            color: Colors.grey[200],
          ),
      ],
    );
  }
}
