//pawsure_app\lib\main_navigation.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/health_controller.dart';
import 'controllers/pet_controller.dart'; // 🆕 Import PetController
import 'controllers/profile_controller.dart';

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
    // Get controllers
    final NavigationController nav = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : Get.put(NavigationController());

    // Ensure HealthController exists
    if (!Get.isRegistered<HealthController>()) {
      Get.put(HealthController());
    }

    // ✅ FIX: Reset to home tab and refresh data on create
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nav.changePage(0); // Reset to Home tab

      // 🔧 FIXED: Refresh PetController (which updates both Home and Health)
      if (Get.isRegistered<PetController>()) {
        Get.find<PetController>().loadPets();
      }

      // Refresh profile
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().loadProfile();
      }
    });

    // Define your screens
    final screens = [
      const HomeScreen(),
      const HealthScreen(),
      const ActivityScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];

    const primaryColor = Color(0xFF22c55e);

    return Scaffold(
      body: Obx(() => screens[nav.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: nav.currentIndex.value,
          onTap: nav.changePage,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Health',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Community',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
