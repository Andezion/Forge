import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:convert';
import '../models/app_settings.dart';

class SettingsService extends ChangeNotifier {
  static const _settingsKey = 'app_settings';

  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  String? get nickname => _settings.nickname;
  String? get region => _settings.region;
  AppLanguage get language => _settings.language;
  WeightUnit get weightUnit => _settings.weightUnit;
  DistanceUnit get distanceUnit => _settings.distanceUnit;
  bool get isProfilePublic => _settings.isProfilePublic;
  bool get showWorkoutHistory => _settings.showWorkoutHistory;
  bool get showPersonalRecords => _settings.showPersonalRecords;
  bool get allowFriendRequests => _settings.allowFriendRequests;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson != null) {
      try {
        final map = json.decode(settingsJson) as Map<String, dynamic>;
        _settings = AppSettings.fromJson(map);
        notifyListeners();
      } catch (e) {}
    }

    await _loadNicknameFromFirebase();
  }

  Future<void> _loadNicknameFromFirebase() async {
    try {
      final fb_auth.FirebaseAuth auth = fb_auth.FirebaseAuth.instance;
      final FirebaseFirestore db = FirebaseFirestore.instance;

      final userId = auth.currentUser?.uid;
      if (userId != null) {
        final doc = await db.collection('users').doc(userId).get();
        if (doc.exists) {
          final data = doc.data();
          final firebaseNickname = data?['nickname'] as String?;
          if (firebaseNickname != null && firebaseNickname.trim().isNotEmpty) {
            if (_settings.nickname != firebaseNickname) {
              _settings = _settings.copyWith(nickname: firebaseNickname);
              notifyListeners();
              await _save();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading nickname from Firebase: $e');
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(_settings.toJson());
    await prefs.setString(_settingsKey, settingsJson);
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await _save();
  }

  Future<void> setNickname(String? nickname) async {
    _settings = _settings.copyWith(nickname: nickname);
    notifyListeners();
    await _save();

    await _saveNicknameToFirebase(nickname);
  }

  Future<void> _saveNicknameToFirebase(String? nickname) async {
    try {
      final fb_auth.FirebaseAuth auth = fb_auth.FirebaseAuth.instance;
      final FirebaseFirestore db = FirebaseFirestore.instance;

      final userId = auth.currentUser?.uid;
      if (userId != null && nickname != null && nickname.trim().isNotEmpty) {
        await db.collection('users').doc(userId).update({
          'nickname': nickname,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error saving nickname to Firebase: $e');
    }
  }

  Future<void> setRegion(String? region) async {
    _settings = _settings.copyWith(region: region);
    notifyListeners();
    await _save();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _settings = _settings.copyWith(language: language);
    notifyListeners();
    await _save();
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    _settings = _settings.copyWith(weightUnit: unit);
    notifyListeners();
    await _save();
  }

  Future<void> setDistanceUnit(DistanceUnit unit) async {
    _settings = _settings.copyWith(distanceUnit: unit);
    notifyListeners();
    await _save();
  }

  Future<void> setProfilePublic(bool isPublic) async {
    _settings = _settings.copyWith(isProfilePublic: isPublic);
    notifyListeners();
    await _save();
  }

  Future<void> setShowWorkoutHistory(bool show) async {
    _settings = _settings.copyWith(showWorkoutHistory: show);
    notifyListeners();
    await _save();
  }

  Future<void> setShowPersonalRecords(bool show) async {
    _settings = _settings.copyWith(showPersonalRecords: show);
    notifyListeners();
    await _save();
  }

  Future<void> setAllowFriendRequests(bool allow) async {
    _settings = _settings.copyWith(allowFriendRequests: allow);
    notifyListeners();
    await _save();
  }

  // Helper methods for conversions
  double convertWeight(double kg) {
    if (_settings.weightUnit == WeightUnit.lb) {
      return kg * 2.20462;
    }
    return kg;
  }

  double convertWeightToKg(double value) {
    if (_settings.weightUnit == WeightUnit.lb) {
      return value / 2.20462;
    }
    return value;
  }

  String getWeightUnitString() {
    return _settings.weightUnit == WeightUnit.kg ? 'kg' : 'lb';
  }

  String getDistanceUnitString() {
    return _settings.distanceUnit == DistanceUnit.meters ? 'm' : 'ft';
  }
}
