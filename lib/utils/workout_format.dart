import 'package:dyplom/l10n/generated/app_localizations.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import 'units.dart';

String formatSetsRepsWeight(
  AppLocalizations l10n,
  Units units, {
  required int sets,
  required int reps,
  required double weightKg,
}) {
  final base = '${l10n.setsCount(sets)} × ${l10n.repsCount(reps)}';
  return weightKg > 0 ? '$base @ ${units.weight(weightKg)}' : base;
}

String formatSetResult(
  AppLocalizations l10n,
  Units units,
  ExerciseSetResult set,
  ExerciseType type,
) {
  switch (type) {
    case ExerciseType.cardio:
      final minutes = set.durationMinutes ?? (set.durationSeconds / 60).round();
      final base = l10n.minutesShort(minutes);
      final kcal = set.calories;
      return kcal != null && kcal > 0
          ? '$base · ${l10n.kcalValue(kcal.round().toString())}'
          : base;
    case ExerciseType.repsOnly:
      return l10n.repsCount(set.actualReps);
    case ExerciseType.weightAndReps:
      final reps = l10n.repsCount(set.actualReps);
      return set.weight > 0 ? '$reps × ${units.weight(set.weight)}' : reps;
  }
}
