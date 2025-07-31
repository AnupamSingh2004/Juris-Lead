import 'package:flutter/material.dart';

class AppTheme {
  // Color Constants
  static const Color jurisLeadBlue = Color(0xFF3498DB);
  static const Color electricBlue = Color(0xFF33A1FF);
  static const Color charcoal = Color(0xFF2C3E50);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color softOffWhite = Color(0xFFE0E6F1);
  static const Color midnightBlue = Color(0xFF0D1B2A);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: jurisLeadBlue,
        onPrimary: Colors.white,
        secondary: jurisLeadBlue,
        onSecondary: Colors.white,
        surface: offWhite,
        onSurface: charcoal,
        background: offWhite,
        onBackground: charcoal,
        error: Color(0xFFE74C3C),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: offWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: offWhite,
        foregroundColor: charcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: charcoal,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: jurisLeadBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: jurisLeadBlue,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: jurisLeadBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: jurisLeadBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: charcoal,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: charcoal,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: charcoal,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: charcoal,
          fontSize: 14,
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: electricBlue,
        onPrimary: midnightBlue,
        secondary: electricBlue,
        onSecondary: midnightBlue,
        surface: Color(0xFF1A2332),
        onSurface: softOffWhite,
        background: midnightBlue,
        onBackground: softOffWhite,
        error: Color(0xFFFF6B6B),
        onError: midnightBlue,
      ),
      scaffoldBackgroundColor: midnightBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: midnightBlue,
        foregroundColor: softOffWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: softOffWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1A2332),
        selectedItemColor: electricBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
          color: const Color(0xFF1A2332),
          shadowColor: Colors.black.withValues(alpha: 0.3),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: electricBlue,
        foregroundColor: midnightBlue,
        elevation: 6,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: electricBlue,
          foregroundColor: midnightBlue,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2332),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: electricBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: softOffWhite,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: softOffWhite,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: softOffWhite,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: softOffWhite,
          fontSize: 14,
        ),
      ),
    );
  }
}
