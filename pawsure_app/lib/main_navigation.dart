import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/navigation_controller.dart'; // Import the new controller

// Import your screens
import 'screens/home/home_screen.dart';
import 'screens/health/health_screen.dart';
import 'screens/activity/activity_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/profile/profile_screen.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize the GetX Controller
    final NavigationController nav = Get.put(NavigationController());

    // 2. Define your screens
    final screens = [
      const HomeScreen(),
      const HealthScreen(),
      const ActivityScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // 3. Use Obx() to listen for changes in the page index
      body: Obx(() => screens[nav.currentIndex.value]),

      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: nav.currentIndex.value,
            onTap: nav.changePage, // Uses the controller's action
            type: BottomNavigationBarType.fixed,
            selectedItemColor:
                const Color(0xFF16A34A), // Matches the 'Pawsure Green'
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'Health'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart), label: 'Activity'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.people), label: 'Community'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: 'Settings'),
            ],
          )),
    );
  }
}
