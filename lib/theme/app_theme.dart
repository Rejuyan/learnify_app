import 'package:flutter/material.dart';

class AppTheme {
  // ─── Brand Colors (from reference) ──────────────────────────────
  static const Color primaryPurple = Color(0xFF7B6FDE);
  static const Color primaryPurpleLight = Color(0xFF9D8FEF);
  static const Color primaryPurpleDark = Color(0xFF6255C5);

  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color accentOrangeLight = Color(0xFFFFAB6B);
  static const Color accentYellow = Color(0xFFFFD93D);
  static const Color accentCoral = Color(0xFFFF6B6B);

  static const Color backgroundLight = Color(0xFFF5F3FC);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6E6E82);
  static const Color textMuted = Color(0xFFAAAAAF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color chipBg = Color(0xFFF0EDFF);
  static const Color chipText = Color(0xFF7B6FDE);

  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFEF5350);
  static const Color warningYellow = Color(0xFFFFB74D);

  static const Color divider = Color(0xFFEEEDF5);
  static const Color shadowColor = Color(0x14000000);

  // ─── Course Accent Colors ───────────────────────────────────────
  static const Color courseBlue = Color(0xFF5B8DEF);
  static const Color coursePink = Color(0xFFFF6B9D);
  static const Color courseTeal = Color(0xFF26C6B0);
  static const Color courseAmber = Color(0xFFFFB347);
  static const Color courseIndigo = Color(0xFF7C6FDE);

  // ─── Dark Mode Colors ───────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1C1C2E);
  static const Color darkCard = Color(0xFF252538);
  static const Color darkDivider = Color(0xFF2E2E45);
  static const Color darkTextPrimary = Color(0xFFF0F0FF);
  static const Color darkTextSecondary = Color(0xFFAAAAAF);

  // ─── Theme Data ─────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primaryPurple,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        secondary: accentOrange,
        surface: backgroundWhite,
        error: errorRed,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: textPrimary,
        onError: textOnPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textOnPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textOnPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundWhite,
        selectedItemColor: primaryPurple,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ─── Dark Theme Data ────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryPurple,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: accentOrange,
        surface: darkCard,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryPurpleLight,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkDivider),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
        hintStyle: const TextStyle(color: darkTextSecondary),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkTextPrimary, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkTextPrimary, letterSpacing: -0.3),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkTextPrimary),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkTextPrimary),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkTextSecondary),
        bodyLarge: TextStyle(fontSize: 16, color: darkTextPrimary, height: 1.6),
        bodyMedium: TextStyle(fontSize: 14, color: darkTextSecondary, height: 1.5),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkTextPrimary),
      ),
    );
  }

  // ─── Header Gradient ─────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B7FE8),
      Color(0xFF7B6FDE),
      Color(0xFF6A5FD0),
    ],
  );

  // ─── Card Shadow ─────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadowLight => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  // ─── Glassmorphism / Soft Card Decoration ────────────────────────
  static BoxDecoration softCard({double borderRadius = 20}) {
    return BoxDecoration(
      color: surfaceCard,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: cardShadow,
    );
  }

  static BoxDecoration trendingCard() {
    return BoxDecoration(
      color: const Color(0xFFFFF8F0),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: accentOrange.withValues(alpha: 0.15),
        width: 1,
      ),
      boxShadow: cardShadowLight,
    );
  }
}
