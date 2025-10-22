import 'package:flutter/material.dart';
import 'main_navigation.dart';

void main() {
  runApp(const PawsureApp());
}

class PawsureApp extends StatelessWidget {
  const PawsureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawsure - Pet Care Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
