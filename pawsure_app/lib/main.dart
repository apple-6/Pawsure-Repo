import 'package:flutter/material.dart';
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
    debugPrint('[DEBUG] PawsureApp: building MaterialApp (main UI)');
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Pawsure - Pet Care Companion',
      theme: theme,
      // Start the app on the Onboarding screen so auth/onboarding appears first.
      home: const OnboardingScreen(),
      routes: {'/role-selection': (context) => RoleSelectionScreen()},
      debugShowCheckedModeBanner: false,
    );
  }
}
