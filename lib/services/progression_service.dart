import '../models/workout.dart';
import '../models/workout_history.dart';
import '../models/workout_session.dart';
import '../models/user.dart';
import 'profile_service.dart';

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

  Future<Map<String, dynamic>> suggestNextWorkout(
    Workout workout,
    List<WorkoutHistory> histories, {
    int lookback = 5,
    UserProfile? profile,
  }) async {
    if (profile == null) {
      final ps = ProfileService();
      await ps.load();
      final goals = ps.goals
          .map((g) => TrainingGoal.values.firstWhere((e) => e.name == g,
              orElse: () => TrainingGoal.general_fitness))
          .toList();
      final experience = ps.experienceLevel != null
          ? ExperienceLevel.values.firstWhere(
              (e) => e.name == ps.experienceLevel,
              orElse: () => ExperienceLevel.intermediate)
          : ExperienceLevel.intermediate;
      final focus = ps.trainingFocus;
      final intensity = ps.preferredIntensity != null
          ? TrainingIntensity.values.firstWhere(
              (e) => e.name == ps.preferredIntensity,
              orElse: () => TrainingIntensity.moderate)
          : TrainingIntensity.moderate;

      profile = UserProfile(
        goals: goals,
        experienceLevel: experience,
        trainingFocus: focus,
        preferredIntensity: intensity,
      );
    }
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
        double baseIncreasePct;
        double baseDecreasePct;
        switch (profile?.experienceLevel ?? ExperienceLevel.intermediate) {
          case ExperienceLevel.beginner:
            baseIncreasePct = 0.03;
            baseDecreasePct = 0.03;
            break;
          case ExperienceLevel.intermediate:
            baseIncreasePct = 0.05;
            baseDecreasePct = 0.05;
            break;
          case ExperienceLevel.advanced:
            baseIncreasePct = 0.08;
            baseDecreasePct = 0.06;
            break;
        }

        final intensity =
            profile?.preferredIntensity ?? TrainingIntensity.moderate;
        double intensityMultiplier;
        switch (intensity) {
          case TrainingIntensity.light:
            intensityMultiplier = 0.6;
            break;
          case TrainingIntensity.moderate:
            intensityMultiplier = 1.0;
            break;
          case TrainingIntensity.intense:
            intensityMultiplier = 1.4;
            break;
        }

        final increaseFactor = 1.0 + (baseIncreasePct * intensityMultiplier);
        final decreaseFactor = 1.0 - (baseDecreasePct * intensityMultiplier);

        final c = metrics.completionRate;
        final perceived = metrics.lastPerceivedDifficulty;

        if (we.weight <= 0.0) {
          if (c >= 0.95 && metrics.avgRepsPerSet >= we.targetReps) {
            final add =
                profile?.experienceLevel == ExperienceLevel.advanced ? 2 : 1;
            newReps = we.targetReps + add;
            reason = 'Bodyweight: completed easily — +$add rep(s)';
          } else if (c < 0.7 || perceived == ExerciseDifficulty.hard) {
            final sub =
                profile?.experienceLevel == ExperienceLevel.beginner ? 1 : 2;
            newReps = we.targetReps - sub > 0 ? we.targetReps - sub : 1;
            reason = 'Bodyweight: struggled — -$sub rep(s)';
          } else {
            reason = 'Bodyweight: keep reps';
          }
        } else {
          if (c >= 0.95 &&
              metrics.avgRepsPerSet >= we.targetReps &&
              perceived != ExerciseDifficulty.hard) {
            newWeight = (we.weight * increaseFactor);
            reason = 'Completed targets comfortably — increase weight';
          } else if (c < 0.75 || perceived == ExerciseDifficulty.hard) {
            newWeight =
                (we.weight * decreaseFactor).clamp(0.0, double.infinity);
            if (c < 0.6)
              newReps = (we.targetReps - 2) > 1 ? we.targetReps - 2 : 1;
            else
              newReps = (we.targetReps - 1) > 1 ? we.targetReps - 1 : 1;
            reason = 'Struggled — reduce weight and lower reps';
          } else {
            final avgDur = metrics.avgDurationSeconds;
            if (avgDur > 90 && c < 0.9) {
              newWeight = (we.weight * (1.0 - 0.02 * intensityMultiplier));
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
