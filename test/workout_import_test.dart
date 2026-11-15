import 'package:dyplom/models/exercise.dart';
import 'package:dyplom/models/workout.dart';
import 'package:dyplom/models/public_program.dart';
import 'package:dyplom/utils/workout_import.dart';
import 'package:flutter_test/flutter_test.dart';

Exercise ex(String id, String name,
        {List<MuscleGroupTag> muscles = const []}) =>
    Exercise(
      id: id,
      name: name,
      description: '',
      difficulty: ExerciseDifficulty.medium,
      createdAt: DateTime(2024),
      muscleGroups: muscles,
    );

WorkoutExercise we(Exercise e,
        {List<Exercise> alts = const [], double weight = 100}) =>
    WorkoutExercise(
      exercise: e,
      sets: 3,
      targetReps: 5,
      weight: weight,
      alternativeExercises: alts,
    );

void main() {
  late int counter;
  String newId() => 'new_${counter++}';

  setUp(() => counter = 0);

  WorkoutImportPlan plan(Workout source, List<Exercise> existing) =>
      planWorkoutImport(
        source: source,
        existing: existing,
        sourcePublicId: 'pub_1',
        newId: newId,
        now: DateTime(2026, 1, 1),
      );

  group('planWorkoutImport', () {
    test('reuses exercise with same id and same name', () {
      final local = ex('1', 'Pull-ups');
      final source = Workout(
        id: 'w', name: 'Back', createdAt: DateTime(2025),
        exercises: [we(ex('1', 'Pull-ups'))],
      );

      final p = plan(source, [local]);

      expect(p.newExercises, isEmpty);
      expect(p.matchedExercises, [local]);
      expect(identical(p.workout.exercises.single.exercise, local), isTrue);
    });

    test('same id but different name is NOT reused (user edited built-in)', () {
      final local = ex('1', 'My weighted pull-ups');
      final source = Workout(
        id: 'w', name: 'Back', createdAt: DateTime(2025),
        exercises: [we(ex('1', 'Pull-ups'))],
      );

      final p = plan(source, [local]);

      expect(p.newExercises.single.name, 'Pull-ups');
      expect(p.newExercises.single.id, isNot('1'));
      expect(p.matchedExercises, isEmpty);
    });

    test('matches by normalized name when ids differ', () {
      final local = ex('171000', 'Bench  Press');
      final source = Workout(
        id: 'w', name: 'Chest', createdAt: DateTime(2025),
        exercises: [we(ex('999', '  bench press '))],
      );

      final p = plan(source, [local]);

      expect(p.newExercises, isEmpty);
      expect(p.workout.exercises.single.exercise.id, '171000');
    });

    test('unknown exercise is added with fresh id, keeping its data', () {
      final tag = const MuscleGroupTag(
          group: MuscleGroup.forearms, intensity: MuscleGroupIntensity.primary);
      final source = Workout(
        id: 'w', name: 'Arm', createdAt: DateTime(2025),
        exercises: [we(ex('555', 'Wrist curl', muscles: [tag]))],
      );

      final p = plan(source, []);

      final added = p.newExercises.single;
      expect(added.id, startsWith('new_'));
      expect(added.name, 'Wrist curl');
      expect(added.muscleGroups.single.group, MuscleGroup.forearms);
      expect(p.workout.exercises.single.exercise.id, added.id);
    });

    test('same exercise used twice (main + alternative) is added once', () {
      final squat = ex('10', 'Squat');
      final source = Workout(
        id: 'w', name: 'Legs', createdAt: DateTime(2025),
        exercises: [
          we(squat),
          we(ex('11', 'Leg press'), alts: [squat]),
        ],
      );

      final p = plan(source, []);

      expect(p.newExercises.map((e) => e.name), ['Squat', 'Leg press']);
      final squatId = p.workout.exercises[0].exercise.id;
      expect(p.workout.exercises[1].alternativeExercises.single.id, squatId);
    });

    test('two source exercises with the same name collapse into one', () {
      final source = Workout(
        id: 'w', name: 'Dup', createdAt: DateTime(2025),
        exercises: [we(ex('a', 'Dips')), we(ex('b', 'dips'))],
      );

      final p = plan(source, []);

      expect(p.newExercises, hasLength(1));
      expect(p.matchedExercises, isEmpty);
      expect(p.workout.exercises[0].exercise.id,
          p.workout.exercises[1].exercise.id);
    });

    test('weights are reset, sets/reps kept, workout gets new id and source', () {
      final source = Workout(
        id: 'author_workout', name: 'Heavy', createdAt: DateTime(2025),
        userId: 'author_uid',
        exercises: [we(ex('1', 'Deadlift'), weight: 250)],
      );

      final p = plan(source, []);
      final w = p.workout;

      expect(w.id, isNot('author_workout'));
      expect(w.userId, isNull);
      expect(w.sourcePublicId, 'pub_1');
      expect(w.name, 'Heavy');
      expect(w.exercises.single.weight, 0);
      expect(w.exercises.single.sets, 3);
      expect(w.exercises.single.targetReps, 5);
    });
  });

  group('PublicProgram.sanitizeWorkout', () {
    test('strips weights and user id, applies published name', () {
      final w = Workout(
        id: 'w1', name: 'Local name', createdAt: DateTime(2025),
        userId: 'uid',
        exercises: [we(ex('1', 'Bench'), weight: 140)],
      );

      final clean = PublicProgram.sanitizeWorkout(w, name: 'Store name');

      expect(clean.name, 'Store name');
      expect(clean.userId, isNull);
      expect(clean.exercises.single.weight, 0);
      expect(clean.id, 'w1');
    });
  });

  test('Workout.sourcePublicId survives JSON round-trip', () {
    final w = Workout(
      id: 'x', name: 'n', createdAt: DateTime(2025), exercises: [],
      sourcePublicId: 'uid_123',
    );
    expect(Workout.fromJson(w.toJson()).sourcePublicId, 'uid_123');
    expect(
      Workout.fromJson(w.copyWith(name: 'm').toJson()).sourcePublicId,
      'uid_123',
    );
  });
}
