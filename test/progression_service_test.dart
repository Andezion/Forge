import 'package:flutter_test/flutter_test.dart';
import 'package:dyplom/services/progression_service.dart';
import 'package:dyplom/models/workout.dart';
import 'package:dyplom/models/workout_history.dart';
import 'package:dyplom/models/workout_session.dart';
import 'package:dyplom/models/exercise.dart';
import 'package:dyplom/models/user.dart';

void main() {
  group('ProgressionService Tests', () {
    late ProgressionService service;

    setUp(() {
      service = ProgressionService();
    });

    test('calculate1RM returns correct value', () {
      final oneRM = service.calculate1RM(100, 8);

      expect(oneRM, closeTo(126.7, 0.1));
    });

    test('calculateWeightForReps returns correct value', () {
      final weight = service.calculateWeightForReps(100, 5);

      expect(weight, closeTo(85.7, 0.1));
    });

    test('getRecoveryModifier returns correct values for different scenarios',
        () {
      final optimal = service.getRecoveryModifier(3, 30);
      expect(optimal, equals(1.0));

      final insufficient = service.getRecoveryModifier(1, 30);
      expect(insufficient, lessThan(1.0));

      final tooLong = service.getRecoveryModifier(14, 30);
      expect(tooLong, lessThan(1.0));

      final elderly = service.getRecoveryModifier(2, 60);
      expect(elderly, lessThan(1.0));
    });

    test('shouldDeload detects when deload is needed', () {
      final exercise = Exercise(
        id: 'ex1',
        name: 'Bench Press',
        description: 'Test',
        difficulty: ExerciseDifficulty.medium,
        createdAt: DateTime.now(),
      );

      final histories = List.generate(6, (i) {
        final exerciseResult = ExerciseResult(
          exercise: exercise,
          targetSets: 3,
          targetReps: 10,
          targetWeight: 80.0,
          setResults: [
            ExerciseSetResult(
              setNumber: 1,
              actualReps: 8,
              weight: 80.0,
              timestamp: DateTime.now(),
              durationSeconds: 60,
            ),
          ],
          perceivedDifficulty: ExerciseDifficulty.hard,
        );

        return WorkoutHistory(
          id: 'hist$i',
          date: DateTime.now().subtract(Duration(days: i * 3)),
          session: WorkoutSession(
            id: 'sess$i',
            workoutId: 'workout1',
            workoutName: 'Test Workout',
            startTime: DateTime.now(),
            exerciseResults: [exerciseResult],
            status: WorkoutSessionStatus.completed,
            totalDurationSeconds: 3600,
          ),
        );
      });

      final needsDeload = service.shouldDeload(histories);
      expect(needsDeload, isTrue);
    });

    test('analyzeExerciseHistory calculates metrics correctly', () {
      final exercise = Exercise(
        id: 'ex1',
        name: 'Squat',
        description: 'Test',
        difficulty: ExerciseDifficulty.medium,
        createdAt: DateTime.now(),
      );

      final histories = [
        _createHistory(exercise, 90.0, 10, 10,
            DateTime.now().subtract(const Duration(days: 2))),
        _createHistory(exercise, 87.5, 10, 10,
            DateTime.now().subtract(const Duration(days: 5))),
        _createHistory(exercise, 85.0, 10, 10,
            DateTime.now().subtract(const Duration(days: 8))),
        _createHistory(exercise, 82.5, 10, 10,
            DateTime.now().subtract(const Duration(days: 11))),
        _createHistory(exercise, 80.0, 10, 10,
            DateTime.now().subtract(const Duration(days: 14))),
      ];

      final metrics = service.analyzeExerciseHistory('ex1', histories);

      expect(metrics.completionRate, equals(1.0));
      expect(metrics.sessionsCount, equals(5));
      expect(metrics.weightTrend, greaterThan(0));
      expect(metrics.performanceTrend, greaterThan(0));
      expect(metrics.estimated1RM, greaterThan(100));
      expect(metrics.daysSinceLastSession, equals(2));
    });

    test('suggestNextWorkout increases weight for good performance', () async {
      final exercise = Exercise(
        id: 'ex1',
        name: 'Bench Press',
        description: 'Test',
        difficulty: ExerciseDifficulty.medium,
        createdAt: DateTime.now(),
      );

      final workout = Workout(
        id: 'workout1',
        name: 'Test Workout',
        exercises: [
          WorkoutExercise(
            exercise: exercise,
            sets: 3,
            targetReps: 10,
            weight: 80.0,
          ),
        ],
        createdAt: DateTime.now(),
      );

      final histories = List.generate(5, (i) {
        return _createHistory(
          exercise,
          80.0,
          10,
          10,
          DateTime.now().subtract(Duration(days: (i + 1) * 3)),
        );
      });

      final profile = UserProfile(
        goals: [TrainingGoal.strength],
        experienceLevel: ExperienceLevel.intermediate,
        trainingFocus: ['chest', 'upper body'],
        preferredIntensity: TrainingIntensity.moderate,
        age: 30,
        weightKg: 75.0,
        yearsTraining: 2.0,
      );

      final result = await service.suggestNextWorkout(
        workout,
        histories,
        profile: profile,
      );

      final suggestedWorkout = result['workout'] as Workout;
      final suggestedExercise = suggestedWorkout.exercises.first;

      expect(suggestedExercise.weight, greaterThan(80.0));
    });

    test('suggestNextWorkout decreases weight for poor performance', () async {
      final exercise = Exercise(
        id: 'ex1',
        name: 'Deadlift',
        description: 'Test',
        difficulty: ExerciseDifficulty.medium,
        createdAt: DateTime.now(),
      );

      final workout = Workout(
        id: 'workout1',
        name: 'Test Workout',
        exercises: [
          WorkoutExercise(
            exercise: exercise,
            sets: 3,
            targetReps: 10,
            weight: 120.0,
          ),
        ],
        createdAt: DateTime.now(),
      );

      final histories = List.generate(3, (i) {
        final exerciseResult = ExerciseResult(
          exercise: exercise,
          targetSets: 3,
          targetReps: 10,
          targetWeight: 120.0,
          setResults: [
            ExerciseSetResult(
              setNumber: 1,
              actualReps: 6,
              weight: 120.0,
              timestamp: DateTime.now(),
              durationSeconds: 90,
            ),
            ExerciseSetResult(
              setNumber: 2,
              actualReps: 5,
              weight: 120.0,
              timestamp: DateTime.now(),
              durationSeconds: 95,
            ),
            ExerciseSetResult(
              setNumber: 3,
              actualReps: 4,
              weight: 120.0,
              timestamp: DateTime.now(),
              durationSeconds: 100,
            ),
          ],
          perceivedDifficulty: ExerciseDifficulty.hard,
        );

        return WorkoutHistory(
          id: 'hist$i',
          date: DateTime.now().subtract(Duration(days: (i + 1) * 3)),
          session: WorkoutSession(
            id: 'sess$i',
            workoutId: 'workout1',
            workoutName: 'Test Workout',
            startTime: DateTime.now(),
            exerciseResults: [exerciseResult],
            status: WorkoutSessionStatus.completed,
            totalDurationSeconds: 3600,
          ),
        );
      });

      final profile = UserProfile(
        goals: [TrainingGoal.strength],
        experienceLevel: ExperienceLevel.intermediate,
        trainingFocus: ['back', 'legs'],
        preferredIntensity: TrainingIntensity.moderate,
        age: 30,
        weightKg: 80.0,
        yearsTraining: 2.0,
      );

      final result = await service.suggestNextWorkout(
        workout,
        histories,
        profile: profile,
      );

      final suggestedWorkout = result['workout'] as Workout;
      final suggestedExercise = suggestedWorkout.exercises.first;

      expect(
        suggestedExercise.weight < 120.0 || suggestedExercise.targetReps < 10,
        isTrue,
      );
    });
  });
}

WorkoutHistory _createHistory(
  Exercise exercise,
  double weight,
  int targetReps,
  int actualReps,
  DateTime date,
) {
  final exerciseResult = ExerciseResult(
    exercise: exercise,
    targetSets: 3,
    targetReps: targetReps,
    targetWeight: weight,
    setResults: List.generate(3, (i) {
      return ExerciseSetResult(
        setNumber: i + 1,
        actualReps: actualReps,
        weight: weight,
        timestamp: date,
        durationSeconds: 60,
      );
    }),
    perceivedDifficulty: ExerciseDifficulty.medium,
  );

  return WorkoutHistory(
    id: 'hist_${date.millisecondsSinceEpoch}',
    date: date,
    session: WorkoutSession(
      id: 'sess_${date.millisecondsSinceEpoch}',
      workoutId: 'workout1',
      workoutName: 'Test Workout',
      startTime: date,
      exerciseResults: [exerciseResult],
      status: WorkoutSessionStatus.completed,
      totalDurationSeconds: 3600,
    ),
  );
}
