import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  static const _keyImagePath = 'profile_image_path';
  static const _keyFrameIndex = 'profile_frame_index';
  static const _keyWeight = 'profile_weight';
  static const _keyGoals = 'profile_goals';
  static const _keyExperience = 'profile_experience';
  static const _keyFocus = 'profile_focus';
  static const _keyIntensity = 'profile_intensity';

  String? _imagePath;
  int _frameIndex = 0;
  double? _weightKg;
  List<String> _goals = [];
  String? _experienceLevel;
  List<String> _trainingFocus = [];
  String? _preferredIntensity;

  String? get imagePath => _imagePath;
  int get frameIndex => _frameIndex;
  double? get weightKg => _weightKg;
  List<String> get goals => _goals;
  String? get experienceLevel => _experienceLevel;
  List<String> get trainingFocus => _trainingFocus;
  String? get preferredIntensity => _preferredIntensity;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _imagePath = prefs.getString(_keyImagePath);
    _frameIndex = prefs.getInt(_keyFrameIndex) ?? 0;
    _weightKg =
        prefs.containsKey(_keyWeight) ? prefs.getDouble(_keyWeight) : null;
    _goals = prefs.getStringList(_keyGoals) ?? [];
    _experienceLevel = prefs.getString(_keyExperience);
    _trainingFocus = prefs.getStringList(_keyFocus) ?? [];
    _preferredIntensity = prefs.getString(_keyIntensity);
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

  Future<void> setGoals(List<String> goals) async {
    _goals = goals;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyGoals, goals);
  }

  Future<void> setExperienceLevel(String? level) async {
    _experienceLevel = level;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (level == null) {
      await prefs.remove(_keyExperience);
    } else {
      await prefs.setString(_keyExperience, level);
    }
  }

  Future<void> setTrainingFocus(List<String> focus) async {
    _trainingFocus = focus;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFocus, focus);
  }

  Future<void> setPreferredIntensity(String? intensity) async {
    _preferredIntensity = intensity;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (intensity == null) {
      await prefs.remove(_keyIntensity);
    } else {
      await prefs.setString(_keyIntensity, intensity);
    }
  }
}
