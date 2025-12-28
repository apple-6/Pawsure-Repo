import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawsure_app/constants/api_config.dart';

import 'sitter_calendar.dart';
import 'sitter_inbox.dart';
import 'sitter_dashboard.dart';
import 'sitter_preview_page.dart';
import 'sitter_edit_profile.dart';
import '../../models/sitter_model.dart'; 

// --- PART 1: THE WIDGET  ---
class SitterSettingScreen extends StatefulWidget {
  const SitterSettingScreen({super.key});

  @override
  State<SitterSettingScreen> createState() => _SitterSettingScreenState();
}

// --- PART 2: THE STATE (All logic goes here!) ---
class _SitterSettingScreenState extends State<SitterSettingScreen> {
  
  // A. State Variables
  UserProfile? currentUser; // Make it nullable
  bool isLoading = true;    // Add loading state
  String? errorMessage;     // Add error state

  // B. Init State (Runs once when screen loads)
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // C. The Async Fetch Function
  Future<void> _fetchUserData() async {
  try {
    // A. Get access to storage
    final prefs = await SharedPreferences.getInstance();
    
    // B. Read the saved ID (Returns null if not found)
    final int? userId = prefs.getInt('userId');

    // C. Check if user is actually logged in
    if (userId == null) {
      // No ID found? They shouldn't be here. Send them to Login.
      Get.offAll(() => LoginScreen());
      throw Exception("User not logged in");
    }

    // D. Use the REAL ID in the URL
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/sitters/user/$userId'), // <--- Dynamic!
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token', // Optional if you made the route public, but recommended
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        currentUser = UserProfile.fromJson(data);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    setState(() {
      isLoading = false;
      errorMessage = "Error: $e";
    });
  }
}

  // D. The Build Method
  @override
  Widget build(BuildContext context) {
    // Define colors here
    const Color brandColor = Color(0xFF1CCA5B);
    const Color lightGreen = Color(0xFFEFFAF4);

    // 1. SHOW LOADING SPINNER
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: brandColor)),
      );
    }

    // 2. SHOW ERROR MESSAGE
    if (errorMessage != null && currentUser == null) {
      return Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: _fetchUserData, child: const Text("Retry"))
          ],
        )),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: brandColor,
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: 4, 
        onTap: (index) {
          if (index == 0) Get.to(() => const SitterDashboard());
          if (index == 2) Get.to(() => const SitterCalendar());
          if (index == 3) Get.to(() => const SitterInbox());
          // Index 4 is current page, do nothing
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Setting'),
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
                  border: Border.all(color: brandColor.withOpacity(0.3), width: 2),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: lightGreen,
                  child: const Icon(Icons.person_outline, size: 40, color: brandColor),
                ),
              ),
              const SizedBox(height: 12),

              // DYNAMIC NAME (Uses the variable from Part 2)
              Text(
                currentUser!.name, 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // Rating Row
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text("4.9", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(width: 4),
                  Text("(32 Reviews)", style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),

              // Verified Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: 16, color: brandColor),
                    SizedBox(width: 6),
                    Text("Verified Sitter", style: TextStyle(color: brandColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 2. ACTION BUTTONS ---

              // Edit Profile Button (This caused the errors before)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (currentUser == null) return;

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(user: currentUser!),
                      ),
                    );

                    // Update UI if data came back
                    if (result != null && result is UserProfile) {
                      setState(() {
                        currentUser = result;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text("Edit Profile", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 12),

              // Preview as Owner Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SitterPreviewPage()),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, color: Colors.black87, size: 20),
                  label: const Text("Preview as Owner", style: TextStyle(fontSize: 16, color: Colors.black87)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- 3. SITTER TOOLS LIST ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Sitter Tools",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
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
              _buildToolTile(
                icon: Icons.logout,
                title: "Log Out",
                brandColor: Colors.red,
                lightGreen: Colors.red.withOpacity(0.1),
                onTap: () {
                   // Your logout logic here
                   // Get.offAll(() => LoginScreen());
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget (Must be inside the State class or outside both classes)
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}