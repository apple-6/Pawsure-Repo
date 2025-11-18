import 'package:flutter/material.dart';
// import 'screens/auth/onboarding_screen.dart'; // DEV: Disabled to skip auth
import 'screens/auth/role_selection.dart';
import 'main_navigation.dart';
import 'package:get/get.dart';

void main() {
  debugPrint('[DEBUG] PawsureApp: Starting main()');
  runApp(const PawsureApp());
}

class PawsureApp extends StatelessWidget {
  const PawsureApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[DEBUG] PawsureApp: building MaterialApp (main UI)');
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    );

    return GetMaterialApp(
      title: 'Pawsure - Pet Care Companion',
      theme: theme,
      // DEV: Temporarily skip to MainNavigation to bypass login
      home: const MainNavigation(),
      // PROD: Uncomment below to use normal auth flow
      // home: const OnboardingScreen(),
      routes: {'/role-selection': (context) => RoleSelectionScreen()},
      debugShowCheckedModeBanner: false,
    );
  }
}
