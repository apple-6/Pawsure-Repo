import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawsure_app/constants/api_config.dart';

// --- IMPORTS FOR NAVIGATION ---
import 'sitter_calendar.dart';
import 'sitter_inbox.dart';
import 'sitter_dashboard.dart';
import 'sitter_preview_page.dart';
import 'sitter_edit_profile.dart';
import '../../models/sitter_model.dart';
import 'package:pawsure_app/services/storage_service.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/controllers/home_controller.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';

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
        setState(() {
          currentUser = UserProfile.fromJson(data);
          isLoading = false;
        });
      } else {
        throw Exception(
          'Failed to load: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
    }
  }

  // --- 🆕 LOGOUT LOGIC ADDED HERE ---
  Future<void> _handleLogout(BuildContext context) async {
    // 1. Show confirmation dialog
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

    // 2. Perform Logout if confirmed
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
    const Color brandColor = Color(0xFF1CCA5B);
    const Color lightGreen = Color(0xFFEFFAF4);

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
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: brandColor,
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) Get.to(() => const SitterDashboard());
          if (index == 1) ; // Discover screen not implemented yet
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // --- 1. PROFILE HEADER ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: brandColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: lightGreen,
                  child: const Icon(
                    Icons.person_outline,
                    size: 40,
                    color: brandColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                currentUser!.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text(
                    "4.9",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 4),
                  Text("(32 Reviews)", style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: brandColor,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Verified Sitter",
                      style: TextStyle(
                        color: brandColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 2. ACTION BUTTONS ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (currentUser == null) return;
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(user: currentUser!),
                      ),
                    );
                    if (result != null && result is UserProfile) {
                      setState(() {
                        currentUser = result;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (currentUser == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SitterPreviewPage(user: currentUser!),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.visibility_outlined,
                    color: Colors.black87,
                    size: 20,
                  ),
                  label: const Text(
                    "Preview as Owner",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. SITTER TOOLS LIST ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Sitter Tools",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildToolTile(
                icon: Icons.account_balance_wallet_outlined,
                title: "Wallet & Earnings",
                brandColor: brandColor,
                lightGreen: lightGreen,
                onTap: () {},
              ),
              _buildToolTile(
                icon: Icons.bar_chart_outlined,
                title: "My Performance",
                brandColor: brandColor,
                lightGreen: lightGreen,
                onTap: () {},
              ),
              _buildToolTile(
                icon: Icons.swap_horiz,
                title: "Switch to Owner Mode",
                brandColor: brandColor,
                lightGreen: lightGreen,
                onTap: () {},
              ),

              // --- 🆕 LOGOUT TILE CONNECTED ---
              _buildToolTile(
                icon: Icons.logout,
                title: "Log Out",
                brandColor: Colors.red,
                lightGreen: Colors.red.withOpacity(0.1),
                onTap: () => _handleLogout(context), // ✅ Calling the function
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolTile({
    required IconData icon,
    required String title,
    required Color brandColor,
    required Color lightGreen,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: lightGreen,
          radius: 20,
          child: Icon(icon, color: brandColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
