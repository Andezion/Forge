import '../models/exercise.dart';
import '../models/workout.dart';

class WorkoutImportPlan {
  final Workout workout;
  final List<Exercise> newExercises;
  final List<Exercise> matchedExercises;

  const WorkoutImportPlan({
    required this.workout,
    required this.newExercises,
    required this.matchedExercises,
  });
}

String normalizeExerciseName(String name) =>
    name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

WorkoutImportPlan planWorkoutImport({
  required Workout source,
  required List<Exercise> existing,
  required String sourcePublicId,
  required String Function() newId,
  DateTime? now,
}) {
  final createdAt = now ?? DateTime.now();
  final byName = <String, Exercise>{
    for (final e in existing) normalizeExerciseName(e.name): e,
  };
  final byId = {for (final e in existing) e.id: e};

  final resolved = <String, Exercise>{};
  final newExercises = <Exercise>[];
  final matched = <Exercise>[];

  Exercise resolve(Exercise ex) {
    final cached = resolved[ex.id];
    if (cached != null) return cached;

    final key = normalizeExerciseName(ex.name);
    final sameId = byId[ex.id];
    Exercise result;
    if (sameId != null && normalizeExerciseName(sameId.name) == key) {
      result = sameId;
      if (!matched.contains(result)) matched.add(result);
    } else if (byName[key] != null) {
      result = byName[key]!;
      if (!newExercises.contains(result) && !matched.contains(result)) {
        matched.add(result);
      }
    } else {
      result = ex.copyWith(id: newId(), createdAt: createdAt);
      newExercises.add(result);
      byName[key] = result;
    }
    resolved[ex.id] = result;
    return result;
  }

  final exercises = source.exercises
      .map((we) => WorkoutExercise(
            exercise: resolve(we.exercise),
            sets: we.sets,
            targetReps: we.targetReps,
            weight: 0,
            targetDurationMinutes: we.targetDurationMinutes,
            alternativeExercises:
                we.alternativeExercises.map(resolve).toList(),
          ))
      .toList();

  return WorkoutImportPlan(
    workout: Workout(
      id: newId(),
      name: source.name,
      exercises: exercises,
      createdAt: createdAt,
      sourcePublicId: sourcePublicId,
    ),
    newExercises: newExercises,
    matchedExercises: matched,
  );
}
