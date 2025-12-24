// lib/constants/api_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart'; // Needed for kIsWeb

class ApiConfig {
  // 1. The "Secret Tunnel" for Android Emulator
  static const String _emulatorUrl = 'http://10.0.2.2:3000';

  // 2. The standard address for Web & iOS
  static const String _localhostUrl = 'http://localhost:3000';

  static const String supabaseUrl = 'https://wgdhczauhclzdxyfhhru.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndnZGhjemF1aGNsemR4eWZoaHJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwNDM2NjcsImV4cCI6MjA3NjYxOTY2N30.6WBWKdgPPI6nY9yeTcZqEFKo7fHq3piRdkfpLOeP2Ss';
  // The Magic Logic
  static String get baseUrl {
    // If running on Web, use localhost
    if (kIsWeb) {
      return _localhostUrl;
    }

    // If running on Android (Emulator), use the tunnel
    // (This works for 99% of emulator cases)
    if (Platform.isAndroid) {
      return _emulatorUrl;
    }

    // Fallback for iOS simulator
    return _localhostUrl;
  }
}
