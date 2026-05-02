import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/world_record.dart';

class WorldRecordsService {
  static final WorldRecordsService _instance = WorldRecordsService._internal();
  factory WorldRecordsService() => _instance;
  WorldRecordsService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<WorldRecord> _localFallback = [];
  bool _localLoaded = false;

  // In-memory cache for the session
  final Map<String, WorldRecord?> _sessionCache = {};

  static const _prefsCachePrefix = 'wr_fs_';
  static const _prefsTsPrefix = 'wr_fs_ts_';
  static const _cacheTtlSeconds = 24 * 3600;

  // Converts local weight class format ('-83 kg') to Firestore key ('83')
  static String normalizeWeightClass(String wc) {
    if (wc.startsWith('+')) return '120p';
    return wc.replaceAll(' kg', '').replaceAll('-', '').replaceAll('+', 'p');
  }

  static String _docKey(
      String exercise, String weightClass, String gender, bool equipped) {
    final wc = normalizeWeightClass(weightClass);
    final eq = equipped ? 'equipped' : 'raw';
    return '${exercise}_${wc}_${gender}_$eq';
  }

  Future<WorldRecord?> getRecord({
    required String exercise,
    required String weightClass,
    required String gender,
    required bool equipped,
    String federation = 'IPF',
  }) async {
    final key = _docKey(exercise, weightClass, gender, equipped);

    if (_sessionCache.containsKey(key)) return _sessionCache[key];

    // Try SharedPreferences cache first (24h TTL)
    final cached = await _loadPrefsCache(key);
    if (cached != null) {
      _sessionCache[key] = cached;
      return cached;
    }

    // Fetch from Firestore
    try {
      final doc = await _db.collection('world_records').doc(key).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final record = WorldRecord(
          id: key,
          exercise: data['exercise'] as String? ?? exercise,
          federation: data['federation'] as String? ?? federation,
          weightClass: data['weightClass'] as String? ?? weightClass,
          gender: data['gender'] as String? ?? gender,
          equipped: data['equipped'] as bool? ?? equipped,
          weight: (data['weight'] as num).toDouble(),
          athleteName: data['athleteName'] as String? ?? '',
          country: data['country'] as String? ?? '',
          recordDate: data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
        );
        _sessionCache[key] = record;
        await _savePrefsCache(key, record);
        return record;
      }
    } catch (e) {
      debugPrint('[WorldRecords] Firestore error for $key: $e');
    }

    // Fallback to local JSON
    return _getLocalRecord(
        exercise: exercise,
        weightClass: weightClass,
        gender: gender,
        equipped: equipped,
        federation: federation);
  }

  Future<WorldRecord?> _getLocalRecord({
    required String exercise,
    required String weightClass,
    required String gender,
    required bool equipped,
    required String federation,
  }) async {
    await _ensureLocalLoaded();
    try {
      return _localFallback.firstWhere(
        (r) =>
            r.exercise == exercise &&
            r.weightClass == weightClass &&
            r.gender == gender &&
            r.equipped == equipped &&
            r.federation == federation,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureLocalLoaded() async {
    if (_localLoaded) return;
    try {
      final json =
          await rootBundle.loadString('assets/data/world_records.json');
      final list = jsonDecode(json) as List;
      _localFallback = list.map((e) => WorldRecord.fromJson(e)).toList();
      _localLoaded = true;
    } catch (e) {
      debugPrint('[WorldRecords] Local JSON load error: $e');
    }
  }

  Future<WorldRecord?> _loadPrefsCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('$_prefsCachePrefix$key');
      final ts = prefs.getInt('$_prefsTsPrefix$key') ?? 0;
      if (json == null) return null;
      final age = DateTime.now().millisecondsSinceEpoch ~/ 1000 - ts;
      if (age > _cacheTtlSeconds) return null;
      final data = jsonDecode(json) as Map<String, dynamic>;
      return WorldRecord.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> _savePrefsCache(String key, WorldRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefsCachePrefix$key', jsonEncode(record.toJson()));
      await prefs.setInt(
          '$_prefsTsPrefix$key', DateTime.now().millisecondsSinceEpoch ~/ 1000);
    } catch (_) {}
  }

  // Kept for backward compat with World Records tab
  Future<void> loadRecords() async => _ensureLocalLoaded();

  List<WorldRecord> getAllRecords() => List.unmodifiable(_localFallback);

  List<WorldRecord> getRecords({
    String? federation,
    String? weightClass,
    String? gender,
    bool? equipped,
    String? exercise,
  }) {
    return _localFallback.where((r) {
      if (federation != null && r.federation != federation) return false;
      if (weightClass != null && r.weightClass != weightClass) return false;
      if (gender != null && r.gender != gender) return false;
      if (equipped != null && r.equipped != equipped) return false;
      if (exercise != null && r.exercise != exercise) return false;
      return true;
    }).toList();
  }

  String getWeightClass(double weightKg, String gender) {
    if (gender == 'male') {
      if (weightKg < 59) return '-59 kg';
      if (weightKg < 66) return '-66 kg';
      if (weightKg < 74) return '-74 kg';
      if (weightKg < 83) return '-83 kg';
      if (weightKg < 93) return '-93 kg';
      if (weightKg < 105) return '-105 kg';
      if (weightKg < 120) return '-120 kg';
      return '+120 kg';
    } else {
      if (weightKg < 47) return '-47 kg';
      if (weightKg < 52) return '-52 kg';
      if (weightKg < 57) return '-57 kg';
      if (weightKg < 63) return '-63 kg';
      if (weightKg < 69) return '-69 kg';
      if (weightKg < 76) return '-76 kg';
      if (weightKg < 84) return '-84 kg';
      return '+84 kg';
    }
  }

  void clearCache() => _sessionCache.clear();
}
