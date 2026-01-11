import 'package:flutter/material.dart';
import 'package:pawsure_app/screens/community/community_screen.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_calendar.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_dashboard.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_inbox.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_setting_screen.dart';

class SitterMainNavigation extends StatefulWidget {
  // ✅ ADDED: Optional parameter to set initial screen
  final int initialIndex;

  const SitterMainNavigation({
    super.key,
    this.initialIndex = 4, // Default to Settings (index 4)
  });

  @override
  State<SitterMainNavigation> createState() => _SitterMainNavigationState();
}

class _SitterMainNavigationState extends State<SitterMainNavigation> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const SitterDashboard(),
    const CommunityScreen(),
    const SitterCalendar(),
    const SitterInbox(),
    const SitterSettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // ✅ ADDED: Initialize with the passed initialIndex
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF2ECA6A);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: brandColor,
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}
