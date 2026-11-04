import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/personal_challenge.dart';

class PersonalChallengeService extends ChangeNotifier {
  static const _prefix = 'personal_challenge_best_';

  final Map<PersonalExercise, int> _best = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    for (final e in PersonalExercise.values) {
      _best[e] = prefs.getInt('$_prefix${e.name}') ?? 0;
    }
    notifyListeners();
  }

  int bestFor(PersonalExercise exercise) => _best[exercise] ?? 0;

  bool isCompleted(PersonalChallenge c) => bestFor(c.exercise) >= c.targetReps;

  Future<bool> recordAttempt(PersonalExercise exercise, int reps) async {
    if (reps <= bestFor(exercise)) return false;
    _best[exercise] = reps;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix${exercise.name}', reps);
    notifyListeners();
    return true;
  }
}
