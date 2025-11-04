import 'dart:async';

/// Minimal placeholder AuthService used by the app UI while the real
/// authentication backend/integration is wired up.
///
/// This file prevents build errors when other screens import
/// `services/auth_service.dart`. It provides simple async stubs which can
/// be replaced later with real network/auth logic.
class AuthService {
  /// Simulate a login call. Returns true for any non-empty credentials.
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return email.isNotEmpty && password.isNotEmpty;
  }

  /// Simulate a register call. Returns true for any non-empty data.
  Future<bool> register(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return data.isNotEmpty;
  }

  /// Optional: sign out stub.
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return;
  }
}
