import 'package:flutter/material.dart';
import 'main_navigation.dart';
import 'package:get/get.dart';
import 'bindings/initial_bindings.dart';

void main() {
  // Required for accessing SharedPreferences before runApp
  WidgetsFlutterBinding.ensureInitialized();
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
      // - Revert to proper auth flow once login is implemented.
      // - Ensure `InitialBindings()` still registers AuthService and any needed controllers.
      // - Consider gating this behind a debug flag or compile-time environment variable.
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
