import 'package:flutter/material.dart';
import 'main_navigation.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/role_selection.dart';

void main() {
  debugPrint('[DEBUG] PawsureApp: Starting main()');
  runApp(const PawsureApp());
}

class PawsureApp extends StatelessWidget {
  const PawsureApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[DEBUG] PawsureApp: building MaterialApp with MainNavigation (main UI)');
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Pawsure - Pet Care Companion',
      theme: theme,
      // Keep main's UI: start at MainNavigation
      home: const MainNavigation(),
      // Add routes from your changes so onboarding and role-selection remain available
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/role-selection': (context) => RoleSelectionScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
