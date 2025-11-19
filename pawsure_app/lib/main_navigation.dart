import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/navigation_controller.dart'; // Import the new controller
import 'controllers/health_controller.dart'; // Import HealthController

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
    // 1. Get existing controllers registered in `InitialBindings`.
    // Use `Get.find` to avoid re-registering controllers every rebuild.
    final NavigationController nav = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : Get.put(NavigationController());

    // Initialize HealthController only if it wasn't registered by bindings.
    if (!Get.isRegistered<HealthController>()) {
      Get.put(HealthController());
    }

    // 2. Define your screens
    final screens = [
      const HomeScreen(),
      const HealthScreen(),
      const ActivityScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];

    // Pawsure Green
    const primaryColor = Color(0xFF22c55e);

    return Scaffold(
      // 3. Use Obx() to listen for changes in the page index
      body: Obx(() => screens[nav.currentIndex.value]),

      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: nav.currentIndex.value,
          onTap: nav.changePage, // Uses the controller's action
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
