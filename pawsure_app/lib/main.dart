import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/role_selection.dart';
import 'screens/community/community_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/home/home_screen.dart'; // Assuming a main screen for the first tab

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
    debugPrint('[DEBUG] PawsureApp: building MaterialApp');
    return MaterialApp(
      title: 'Pawsure - Pet Care Companion',
      theme: ThemeData(
        // Assuming ColorScheme seed color is corrected to a valid 8-digit hex
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1CCAE5)),
        useMaterial3: true,
      ),
      // App starts with the AuthWrapper to determine the initial route
      home: const _AuthWrapper(),
      routes: {
        // Auth Flow
        '/onboarding': (context) => const OnboardingScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),

        // Main App Flow
        '/dashboard': (context) => const MainNavigationShell(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- 1. AUTH WRAPPER: Determines Initial Route ---

class _AuthWrapper extends StatefulWidget {
  const _AuthWrapper();

  @override
  State<_AuthWrapper> createState() => __AuthWrapperState();
}

class __AuthWrapperState extends State<_AuthWrapper> {
  // ** DEVELOPMENT FLAG: SET TO TRUE TO SKIP AUTH FLOW **
  static const bool SHOULD_SKIP_AUTH = true;
  // ** ------------------------------------------- **

  Future<String> _getInitialRoute() async {
    // 1. DEVELOPMENT SKIP LOGIC
    if (SHOULD_SKIP_AUTH) {
      debugPrint('[DEBUG] Auth Skipped: Routing to /dashboard');
      return '/dashboard';
    }

    // 2. PRODUCTION LOGIC
    final prefs = await SharedPreferences.getInstance();
    final bool hasCompletedOnboarding =
        prefs.getBool('onboarding_completed') ?? false;

    // (In a real app: check for a stored auth token here)

    if (hasCompletedOnboarding) {
      // User has completed onboarding, proceed to the next step (e.g., login/role selection)
      return '/role-selection';
    } else {
      // First-time user, start onboarding
      return '/onboarding';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final initialRoute = snapshot.data!;

          // Use a simple switch to return the widget corresponding to the route path
          switch (initialRoute) {
            case '/dashboard':
              return const MainNavigationShell();
            case '/role-selection':
              return const RoleSelectionScreen();
            case '/onboarding':
            default:
              return const OnboardingScreen();
          }
        }

        // Show a loading screen while the initial route is being determined
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF1CCAE5)),
          ),
        );
      },
    );
  }
}

// --- 2. MAIN NAVIGATION SHELL: The App's Home Screen with Tabs ---

// This widget acts as the container for your main tabs (Community, Home, Settings, etc.)
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex =
      1; // Start on the Community tab (index 1) for immediate testing

  final List<Widget> _screens = [
    const HomeScreen(), // Index 0: Dashboard (Home)
    const CommunityScreen(), // Index 1: Community (The screen you're working on)
    const ProfileScreen(
      userName: 'Guest User',
      userRole: 'Pet Owner',
    ), // Index 2: Settings
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The currently selected screen is displayed here
      body: _screens[_currentIndex],

      // Bottom Navigation Bar for switching between tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary, // Green color
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
