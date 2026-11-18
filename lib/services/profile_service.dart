import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:path_provider/path_provider.dart';
import '../models/body_measurement.dart';
import '../models/chart_data.dart';
import 'avatar_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  static const double avatarPickSize = 192;
  static const int avatarPickQuality = 75;

  static const int maxAvatarBytes = 100 * 1024;

  static const _keyImagePath = 'profile_image_path';
  static const _keyAvatarVersion = 'profile_avatar_version';
  static const _keyAvatarOwner = 'profile_avatar_owner';
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
  static const _keyMeasurements = 'profile_measurements';

  String? _imagePath;
  int _avatarVersion = 0;
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
  final Map<BodyMeasurement, BodyMeasurementEntry> _measurements = {};

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
  Map<BodyMeasurement, BodyMeasurementEntry> get measurements =>
      Map.unmodifiable(_measurements);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _imagePath = prefs.getString(_keyImagePath);
    _avatarVersion = prefs.getInt(_keyAvatarVersion) ?? 0;
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
    _measurements.clear();
    try {
      final raw = prefs.getString(_keyMeasurements);
      if (raw != null) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        for (final type in BodyMeasurement.values) {
          final value = map[type.name];
          if (value is Map<String, dynamic>) {
            _measurements[type] = BodyMeasurementEntry.fromJson(value);
          }
        }
      }
    } catch (_) {
      _measurements.clear();
    }
    notifyListeners();
  }

  Future<void> setMeasurement(BodyMeasurement type, double? cm) async {
    if (cm == null) {
      _measurements.remove(type);
    } else {
      _measurements[type] = BodyMeasurementEntry(cm: cm, date: DateTime.now());
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyMeasurements,
      jsonEncode({
        for (final e in _measurements.entries) e.key.name: e.value.toJson(),
      }),
    );
  }

  Future<bool> setAvatar(Uint8List picked) async {
    final bytes = await _shrinkAvatar(picked);
    if (bytes == null) return false;
    final version = DateTime.now().millisecondsSinceEpoch;
    final path = await _writeAvatarFile(bytes, version);
    await _setLocalAvatar(path, version);
    _uploadAvatar(bytes, version);
    return true;
  }

  Future<void> removeAvatar() async {
    final version = DateTime.now().millisecondsSinceEpoch;
    await _deleteAvatarFiles();
    await _setLocalAvatar(null, version);
    _uploadAvatar(null, version);
  }

  Future<void> syncAvatar() async {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      final owner = prefs.getString(_keyAvatarOwner);
      if (owner != null && owner != uid) {
        await _deleteAvatarFiles();
        await _setLocalAvatar(null, 0);
      }
      await prefs.setString(_keyAvatarOwner, uid);

      if (_avatarVersion == 0 && _imagePath != null) {
        final file = File(_imagePath!);
        if (await file.exists() && await setAvatar(await file.readAsBytes())) {
          return;
        }
        await _setLocalAvatar(null, 0);
      }

      final doc = await FirebaseFirestore.instance
          .collection('user_stats')
          .doc(uid)
          .get();
      final data = doc.data();
      final remoteVersion = (data?['avatarVersion'] as num?)?.toInt() ?? 0;
      final remoteAvatar = data?['avatar'] as String?;

      if (remoteVersion > _avatarVersion) {
        if (remoteAvatar != null && remoteAvatar.isNotEmpty) {
          final bytes = base64Decode(remoteAvatar);
          final path = await _writeAvatarFile(bytes, remoteVersion);
          await _setLocalAvatar(path, remoteVersion);
        } else {
          await _deleteAvatarFiles();
          await _setLocalAvatar(null, remoteVersion);
        }
        AvatarCache.instance.put(uid, remoteAvatar, remoteVersion);
      } else if (_avatarVersion > remoteVersion) {
        final path = _imagePath;
        final bytes = path != null && await File(path).exists()
            ? await File(path).readAsBytes()
            : null;
        _uploadAvatar(bytes, _avatarVersion);
      }
    } catch (e) {
      debugPrint('[AVATAR] Sync error: $e');
    }
  }

  Future<void> _setLocalAvatar(String? path, int version) async {
    _imagePath = path;
    _avatarVersion = version;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_keyImagePath);
    } else {
      await prefs.setString(_keyImagePath, path);
    }
    await prefs.setInt(_keyAvatarVersion, version);
  }

  void _uploadAvatar(Uint8List? bytes, int version) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final encoded = bytes == null ? null : base64Encode(bytes);
    AvatarCache.instance.put(uid, encoded, version);
    FirebaseFirestore.instance.collection('user_stats').doc(uid).set({
      'avatar': encoded ?? FieldValue.delete(),
      'avatarVersion': version,
    }, SetOptions(merge: true)).catchError((Object e) {
      debugPrint('[AVATAR] Upload error: $e');
    });
  }

  Future<Uint8List?> _shrinkAvatar(Uint8List bytes) async {
    if (bytes.length <= maxAvatarBytes) return bytes;
    for (final size in [128, 96]) {
      try {
        final codec = await ui.instantiateImageCodec(bytes,
            targetWidth: size, targetHeight: size);
        final frame = await codec.getNextFrame();
        final data =
            await frame.image.toByteData(format: ui.ImageByteFormat.png);
        frame.image.dispose();
        if (data != null && data.lengthInBytes <= maxAvatarBytes) {
          return data.buffer.asUint8List();
        }
      } catch (e) {
        debugPrint('[AVATAR] Shrink error: $e');
        return null;
      }
    }
    return null;
  }

  Future<String> _writeAvatarFile(Uint8List bytes, int version) async {
    await _deleteAvatarFiles();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/avatar_$version.img');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> _deleteAvatarFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      await for (final entity in dir.list()) {
        final name = entity.uri.pathSegments.last;
        if (entity is File && name.startsWith('avatar_')) {
          await entity.delete();
        }
      }
    } catch (e) {
      debugPrint('[AVATAR] Cleanup error: $e');
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
