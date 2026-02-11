import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color scaffoldBackgroundColor = Color(0xFF0F0F0F); // Deep Black
  static const Color primaryColor = Color(0xFF6C63FF); // Modern Violet/Blue
  static const Color accentColor = Color(0xFF00E5FF); // Neon Cyan
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color successColor = Color(0xFF00E676);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        background: scaffoldBackgroundColor,
        error: errorColor,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: GoogleFonts.outfit(
            fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
        displaySmall: GoogleFonts.outfit(
            fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        headlineMedium: GoogleFonts.outfit(
            fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white70),
        bodyLarge: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
        bodyMedium: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white70),
        labelLarge: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.outfit(color: Colors.white38),
      ),
    );
  }
}
