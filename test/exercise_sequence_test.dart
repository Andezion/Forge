import 'package:flutter_test/flutter_test.dart';
import 'package:dyplom/models/exercise.dart';
import 'package:dyplom/models/workout.dart';
import 'package:dyplom/utils/exercise_sequence.dart';

WorkoutExercise _we(String id) {
  return WorkoutExercise(
    exercise: Exercise(
      id: id,
      name: id,
      description: '',
      difficulty: ExerciseDifficulty.medium,
      createdAt: DateTime(2024, 1, 1),
    ),
    sets: 3,
    targetReps: 10,
    weight: 0,
  );
}

void main() {
  group('insertExerciseAhead', () {
    test('inserts a single exercise right after the current one', () {
      final a = _we('Biceps 1');
      final b = _we('Biceps 2');
      final c = _we('Biceps 3');
      final x = _we('Wrist 1');

      final result = insertExerciseAhead(
        queue: [a, b, c],
        currentIndex: 0,
        aheadOffset: 0,
        toInsert: x,
      );

      expect(result.map((e) => e.exercise.id).toList(),
          ['Biceps 1', 'Wrist 1', 'Biceps 2', 'Biceps 3']);
    });

    test('stacks multiple insertions in the order they were made', () {
      final a = _we('Biceps 1');
      final b = _we('Biceps 2');
      final c = _we('Biceps 3');
      final x = _we('Wrist 1');
      final y = _we('Forearm 2');

      var queue = [a, b, c];
      queue = insertExerciseAhead(
        queue: queue,
        currentIndex: 0,
        aheadOffset: 0,
        toInsert: x,
      );
      queue = insertExerciseAhead(
        queue: queue,
        currentIndex: 0,
        aheadOffset: 1,
        toInsert: y,
      );

      expect(queue.map((e) => e.exercise.id).toList(),
          ['Biceps 1', 'Wrist 1', 'Forearm 2', 'Biceps 2', 'Biceps 3']);
    });

    test('does not delete, duplicate, or reorder unrelated exercises', () {
      final original = [_we('A'), _we('B'), _we('C'), _we('D')];
      final inserted = _we('X');

      final result = insertExerciseAhead(
        queue: original,
        currentIndex: 1,
        aheadOffset: 0,
        toInsert: inserted,
      );

      expect(original.map((e) => e.exercise.id).toList(), ['A', 'B', 'C', 'D']);
      expect(result.map((e) => e.exercise.id).toList(),
          ['A', 'B', 'X', 'C', 'D']);
    });

    test('clamps to the end of the queue when inserting past the last index',
        () {
      final a = _we('A');
      final b = _we('B');
      final x = _we('X');

      final result = insertExerciseAhead(
        queue: [a, b],
        currentIndex: 1,
        aheadOffset: 5,
        toInsert: x,
      );

      expect(result.map((e) => e.exercise.id).toList(), ['A', 'B', 'X']);
    });
  });
}
