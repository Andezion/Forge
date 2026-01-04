import 'package:flutter/material.dart';

class AppColors {
  static Color primary = const Color(0xFF6750A4);
  static Color primaryDark = const Color(0xFF4A3780);
  static Color primaryLight = const Color(0xFF9380C7);

  static const Color accent = Color(0xFF03DAC6);
  static const Color accentDark = Color(0xFF00A896);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color cardShadow = Color(0x1A000000);

  static const Color streetlifting = Color(0xFFFF6B35);
  static const Color armwrestling = Color(0xFF004E89);
  static const Color powerlifting = Color(0xFF8B0000);

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF5F6368);
  }

  static Color getTextHint(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF757575)
        : const Color(0xFF9E9E9E);
  }

  static Color getBackground(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getSurface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getDivider(BuildContext context) {
    return Theme.of(context).dividerColor;
  }

  static Color getTextOnPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  static Color background = const Color(0xFFF5F5F5);
  static Color surface = const Color(0xFFFFFFFF);
  static Color surfaceDark = const Color(0xFF1E1E1E);
  static Color textPrimary = const Color(0xFF000000);
  static Color textSecondary = const Color(0xFF5F6368);
  static Color textHint = const Color(0xFF9E9E9E);
  static Color textOnPrimary = const Color(0xFFFFFFFF);
  static Color divider = const Color(0xFFE0E0E0);
  static void setDarkMode(bool isDark) {
    if (isDark) {
      background = const Color(0xFF121212);
      surface = const Color(0xFF1E1E1E);
      textPrimary = const Color(0xFFFFFFFF);
      textSecondary = const Color(0xFFB0B0B0);
      textHint = const Color(0xFF757575);
      divider = const Color(0xFF303030);
    } else {
      background = const Color(0xFFF5F5F5);
      surface = const Color(0xFFFFFFFF);
      textPrimary = const Color(0xFF000000);
      textSecondary = const Color(0xFF5F6368);
      textHint = const Color(0xFF9E9E9E);
      divider = const Color(0xFFE0E0E0);
    }
  }
}
