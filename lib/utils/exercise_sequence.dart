import '../models/workout.dart';

List<WorkoutExercise> insertExerciseAhead({
  required List<WorkoutExercise> queue,
  required int currentIndex,
  required int aheadOffset,
  required WorkoutExercise toInsert,
}) {
  final result = List<WorkoutExercise>.from(queue);
  final insertAt = (currentIndex + 1 + aheadOffset).clamp(0, result.length);
  result.insert(insertAt, toInsert);
  return result;
}
