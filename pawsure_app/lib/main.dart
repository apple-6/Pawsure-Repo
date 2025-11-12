import 'package:flutter/material.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/sitter/sitter_dashboard.dart';
import 'models/sitter.dart';

void main() {
  debugPrint('[DEBUG] PawsureApp: Starting main()');
  runApp(const PawsureApp());
}

class PawsureApp extends StatelessWidget {
  const PawsureApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '[DEBUG] PawsureApp: building MaterialApp with OnboardingScreen',
    );
    return MaterialApp(
      title: 'Pawsure - Pet Care Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // // Start with onboarding -> login/register flow
      // home: const OnboardingScreen(),
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/register': (context) => const RegisterScreen(),
      // },
      // Skip auth - launch directly to sitter dashboard for preview
      home: const SitterDashboardScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/sitter/dashboard') {
          return MaterialPageRoute(
            builder: (context) => const SitterDashboardScreen(),
            settings: settings,
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
