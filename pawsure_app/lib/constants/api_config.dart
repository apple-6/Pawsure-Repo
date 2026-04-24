// lib/constants/api_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // 1. Capture environment variables passed via --dart-define
  static const String _envApiUrl = String.fromEnvironment('API_BASE_URL');
  static const String _envSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _envSupabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // 2. Local Fallbacks
  static const String _emulatorUrl = 'http://10.0.2.2:3000';
  static const String _localhostUrl = 'http://localhost:3000';

  // 3. Supabase Credentials (using environment variables with hardcoded fallbacks for convenience)
  static String get supabaseUrl => _envSupabaseUrl.isNotEmpty 
      ? _envSupabaseUrl 
      : 'https://wgdhczauhclzdxyfhhru.supabase.co';

  static String get supabaseAnonKey => _envSupabaseKey.isNotEmpty 
      ? _envSupabaseKey 
      : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndnZGhjemF1aGNsemR4eWZoaHJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwNDM2NjcsImV4cCI6MjA3NjYxOTY2N30.6WBWKdgPPI6nY9yeTcZqEFKo7fHq3piRdkfpLOeP2Ss';

  // 4. API Base URL Logic
  static String get baseUrl {
    if (_envApiUrl.isNotEmpty) return _envApiUrl;
    if (kIsWeb) return _localhostUrl;
    if (Platform.isAndroid) return _emulatorUrl;
    return _localhostUrl;
  }
}
