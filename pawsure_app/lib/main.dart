import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/initial_bindings.dart';

// Screens
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/role_selection.dart';
import 'main_navigation.dart'; // Keep this for routing later

void main() {
  // 1. Keep this from your branch (Required for StorageService)
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
      // 2. Keep GetMaterialApp from your branch
      title: 'Pawsure - Pet Care Companion',

      // 3. Use the branding color from Main (Fixed typo: added 'B' to make it valid 6-digit hex)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1CCA5B)),
        useMaterial3: true,
      ),

      // 4. Keep your bindings so Controllers/Services are created
      initialBinding: InitialBindings(),

      // 5. RESTORE AUTH FLOW: Change home back to OnboardingScreen
      home: const OnboardingScreen(),

      // 6. Define routes so you can navigate easily from Login -> MainNavigation
      routes: {
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/home': (context) => const MainNavigation(), // Add this route
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
