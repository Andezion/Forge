import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  static const _keyImagePath = 'profile_image_path';
  static const _keyFrameIndex = 'profile_frame_index';
  static const _keyWeight = 'profile_weight';

  String? _imagePath;
  int _frameIndex = 0;
  double? _weightKg;

  String? get imagePath => _imagePath;
  int get frameIndex => _frameIndex;
  double? get weightKg => _weightKg;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _imagePath = prefs.getString(_keyImagePath);
    _frameIndex = prefs.getInt(_keyFrameIndex) ?? 0;
    _weightKg =
        prefs.containsKey(_keyWeight) ? prefs.getDouble(_keyWeight) : null;
    notifyListeners();
  }

  Future<void> setImagePath(String? path) async {
    _imagePath = path;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_keyImagePath);
    } else {
      await prefs.setString(_keyImagePath, path);
    }
  }

  Future<void> setFrameIndex(int index) async {
    _frameIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFrameIndex, index);
  }

  Future<void> setWeightKg(double? kg) async {
    _weightKg = kg;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (kg == null) {
      await prefs.remove(_keyWeight);
    } else {
      await prefs.setDouble(_keyWeight, kg);
    }
  }
}
