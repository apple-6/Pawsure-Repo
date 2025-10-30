import 'package:flutter/material.dart';
import 'main_navigation.dart';

void main() {
  runApp(const PawsureApp());
}

class PawsureApp extends StatelessWidget {
  const PawsureApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF22c55e),
        primary: Color(0xFF22c55e),
        surface: Color(0xFFF8F9FA), // <<< Use surface here (was background)
      ),
      scaffoldBackgroundColor: Color(0xFFF8F9FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      useMaterial3: true,
    );
    return MaterialApp(
      title: 'Pawsure - Pet Care Companion',
      theme: theme,
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
