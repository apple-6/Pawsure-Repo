import 'package:flutter/material.dart';
// import 'screens/auth/onboarding_screen.dart'; // DEV: Disabled to skip auth
import 'screens/auth/role_selection.dart';
import 'main_navigation.dart';
import 'package:get/get.dart';
import 'bindings/initial_bindings.dart';

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
      initialBinding: InitialBindings(),
      // DEV: Temporarily skip to MainNavigation to bypass login
      // TODO: REMOVE BEFORE PRODUCTION - This bypasses the auth/onboarding flow.
      // - Revert to `OnboardingScreen()` or your auth flow once login is implemented.
      // - Ensure `InitialBindings()` still registers AuthService and any needed controllers.
      // - Consider gating this behind a debug flag or compile-time environment variable.
      // Example: use `const bool skipAuth = bool.fromEnvironment('SKIP_AUTH', defaultValue: true);`
      // Then: `home: skipAuth ? const MainNavigation() : const OnboardingScreen(),`
      // See route '/role-selection' for role selection flow.
      home: const MainNavigation(),
      // PROD: Uncomment below to use normal auth flow
      // home: const OnboardingScreen(),
      routes: {'/role-selection': (context) => RoleSelectionScreen()},
      debugShowCheckedModeBanner: false,
    );
  }
}
