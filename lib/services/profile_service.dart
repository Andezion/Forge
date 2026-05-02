import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/chart_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  static const _keyImagePath = 'profile_image_path';
  static const _keyFrameIndex = 'profile_frame_index';
  static const _keyWeight = 'profile_weight';
  static const _keyGoals = 'profile_goals';
  static const _keyExperience = 'profile_experience';
  static const _keyFocus = 'profile_focus';
  static const _keyIntensity = 'profile_intensity';
  static const _keyAge = 'profile_age';
  static const _keyHeight = 'profile_height';
  static const _keyYearsTraining = 'profile_years_training';
  static const _keyWeightHistory = 'profile_weight_history';
  static const _keyGender = 'profile_gender';
  static const _keyTrainingDays = 'profile_training_days';
  static const _keySessionDuration = 'profile_session_duration';
  static const _keyInjuries = 'profile_injuries';
  static const _keyCountry = 'profile_country';
  static const _keyCity = 'profile_city';

  String? _imagePath;
  int _frameIndex = 0;
  double? _weightKg;
  final List<ChartDataPoint> _weightHistory = [];
  List<String> _goals = [];
  String? _experienceLevel;
  List<String> _trainingFocus = [];
  String? _preferredIntensity;
  int? _age;
  double? _heightCm;
  double? _yearsTraining;
  String? _gender;
  int? _trainingDaysPerWeek;
  String? _sessionDuration;
  List<String> _injuries = [];
  String? _country;
  String? _city;

  String? get imagePath => _imagePath;
  int get frameIndex => _frameIndex;
  double? get weightKg => _weightKg;
  List<ChartDataPoint> get weightHistory => List.unmodifiable(_weightHistory);
  List<String> get goals => _goals;
  String? get experienceLevel => _experienceLevel;
  List<String> get trainingFocus => _trainingFocus;
  String? get preferredIntensity => _preferredIntensity;
  int? get age => _age;
  double? get heightCm => _heightCm;
  double? get yearsTraining => _yearsTraining;
  String? get gender => _gender;
  int? get trainingDaysPerWeek => _trainingDaysPerWeek;
  String? get sessionDuration => _sessionDuration;
  List<String> get injuries => _injuries;
  String? get country => _country;
  String? get city => _city;

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
    _age = prefs.containsKey(_keyAge) ? prefs.getInt(_keyAge) : null;
    _heightCm =
        prefs.containsKey(_keyHeight) ? prefs.getDouble(_keyHeight) : null;
    _yearsTraining = prefs.containsKey(_keyYearsTraining)
        ? prefs.getDouble(_keyYearsTraining)
        : null;
    _gender = prefs.getString(_keyGender);
    _trainingDaysPerWeek = prefs.containsKey(_keyTrainingDays)
        ? prefs.getInt(_keyTrainingDays)
        : null;
    _sessionDuration = prefs.getString(_keySessionDuration);
    _injuries = prefs.getStringList(_keyInjuries) ?? [];
    _country = prefs.getString(_keyCountry);
    _city = prefs.getString(_keyCity);
    try {
      final hist = prefs.getStringList(_keyWeightHistory) ?? [];
      _weightHistory.clear();
      for (var s in hist) {
        final m = jsonDecode(s) as Map<String, dynamic>;
        final dt = DateTime.parse(m['t'] as String);
        final w = (m['w'] as num).toDouble();
        _weightHistory.add(ChartDataPoint(date: dt, value: w));
      }
    } catch (_) {
      _weightHistory.clear();
    }
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
    final prefs = await SharedPreferences.getInstance();
    if (kg == null) {
      await prefs.remove(_keyWeight);
    } else {
      await prefs.setDouble(_keyWeight, kg);
      try {
        final entry = jsonEncode({
          't': DateTime.now().toIso8601String(),
          'w': kg,
        });
        final hist = prefs.getStringList(_keyWeightHistory) ?? [];
        hist.insert(0, entry);
        if (hist.length > 365) hist.removeRange(365, hist.length);
        await prefs.setStringList(_keyWeightHistory, hist);
        _weightHistory.insert(
            0, ChartDataPoint(date: DateTime.now(), value: kg));
        if (_weightHistory.length > 365) {
          _weightHistory.removeRange(365, _weightHistory.length);
        }
      } catch (_) {}
    }
    notifyListeners();
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

  Future<void> setAge(int? age) async {
    _age = age;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (age == null) {
      await prefs.remove(_keyAge);
    } else {
      await prefs.setInt(_keyAge, age);
    }
  }

  Future<void> setHeightCm(double? height) async {
    _heightCm = height;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (height == null) {
      await prefs.remove(_keyHeight);
    } else {
      await prefs.setDouble(_keyHeight, height);
    }
  }

  Future<void> setYearsTraining(double? years) async {
    _yearsTraining = years;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (years == null) {
      await prefs.remove(_keyYearsTraining);
    } else {
      await prefs.setDouble(_keyYearsTraining, years);
    }
  }

  Future<void> setGender(String? gender) async {
    _gender = gender;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (gender == null) {
      await prefs.remove(_keyGender);
    } else {
      await prefs.setString(_keyGender, gender);
    }
  }

  Future<void> setTrainingDaysPerWeek(int? days) async {
    _trainingDaysPerWeek = days;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (days == null) {
      await prefs.remove(_keyTrainingDays);
    } else {
      await prefs.setInt(_keyTrainingDays, days);
    }
  }

  Future<void> setSessionDuration(String? duration) async {
    _sessionDuration = duration;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (duration == null) {
      await prefs.remove(_keySessionDuration);
    } else {
      await prefs.setString(_keySessionDuration, duration);
    }
  }

  Future<void> setInjuries(List<String> injuries) async {
    _injuries = injuries;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyInjuries, injuries);
  }

  Future<void> setCountry(String? country) async {
    _country = country;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (country == null) {
      await prefs.remove(_keyCountry);
    } else {
      await prefs.setString(_keyCountry, country);
    }
  }

  Future<void> setCity(String? city) async {
    _city = city;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (city == null) {
      await prefs.remove(_keyCity);
    } else {
      await prefs.setString(_keyCity, city);
    }
  }
}
