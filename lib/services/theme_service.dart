import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

class AppColor extends ChangeNotifier {
  static const _prefsKey = 'app_primary_color';
  static const _darkModeKey = 'app_dark_mode';

  Color _color = AppColors.primary;
  bool _isDarkMode = false;

  Color get color => _color;
  bool get isDarkMode => _isDarkMode;

  AppColor();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    AppColors.setDarkMode(_isDarkMode);

    final value = prefs.getInt(_prefsKey);
    if (value != null) {
      try {
        final loadedColor = Color(value);

        if (loadedColor.a > 100 &&
            (loadedColor.r > 0 || loadedColor.g > 0 || loadedColor.b > 0)) {
          _color = loadedColor;
          AppColors.primary = _color;

          AppColors.textOnPrimary =
              _color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
          notifyListeners();
        } else {
          await prefs.remove(_prefsKey);
        }
      } catch (e) {
        await prefs.remove(_prefsKey);
      }
    }
  }

  Future<void> setColor(Color newColor) async {
    _color = newColor;
    AppColors.primary = newColor;
    AppColors.textOnPrimary =
        newColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

    final colorValue = (newColor.a.toInt() << 24) |
        (newColor.r.toInt() << 16) |
        (newColor.g.toInt() << 8) |
        newColor.b.toInt();
    await prefs.setInt(_prefsKey, colorValue);
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    AppColors.setDarkMode(isDark);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }
}
