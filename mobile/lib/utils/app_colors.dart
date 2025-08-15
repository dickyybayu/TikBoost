import 'package:flutter/material.dart';

/// App color palette - beige, soft peach, light gray, muted green
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Dark theme colors
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkCardBackground = Color(0xFF2C2C2E);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFF8E8E93);
  
  // Light theme colors
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightPrimaryText = Color(0xFF000000);
  static const Color lightSecondaryText = Color(0xFF6D6D70);
  
  // Brand colors (same for both themes)
  static const Color beige = Color(0xFFF5F1EB);
  static const Color softPeach = Color(0xFFFFD4C4);
  static const Color lightGray = Color(0xFFF2F2F7);
  static const Color mutedGreen = Color(0xFF8FBC8F);
  
  // System colors
  static const Color accent = Color(0xFFFF6B35);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color white = Color(0xFFFFFFFF);
  
  // Dynamic colors based on theme
  static Color background(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color cardBackground(bool isDark) => isDark ? darkCardBackground : lightCardBackground;
  static Color primaryText(bool isDark) => isDark ? darkPrimaryText : lightPrimaryText;
  static Color secondaryText(bool isDark) => isDark ? darkSecondaryText : lightSecondaryText;
  
  // Gradient colors
  static List<Color> get softGradient => [
    softPeach.withOpacity(0.3),
    mutedGreen.withOpacity(0.3),
  ];
  
  static List<Color> get greenPeachGradient => [
    mutedGreen.withOpacity(0.3),
    softPeach.withOpacity(0.3),
  ];
}
