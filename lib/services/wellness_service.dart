import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/wellness_entry.dart';

class WellnessService extends ChangeNotifier {
  static const _key = 'wellness_entries';

  List<WellnessEntry> _entries = [];

  List<WellnessEntry> get entries => List.unmodifiable(_entries);

  WellnessEntry? get lastEntry => _entries.isEmpty ? null : _entries.first;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _entries = raw
        .map((s) =>
            WellnessEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }

  Future<void> addEntry(WellnessEntry entry) async {
    _entries.insert(0, entry);
    await _save();
    notifyListeners();
  }

  bool canSubmit({Duration cooldown = const Duration(hours: 8)}) {
    final last = lastEntry;
    if (last == null) return true;
    return DateTime.now().difference(last.timestamp) >= cooldown;
  }

  Duration timeUntilNext({Duration cooldown = const Duration(hours: 8)}) {
    final last = lastEntry;
    if (last == null) return Duration.zero;
    final next = last.timestamp.add(cooldown);
    final diff = next.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}
