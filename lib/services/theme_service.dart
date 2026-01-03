import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

class AppColor extends ChangeNotifier {
  static const _prefsKey = 'app_primary_color';

  Color _color = AppColors.primary;

  Color get color => _color;

  AppColor();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_prefsKey);
    if (value != null) {
      _color = Color(value);
      AppColors.primary = _color;

      AppColors.textOnPrimary =
          _color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
      notifyListeners();
    }
  }

  Future<void> setColor(Color newColor) async {
    _color = newColor;
    AppColors.primary = newColor;
    AppColors.textOnPrimary =
        newColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // Store color as ARGB integer
    final colorInt = (newColor.a.toInt() << 24) |
        (newColor.r.toInt() << 16) |
        (newColor.g.toInt() << 8) |
        newColor.b.toInt();
    await prefs.setInt(_prefsKey, colorInt);
  }
}
