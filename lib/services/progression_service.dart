import '../models/workout.dart';
import '../models/workout_history.dart';
import '../models/workout_session.dart';

class ProgressMetrics {
  final double completionRate;
  final double avgWeight;
  final double avgRepsPerSet;
  final int sessionsCount;
  final int avgDurationSeconds;
  final ExerciseDifficulty? lastPerceivedDifficulty;

  ProgressMetrics({
    required this.completionRate,
    required this.avgWeight,
    required this.avgRepsPerSet,
    required this.sessionsCount,
    required this.avgDurationSeconds,
    required this.lastPerceivedDifficulty,
  });
}

class SuggestedExerciseAdjustment {
  final double weight;
  final int reps;
  final int sets;
  final String reason;

  SuggestedExerciseAdjustment({
    required this.weight,
    required this.reps,
    required this.sets,
    required this.reason,
  });
}

class ProgressionService {
  ProgressMetrics analyzeExerciseHistory(
    String exerciseId,
    List<WorkoutHistory> histories, {
    int lookback = 5,
  }) {
    final sessions = <ExerciseResult>[];

    for (var h in histories.reversed) {
      for (var er in h.session.exerciseResults) {
        if (er.exercise.id == exerciseId) {
          sessions.add(er);
        }
      }
      if (sessions.length >= lookback) break;
    }

    if (sessions.isEmpty) {
      return ProgressMetrics(
        completionRate: 0.0,
        avgWeight: 0.0,
        avgRepsPerSet: 0.0,
        sessionsCount: 0,
        avgDurationSeconds: 0,
        lastPerceivedDifficulty: null,
      );
    }

    double totalCompletion = 0.0;
    double totalWeight = 0.0;
    double totalReps = 0.0;
    int totalSets = 0;
    int totalDuration = 0;
    ExerciseDifficulty? lastPerceived;

    for (var er in sessions) {
      int sets = er.setResults.length;
      int possibleReps = er.targetReps * sets;
      int achievedReps = er.setResults.fold(0, (s, r) => s + r.actualReps);
      totalCompletion += possibleReps > 0 ? (achievedReps / possibleReps) : 0.0;
      totalWeight += er.setResults.fold(0.0, (s, r) => s + r.weight) /
          (sets == 0 ? 1 : sets);
      totalReps += sets == 0 ? 0 : (achievedReps / sets);
      totalSets += sets;
      totalDuration += er.setResults.fold(0, (s, r) => s + r.durationSeconds);
      lastPerceived = er.perceivedDifficulty ?? lastPerceived;
    }

    final count = sessions.length;
    return ProgressMetrics(
      completionRate: (totalCompletion / count).clamp(0.0, 1.0),
      avgWeight: totalWeight / count,
      avgRepsPerSet: count == 0 || totalSets == 0 ? 0.0 : (totalReps / count),
      sessionsCount: count,
      avgDurationSeconds: count == 0 ? 0 : (totalDuration ~/ count),
      lastPerceivedDifficulty: lastPerceived,
    );
  }

  Map<String, dynamic> suggestNextWorkout(
    Workout workout,
    List<WorkoutHistory> histories, {
    int lookback = 5,
  }) {
    final adjustedExercises = <WorkoutExercise>[];
    final reasons = <String, String>{};

    for (var we in workout.exercises) {
      final metrics =
          analyzeExerciseHistory(we.exercise.id, histories, lookback: lookback);
      double newWeight = we.weight;
      int newReps = we.targetReps;
      int newSets = we.sets;
      String reason = 'No history — keep prescription';

      if (metrics.sessionsCount == 0) {
        reason = 'No recent data — keep as is';
      } else {
        final c = metrics.completionRate;
        final perceived = metrics.lastPerceivedDifficulty;

        if (we.weight <= 0.0) {
          if (c >= 0.95 && metrics.avgRepsPerSet >= we.targetReps) {
            newReps = we.targetReps + 1;
            reason = 'Bodyweight: completed easily — +1 rep';
          } else if (c < 0.7 || perceived == ExerciseDifficulty.hard) {
            newReps = we.targetReps - 1 > 0 ? we.targetReps - 1 : 1;
            reason = 'Bodyweight: struggled — -1 rep';
          } else {
            reason = 'Bodyweight: keep reps';
          }
        } else {
          if (c >= 0.95 &&
              metrics.avgRepsPerSet >= we.targetReps &&
              perceived != ExerciseDifficulty.hard) {
            newWeight = (we.weight * 1.05);
            reason = 'Completed targets comfortably — increase weight by 5%';
          } else if (c < 0.75 || perceived == ExerciseDifficulty.hard) {
            newWeight = (we.weight * 0.95).clamp(0.0, double.infinity);
            if (c < 0.6)
              newReps = (we.targetReps - 2) > 1 ? we.targetReps - 2 : 1;
            else
              newReps = (we.targetReps - 1) > 1 ? we.targetReps - 1 : 1;
            reason = 'Struggled — reduce weight by 5% and lower reps';
          } else {
            final avgDur = metrics.avgDurationSeconds;
            if (avgDur > 90 && c < 0.9) {
              newWeight = (we.weight * 0.97);
              reason =
                  'Sets took long and completion low — slight weight reduction';
            } else {
              reason = 'Performance stable — keep prescription';
            }
          }
        }
      }

      newWeight = (newWeight * 2).round() / 2.0;

      adjustedExercises.add(
        we.copyWith(sets: newSets, targetReps: newReps, weight: newWeight),
      );

      reasons[we.exercise.id] = reason;
    }

    final adjusted = workout.copyWith(exercises: adjustedExercises);
    return {'workout': adjusted, 'reasons': reasons};
  }
}
