import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

class AppColor extends ChangeNotifier {
  static const _prefsKey = 'app_primary_color';
  static const _darkModeKey = 'app_dark_mode';

  Color _color = AppColors.primary;
  bool _isDarkMode = false;

  Color get color => _color;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  AppColor();

  ThemeData get lightTheme => AppTheme.lightTheme(_color);
  ThemeData get darkTheme => AppTheme.darkTheme(_color);

  ThemeData getTheme() => _isDarkMode ? darkTheme : lightTheme;

  bool isCurrentColor(Color other) => _color.toARGB32() == other.toARGB32();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    AppColors.setDarkMode(_isDarkMode);

    final value = prefs.getInt(_prefsKey);
    if (value != null) {
      final alpha = (value >> 24) & 0xFF;
      final rgb = value & 0xFFFFFF;
      if (alpha > 100 && rgb != 0) {
        _color = Color(value);
      } else {
        await prefs.remove(_prefsKey);
      }
    }
    AppColors.setPrimary(_color);
    notifyListeners();
  }

  Future<void> setColor(Color newColor) async {
    final normalized = Color(newColor.toARGB32());
    if (isCurrentColor(normalized)) return;
    _color = normalized;
    AppColors.setPrimary(normalized);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, normalized.toARGB32());
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) return;
    _isDarkMode = isDark;
    AppColors.setDarkMode(isDark);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }
}
