//pawsure_app\lib\main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added for Supabase
import 'constants/api_config.dart'; // Added to access your URL/Key
import 'bindings/initial_bindings.dart';
import 'controllers/navigation_controller.dart';

// Screens
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/role_selection.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/health/add_health_record_screen.dart'; // 👈 ADD THIS IMPORT
import 'main_navigation.dart';

// Changed to Future<void> and added async to allow Supabase to initialize
Future<void> main() async {
  // 1. Ensure Flutter bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[DEBUG] PawsureApp: Initializing Supabase');

  // 2. Initialize Supabase using the constants from your ApiConfig
  // This prevents the "Supabase not initialized" error in your modal
  await Supabase.initialize(
    url: ApiConfig.supabaseUrl,
    anonKey: ApiConfig.supabaseAnonKey,
  );

  debugPrint('[DEBUG] PawsureApp: Starting main()');

  // ✅ Register NavigationController FIRST (before InitialBindings)
  // Retained from HEAD to ensure navigation logic works
  Get.put(NavigationController(), permanent: true);
  debugPrint('✅ NavigationController registered globally');

  // 3. Start the application
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

      home: const OnboardingScreen(),

      // ✅ FIXED: Added all necessary routes including /health/add-record
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
          name:
              '/health/add-record', // 👈 CRITICAL: Retained your specific route
          page: () => const AddHealthRecordScreen(),
        ),
      ],

      debugShowCheckedModeBanner: false,
    );
  }
}
