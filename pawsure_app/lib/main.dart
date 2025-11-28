import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/initial_bindings.dart';

// Screens
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/role_selection.dart';
import 'main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[DEBUG] PawsureApp: Starting main()');
  runApp(const PawsureApp());
}

class PawsureApp extends StatelessWidget {
  const PawsureApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[DEBUG] PawsureApp: building GetMaterialApp with Onboarding');

    return GetMaterialApp(
      title: 'Pawsure - Pet Care Companion',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1CCA5B)),
        useMaterial3: true,
      ),

      initialBinding: InitialBindings(),

      // Initial screen
      home: const OnboardingScreen(),

      // ✅ UPDATED: Use getPages instead of routes for GetX navigation
      getPages: [
        GetPage(name: '/', page: () => const OnboardingScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(
          name: '/role-selection',
          page: () => const RoleSelectionScreen(),
        ),
        GetPage(name: '/home', page: () => const MainNavigation()),
      ],

      debugShowCheckedModeBanner: false,
    );
  }
}
