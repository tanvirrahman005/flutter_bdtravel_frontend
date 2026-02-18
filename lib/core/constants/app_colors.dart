import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5449E8);
  static const Color primaryLight = Color(0xFF9B95FF);
  
  // Accent Colors
  static const Color accent = Color(0xFFFF6584);
  static const Color accentLight = Color(0xFFFF8FA3);
  
  // Background Colors
  static const Color background = Color(0xFFF8F9FE);
  static const Color cardBackground = Colors.white;
  static const Color surface = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2E3A59);
  static const Color textSecondary = Color(0xFF8E92A3);
  static const Color textHint = Color(0xFFB8BBC4);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Divider
  static const Color divider = Color(0xFFE8EAEF);
}
