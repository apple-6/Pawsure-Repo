import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/screens/auth/login_screen.dart';
import 'package:pawsure_app/screens/community/community_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawsure_app/main_navigation.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/controllers/sitter_controller.dart';
import 'package:pawsure_app/screens/profile/help_support_screen.dart';

// Navigation Imports
import 'sitter_calendar.dart';
import 'sitter_inbox.dart';
import 'sitter_dashboard.dart';
import 'sitter_preview_page.dart';
import 'sitter_edit_profile.dart';
import 'sitter_performance_page.dart';
import '../../models/sitter_model.dart';
import 'sitter_registration_screen.dart';



class SitterSettingScreen extends StatefulWidget {
  const SitterSettingScreen({super.key});

  @override
  State<SitterSettingScreen> createState() => _SitterSettingScreenState();
}

class _SitterSettingScreenState extends State<SitterSettingScreen> {
  UserProfile? currentUser;
  bool isLoading = true;
  String? errorMessage;

  double rating = 0.0;
  int reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

 Future<void> _fetchUserData() async {
    try {
      final apiService = Get.find<ApiService>();
      
      // 1. Get the profile (Now includes rating/reviews inside the object)
      final profile = await apiService.getMySitterProfile();

      if (profile != null) {
        if (mounted) {
          setState(() {
            currentUser = profile;
            isLoading = false;

            // ✅ FIXED: No more 'toJson' error. Just use the fields directly.
            rating = profile.rating;
            reviewCount = profile.reviewCount;
          });
        }
      } else {
        // User not found (404)
        if (mounted) {
           Get.off(() => const SitterRegistrationScreen());
        }
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

 // ✅ New Helper to fetch stats specifically
  Future<void> _fetchSitterStats(ApiService apiService, int sitterId) async {
    try {
      // Calls the new API method we added in Step 2
      final data = await apiService.getSitterDetails(sitterId);

      if (data != null && mounted) {
        setState(() {
          // Parse data safely
          rating = (data['rating'] ?? data['avgRating'] ?? 0).toDouble();
          
          reviewCount = data['reviewCount'] ?? 
                        data['reviews_count'] ?? 
                        data['review_count'] ?? 
                        0;
        });
      }
    } catch (e) {
      print("Error loading stats: $e");
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
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Clear SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Clear user data state
        if (mounted) {
          setState(() {
            currentUser = null;
          });
        }

        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // Navigate to login and remove all previous routes
        // Use Navigator instead of Get to avoid controller issues
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        // Close loading dialog if it's showing
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to logout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _checkAndSwitchToOwner() async {
    try {
      // 1. Show loading indicator briefly (optional, for UX)
      setState(() => isLoading = true);

      // 2. Update Local Storage
      // This tells the app: "Next time I open, show me the Owner Dashboard"
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'owner');

      // 3. Navigate directly to Owner Dashboard
      // Make sure to import your OwnerDashboard file at the top!
      Get.offAll(() => const MainNavigation());
      
      Get.snackbar(
        "Switched to Owner Mode",
        "You can now book other sitters!",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to switch mode: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
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

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display specific error if available, or generic message
              Text(
                errorMessage ?? "Failed to load profile data.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  foregroundColor: Colors.white,
                ),
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
          if (index == 1) Get.to(() => const CommunityScreen());
          if (index == 2) Get.to(() => const SitterCalendar());
          if (index == 3) Get.to(() => const SitterInbox());
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
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
                                        currentUser?.name ?? "Sitter",
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
                            GetBuilder<SitterController>(
                              init: Get.isRegistered<SitterController>() ? Get.find<SitterController>() : SitterController(),
                              builder: (controller) {
                                return Obx(() => Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatColumn(
                                      icon: Icons.account_balance_wallet,
                                      value: "RM ${controller.earnings.value.toStringAsFixed(0)}",
                                      label: "Wallet",
                                      color: Colors.green,
                                    ),
                                    _buildVerticalDivider(),
                                    _buildStatColumn(
                                      icon: Icons.star_rounded,
                                      value: controller.avgRating.value.toStringAsFixed(1),
                                      label: "Rating",
                                      color: Colors.amber,
                                    ),
                                    _buildVerticalDivider(),
                                    _buildStatColumn(
                                      icon: Icons.people_alt,
                                      value: "${controller.sitterProfile['reviewCount'] ?? 0}",
                                      label: "Reviews",
                                      color: Colors.blueAccent,
                                    ),
                                  ],
                                ));
                              },
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
                          onTap: () =>
                              Get.to(() => const SitterPerformancePage()),
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
                          onTap: _checkAndSwitchToOwner,
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
                          onTap: () {Get.to(() => HelpSupportScreen());},
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
