import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawsure_app/constants/api_config.dart';
import 'package:pawsure_app/services/storage_service.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/controllers/home_controller.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';

// Navigation Imports
import 'sitter_calendar.dart';
import 'sitter_inbox.dart';
import 'sitter_dashboard.dart';
import 'sitter_preview_page.dart';
import 'sitter_edit_profile.dart';
import 'sitter_performance_page.dart';
import '../../models/sitter_model.dart';
import '../../services/api_service.dart';

class SitterSettingScreen extends StatefulWidget {
  const SitterSettingScreen({super.key});

  @override
  State<SitterSettingScreen> createState() => _SitterSettingScreenState();
}

class _SitterSettingScreenState extends State<SitterSettingScreen> {
  UserProfile? currentUser;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('userId');

      if (userId == null) {
        Get.offAll(() => LoginScreen());
        throw Exception("User not logged in");
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/sitters/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            currentUser = UserProfile.fromJson(data);
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Error: $e";
        });
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
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
        // --- TOKEN CLEARING ---
        // If you rely on SharedPreferences mostly, use this:
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // Clears UserID, Token, etc.

        final storageService = Get.find<StorageService>();
        await storageService.deleteToken();

        // --- RESET GETX CONTROLLERS ---
        // These checks are safe (they won't crash if the controller isn't found)
        // Ensure you import these Controllers at the top if they are in different files.
        if (Get.isRegistered<HealthController>()) {
          Get.find<HealthController>().resetState();
        }
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().resetState();
        }
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().resetState();
        }

        // Clear all dependencies from memory
        Get.deleteAll(force: true);

        // Navigate to Login
        Get.offAll(() => LoginScreen()); 

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
    const Color brandColor = Color(0xFF2ECA6A);
    const Color scaffoldBg = Color(0xFFF3F4F6);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: brandColor)),
      );
    }

    if (errorMessage != null && currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchUserData,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: brandColor,
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) Get.to(() => const SitterDashboard());
          if (index == 2) Get.to(() => const SitterCalendar());
          if (index == 3) Get.to(() => const SitterInbox());
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Setting',
          ),
        ],
      ),

      // ✅ FIXED LAYOUT: Everything is inside SingleChildScrollView
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // --- 1. THE GREEN BACKGROUND (Scrolls with page) ---
            Container(
              height: 260, // Height of the green banner
              width: double.infinity,
              color: brandColor,
            ),

            // --- 2. THE CONTENT (Scrolls with page) ---
            Column(
              children: [
                // Header Title (Inside Column, so it scrolls)
                Padding(
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sitter Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Main Content (Card + Menus)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // --- FLOATING PROFILE CARD ---
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar & Info
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: brandColor.withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: const Color(0xFFE8F5E9),
                                    child: const Icon(
                                      Icons.person,
                                      color: brandColor,
                                      size: 35,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentUser!.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          "Verified Sitter",
                                          style: TextStyle(
                                            color: brandColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final result = await Get.to(
                                      () => EditProfilePage(user: currentUser!),
                                    );
                                    if (result != null) {
                                      setState(() {
                                        currentUser = result;
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Divider(height: 1),
                            ),
                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatColumn(
                                  icon: Icons.account_balance_wallet,
                                  value: "RM 120",
                                  label: "Wallet",
                                  color: Colors.green,
                                ),
                                _buildVerticalDivider(),
                                _buildStatColumn(
                                  icon: Icons.star_rounded,
                                  value: "4.9",
                                  label: "Rating",
                                  color: Colors.amber,
                                ),
                                _buildVerticalDivider(),
                                _buildStatColumn(
                                  icon: Icons.people_alt,
                                  value: "32",
                                  label: "Reviews",
                                  color: Colors.blueAccent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --- MENUS ---
                      _buildSectionHeader("Sitter Management"),
                      _buildMenuContainer([
                        _buildMenuItem(
                          icon: Icons.visibility_outlined,
                          iconColor: Colors.purple,
                          title: "Preview Profile",
                          subtitle: "See what owners see",
                          onTap: () {
                            Get.to(() => SitterPreviewPage(user: currentUser!));
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.bar_chart_outlined,
                          iconColor: Colors.blue,
                          title: "My Performance",
                          subtitle: "View booking history & stats",
                          onTap: () => Get.to(() => const SitterPerformancePage()),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.monetization_on_outlined,
                          iconColor: Colors.green,
                          title: "Earnings & Wallet",
                          subtitle: "View transaction history",
                          onTap: () {},
                        ),
                      ]),

                      const SizedBox(height: 25),

                      _buildSectionHeader("Account"),
                      _buildMenuContainer([
                        _buildMenuItem(
                          icon: Icons.swap_horiz,
                          iconColor: Colors.orange,
                          title: "Switch to Owner Mode",
                          subtitle: "Book sitters for your own pets",
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.notifications_none,
                          iconColor: Colors.teal,
                          title: "Notifications",
                          subtitle: "Manage alert preferences",
                          onTap: () {},
                        ),
                      ]),

                      const SizedBox(height: 25),

                      _buildSectionHeader("Support"),
                      _buildMenuContainer([
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          iconColor: Colors.indigo,
                          title: "Help & Support",
                          subtitle: "FAQ and Customer Service",
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          iconColor: Colors.grey,
                          title: "About Pawsure",
                          subtitle: "Version 1.0.0",
                          onTap: () {},
                        ),
                      ]),

                      const SizedBox(height: 30),

                      // --- LOGOUT BUTTON ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleLogout(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                          ),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            "Log Out",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS (Same as before) ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[100],
      indent: 60,
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey[200]);
  }
}
