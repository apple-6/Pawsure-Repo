import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF22c55e);
  static const Color primaryDark = Color(0xFF16a34a);
  static const Color primaryLight = Color(0xFFdcfce7);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFB923C);
  static const Color info = Color(0xFF3B82F6);

  // Navigation Colors
  static const Color navBackground = Color(0xFF22c55e);
  static const Color navSelected = Color(0xFFFFFFFF);
  static const Color navUnselected = Color(0xFFB2DFDB);

  // Border & Divider
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFF3F4F6);

  // Opacity Variants
  static Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);

  static Color textSecondaryWithOpacity(double opacity) =>
      textSecondary.withValues(alpha: opacity);
}
