import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/world_record.dart';

class WorldRecordsService {
  static final WorldRecordsService _instance = WorldRecordsService._internal();
  factory WorldRecordsService() => _instance;
  WorldRecordsService._internal();

  List<WorldRecord> _records = [];
  bool _isLoaded = false;

  Future<void> loadRecords() async {
    if (_isLoaded) return;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/world_records.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _records = jsonList.map((json) => WorldRecord.fromJson(json)).toList();
      _isLoaded = true;
    } catch (e) {
      print('Error loading world records: $e');
      _records = [];
    }
  }

  List<WorldRecord> getAllRecords() => List.unmodifiable(_records);

  List<WorldRecord> getRecords({
    String? federation,
    String? weightClass,
    String? gender,
    bool? equipped,
    String? exercise,
  }) {
    return _records.where((record) {
      if (federation != null && record.federation != federation) return false;
      if (weightClass != null && record.weightClass != weightClass)
        return false;
      if (gender != null && record.gender != gender) return false;
      if (equipped != null && record.equipped != equipped) return false;
      if (exercise != null && record.exercise != exercise) return false;
      return true;
    }).toList();
  }

  WorldRecord? getRecord({
    required String federation,
    required String weightClass,
    required String gender,
    required bool equipped,
    required String exercise,
  }) {
    try {
      return _records.firstWhere(
        (record) =>
            record.federation == federation &&
            record.weightClass == weightClass &&
            record.gender == gender &&
            record.equipped == equipped &&
            record.exercise == exercise,
      );
    } catch (e) {
      return null;
    }
  }

  String getWeightClass(double weightKg, String gender) {
    if (gender == 'male') {
      if (weightKg < 59) return '-59kg';
      if (weightKg < 66) return '59-66kg';
      if (weightKg < 74) return '66-74kg';
      if (weightKg < 83) return '74-83kg';
      if (weightKg < 93) return '83-93kg';
      if (weightKg < 105) return '93-105kg';
      if (weightKg < 120) return '105-120kg';
      return '120+kg';
    } else {
      if (weightKg < 47) return '-47kg';
      if (weightKg < 52) return '47-52kg';
      if (weightKg < 57) return '52-57kg';
      if (weightKg < 63) return '57-63kg';
      if (weightKg < 69) return '63-69kg';
      if (weightKg < 76) return '69-76kg';
      if (weightKg < 84) return '76-84kg';
      return '84+kg';
    }
  }

  double compareToWorldRecord({
    required double userWeight,
    required String federation,
    required String weightClass,
    required String gender,
    required bool equipped,
    required String exercise,
  }) {
    final record = getRecord(
      federation: federation,
      weightClass: weightClass,
      gender: gender,
      equipped: equipped,
      exercise: exercise,
    );

    if (record == null || record.weight == 0) return 0.0;
    return userWeight / record.weight;
  }

  List<String> getFederations() {
    return _records.map((r) => r.federation).toSet().toList()..sort();
  }

  List<String> getWeightClasses(String gender) {
    return _records
        .where((r) => r.gender == gender)
        .map((r) => r.weightClass)
        .toSet()
        .toList()
      ..sort();
  }
}
