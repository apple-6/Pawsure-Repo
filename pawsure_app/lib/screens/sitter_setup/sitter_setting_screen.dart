import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/screens/auth/login_screen.dart';
import 'sitter_calendar.dart';
import 'sitter_inbox.dart';
import 'sitter_dashboard.dart';
import 'sitter_preview_page.dart';
import 'sitter_edit_profile.dart';
import '../../models/sitter_model.dart';

class SitterSettingScreen extends StatefulWidget {
  const SitterSettingScreen({super.key});

  @override
  State<SitterSettingScreen> createState() => _SitterSettingScreenState();
}

class _SitterSettingScreenState extends State<SitterSettingScreen> {
  
  // --- STATE VARIABLES ---
  // This holds the data displayed on the screen.
  late UserProfile currentUser;

  @override
  void initState() {
    super.initState();
    // Initialize with default data (Mock Data)
    // In a real app, you might fetch this from an API here.
    currentUser = UserProfile(
      name: "Aisha B.",
      location: "Petaling Jaya, Selangor",
      bio: "Hi! I'm Aisha, an experienced pet sitter...",
      experienceYears: 3,
      staysCompleted: 32,
      services: [
        ServiceModel(name: "Dog Boarding", isActive: true, price: "80", unit: "/night"),
        ServiceModel(name: "Dog Walking", isActive: true, price: "25", unit: "/hour"),
        ServiceModel(name: "Pet Sitting", isActive: true, price: "60", unit: "/visit"),
        ServiceModel(name: "Overnight Care", isActive: true, price: "100", unit: "/night"),
      ],
    );
  }

  // --- NAVIGATION LOGIC ---
  void _navigateToEditProfile() async {
    // Navigator.push returns a Future that resolves when the page is popped.
    // The 'result' will be the updated UserProfile object we sent back from EditProfilePage.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: currentUser),
      ),
    );

    // If 'result' is not null, it means the user clicked SAVE
    if (result != null && result is UserProfile) {
      setState(() {
        currentUser = result; // Update the state with new data
      });
      
      // Optional: Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Color(0xFF1CCA5B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF1CCA5B);
    const Color lightGreen = Color(0xFFEFFAF4);

    return Scaffold(
      backgroundColor: Colors.white,
      
      // --- BOTTOM NAVIGATION ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: brandColor,
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: 4, // Index 4 is 'Setting'
        onTap: (index) {
          if (index == 0) Get.to(() => const SitterDashboard());
          if (index == 1) { /* Navigate to Discover */ }
          if (index == 2) Get.to(() => const SitterCalendar());
          if (index == 3) Get.to(() => const SitterInbox());
          if (index == 4) { /* Already on Settings */ }
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
              const SizedBox(height: 60), // Add top padding for status bar

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

              // DYNAMIC NAME (Uses state variable)
              Text(
                currentUser.name, 
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

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _navigateToEditProfile, // <--- Call our new function
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

              // Tool Items
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
                  Get.offAll(() => const LoginScreen());
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget
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
