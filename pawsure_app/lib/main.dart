//pawsure_app\lib\main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/initial_bindings.dart';
import 'controllers/navigation_controller.dart';

// Screens
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/role_selection.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/health/add_health_record_screen.dart';
import 'main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[DEBUG] PawsureApp: Starting main()');

  // ✅ Register NavigationController FIRST (before InitialBindings)
  Get.put(NavigationController(), permanent: true);
  debugPrint('✅ NavigationController registered globally');

  runApp(const PawsureApp());
}

class PawsureApp extends StatelessWidget {
  const PawsureApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[DEBUG] PawsureApp: building GetMaterialApp');

    return GetMaterialApp(
      title: 'Pawsure - Pet Care Companion',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1CCA5B)),
        useMaterial3: true,
      ),

      // ✅ InitialBindings loads all services and controllers in correct order
      initialBinding: InitialBindings(),

      // Initial screen
      home: const OnboardingScreen(),

      getPages: [
        GetPage(name: '/', page: () => const OnboardingScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(
          name: '/role-selection',
          page: () => const RoleSelectionScreen(),
        ),
        GetPage(name: '/home', page: () => const MainNavigation()),
        GetPage(name: '/calendar', page: () => const CalendarScreen()),
        GetPage(
          name: '/health/add-record',
          page: () => const AddHealthRecordScreen(),
        ),
      ],

      debugShowCheckedModeBanner: false,
    );
  }
}
