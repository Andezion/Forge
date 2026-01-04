import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(Color primaryColor) {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: Brightness.light,
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF000000),
        surfaceContainerHighest: const Color(0xFFF5F5F5),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor:
            primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFFFFFFFF),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF000000),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF000000)),
        bodyMedium: TextStyle(color: Color(0xFF000000)),
        bodySmall: TextStyle(color: Color(0xFF5F6368)),
        titleLarge: TextStyle(color: Color(0xFF000000)),
        titleMedium: TextStyle(color: Color(0xFF000000)),
        titleSmall: TextStyle(color: Color(0xFF5F6368)),
        headlineLarge: TextStyle(color: Color(0xFF000000)),
        headlineMedium: TextStyle(color: Color(0xFF000000)),
        headlineSmall: TextStyle(color: Color(0xFF000000)),
        labelLarge: TextStyle(color: Color(0xFF000000)),
        labelMedium: TextStyle(color: Color(0xFF5F6368)),
        labelSmall: TextStyle(color: Color(0xFF9E9E9E)),
      ),
      dividerColor: const Color(0xFFE0E0E0),
    );
  }

  static ThemeData darkTheme(Color primaryColor) {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E1E),
        onSurface: const Color(0xFFFFFFFF),
        surfaceContainerHighest: const Color(0xFF2C2C2C),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor:
            primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF1E1E1E),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFFFFFFF),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
        bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
        bodySmall: TextStyle(color: Color(0xFFB0B0B0)),
        titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
        titleMedium: TextStyle(color: Color(0xFFFFFFFF)),
        titleSmall: TextStyle(color: Color(0xFFB0B0B0)),
        headlineLarge: TextStyle(color: Color(0xFFFFFFFF)),
        headlineMedium: TextStyle(color: Color(0xFFFFFFFF)),
        headlineSmall: TextStyle(color: Color(0xFFFFFFFF)),
        labelLarge: TextStyle(color: Color(0xFFFFFFFF)),
        labelMedium: TextStyle(color: Color(0xFFB0B0B0)),
        labelSmall: TextStyle(color: Color(0xFF757575)),
      ),
      dividerColor: const Color(0xFF303030),
    );
  }
}
