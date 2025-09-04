import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(false);
  static ThemeData get darkTheme => _buildTheme(true);

  static ThemeData _buildTheme(bool isDark) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primarySwatch: Colors.orange,
      scaffoldBackgroundColor: AppColors.background(isDark),
      fontFamily: GoogleFonts.poppins().fontFamily,
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background(isDark),
        elevation: 0,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.primaryText(isDark),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.primaryText(isDark)),
      ),
      
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          color: AppColors.primaryText(isDark),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: AppColors.primaryText(isDark),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.poppins(
          color: AppColors.primaryText(isDark),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.poppins(
          color: AppColors.primaryText(isDark),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.poppins(
          color: AppColors.primaryText(isDark),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.poppins(
          color: AppColors.primaryText(isDark),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: AppColors.primaryText(isDark),
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: AppColors.secondaryText(isDark),
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.poppins(
          color: AppColors.secondaryText(isDark),
          fontSize: 12,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.cardBackground(isDark),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground(isDark),
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.secondaryText(isDark),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
