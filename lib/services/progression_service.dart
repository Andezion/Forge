import '../models/workout.dart';
import '../models/workout_history.dart';
import '../models/workout_session.dart';
import '../models/user.dart';
import '../models/exercise.dart';
import 'profile_service.dart';

class ProgressMetrics {
  final double completionRate;
  final double avgWeight;
  final double avgRepsPerSet;
  final int sessionsCount;
  final int avgDurationSeconds;
  final ExerciseDifficulty? lastPerceivedDifficulty;
  final double weightTrend;
  final double performanceTrend;
  final double estimated1RM;
  final int daysSinceLastSession;

  ProgressMetrics({
    required this.completionRate,
    required this.avgWeight,
    required this.avgRepsPerSet,
    required this.sessionsCount,
    required this.avgDurationSeconds,
    required this.lastPerceivedDifficulty,
    this.weightTrend = 0.0,
    this.performanceTrend = 0.0,
    this.estimated1RM = 0.0,
    this.daysSinceLastSession = 0,
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
  double calculate1RM(double weight, int reps) {
    if (weight <= 0 || reps <= 0) return 0.0;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30.0);
  }

  double calculateWeightForReps(double oneRM, int targetReps) {
    if (oneRM <= 0 || targetReps <= 0) return 0.0;
    if (targetReps == 1) return oneRM;
    return oneRM / (1 + targetReps / 30.0);
  }

  bool shouldDeload(
    List<WorkoutHistory> recentHistories, {
    int checkLastWorkouts = 6,
  }) {
    if (recentHistories.length < checkLastWorkouts) return false;

    int hardWorkouts = 0;
    int totalExercises = 0;

    for (var i = 0; i < checkLastWorkouts && i < recentHistories.length; i++) {
      final session = recentHistories[i].session;
      for (var er in session.exerciseResults) {
        totalExercises++;
        if (er.perceivedDifficulty == ExerciseDifficulty.hard) {
          hardWorkouts++;
        }
      }
    }

    if (totalExercises > 0 && (hardWorkouts / totalExercises) > 0.6) {
      return true;
    }

    return false;
  }

  double getRecoveryModifier(int daysSinceLastWorkout, int userAge) {
    const optimalRecoveryDays = 2.5;

    double ageModifier = 1.0;
    if (userAge > 40) {
      ageModifier = 1.2;
    } else if (userAge > 50) {
      ageModifier = 1.4;
    } else if (userAge > 60) {
      ageModifier = 1.6;
    }

    final optimalWithAge = optimalRecoveryDays * ageModifier;

    if (daysSinceLastWorkout < optimalWithAge) {
      return 0.90 + (daysSinceLastWorkout / optimalWithAge) * 0.10;
    } else if (daysSinceLastWorkout > optimalWithAge * 2.5) {
      final daysOver = daysSinceLastWorkout - (optimalWithAge * 2.5);
      final reduction = (daysOver / 7.0) * 0.05;
      return (1.0 - reduction).clamp(0.80, 1.0);
    }

    return 1.0;
  }

  ProgressMetrics analyzeExerciseHistory(
    String exerciseId,
    List<WorkoutHistory> histories, {
    int lookback = 5,
  }) {
    final sessions = <ExerciseResult>[];
    final sessionDates = <DateTime>[];

    for (var h in histories.reversed) {
      for (var er in h.session.exerciseResults) {
        if (er.exercise.id == exerciseId) {
          sessions.add(er);
          sessionDates.add(h.date);
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
        weightTrend: 0.0,
        performanceTrend: 0.0,
        estimated1RM: 0.0,
        daysSinceLastSession: 0,
      );
    }

    double totalCompletion = 0.0;
    double totalWeight = 0.0;
    double totalReps = 0.0;
    int totalSets = 0;
    int totalDuration = 0;
    ExerciseDifficulty? lastPerceived;

    final weights = <double>[];
    final completionRates = <double>[];
    double maxEstimated1RM = 0.0;

    for (var er in sessions) {
      int sets = er.setResults.length;
      int possibleReps = er.targetReps * sets;
      int achievedReps = er.setResults.fold(0, (s, r) => s + r.actualReps);
      final completion = possibleReps > 0 ? (achievedReps / possibleReps) : 0.0;

      totalCompletion += completion;
      completionRates.add(completion);

      final avgWeightThisSession =
          er.setResults.fold(0.0, (s, r) => s + r.weight) /
              (sets == 0 ? 1 : sets);
      weights.add(avgWeightThisSession);
      totalWeight += avgWeightThisSession;

      totalReps += sets == 0 ? 0 : (achievedReps / sets);
      totalSets += sets;
      totalDuration += er.setResults.fold(0, (s, r) => s + r.durationSeconds);
      lastPerceived = er.perceivedDifficulty ?? lastPerceived;

      for (var setResult in er.setResults) {
        final estimated = calculate1RM(setResult.weight, setResult.actualReps);
        if (estimated > maxEstimated1RM) {
          maxEstimated1RM = estimated;
        }
      }
    }

    final count = sessions.length;

    double weightTrend = 0.0;
    if (weights.length >= 2) {
      final firstHalf =
          weights.take(weights.length ~/ 2).fold(0.0, (a, b) => a + b) /
              (weights.length ~/ 2);
      final secondHalf =
          weights.skip(weights.length ~/ 2).fold(0.0, (a, b) => a + b) /
              (weights.length - weights.length ~/ 2);
      weightTrend = secondHalf - firstHalf;
    }

    double performanceTrend = 0.0;
    if (completionRates.length >= 2 && weights.length >= 2) {
      final firstPerf = (completionRates[0] * weights[0]);
      final lastPerf = (completionRates.last * weights.last);
      performanceTrend = lastPerf - firstPerf;
    }

    final daysSince = sessionDates.isNotEmpty
        ? DateTime.now().difference(sessionDates.last).inDays
        : 0;

    return ProgressMetrics(
      completionRate: (totalCompletion / count).clamp(0.0, 1.0),
      avgWeight: totalWeight / count,
      avgRepsPerSet: count == 0 || totalSets == 0 ? 0.0 : (totalReps / count),
      sessionsCount: count,
      avgDurationSeconds: count == 0 ? 0 : (totalDuration ~/ count),
      lastPerceivedDifficulty: lastPerceived,
      weightTrend: weightTrend,
      performanceTrend: performanceTrend,
      estimated1RM: maxEstimated1RM,
      daysSinceLastSession: daysSince,
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
        age: ps.age,
        weightKg: ps.weightKg,
        yearsTraining: ps.yearsTraining,
      );
    }
    final prof = profile;
    final adjustedExercises = <WorkoutExercise>[];
    final reasons = <String, String>{};

    final needsDeload = shouldDeload(histories);

    final userAge = prof.age ?? 30;

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
        switch (prof.experienceLevel) {
          case ExperienceLevel.beginner:
            baseIncreasePct = 0.05;
            baseDecreasePct = 0.05;
            break;
          case ExperienceLevel.intermediate:
            baseIncreasePct = 0.025;
            baseDecreasePct = 0.05;
            break;
          case ExperienceLevel.advanced:
            baseIncreasePct = 0.0125;
            baseDecreasePct = 0.0375;
            break;
        }

        final intensity = prof.preferredIntensity;
        double intensityMultiplier;
        switch (intensity) {
          case TrainingIntensity.light:
            intensityMultiplier = 0.7;
            break;
          case TrainingIntensity.moderate:
            intensityMultiplier = 1.0;
            break;
          case TrainingIntensity.intense:
            intensityMultiplier = 1.3;
            break;
        }

        final recoveryModifier = getRecoveryModifier(
          metrics.daysSinceLastSession,
          userAge,
        );

        final increaseFactor =
            1.0 + (baseIncreasePct * intensityMultiplier * recoveryModifier);
        final decreaseFactor = 1.0 - (baseDecreasePct * intensityMultiplier);

        final c = metrics.completionRate;
        final perceived = metrics.lastPerceivedDifficulty;

        if (needsDeload) {
          if (we.weight > 0) {
            newWeight = we.weight * 0.70;
          }
          newSets = (we.sets * 0.75).round().clamp(1, we.sets);
          reason = 'Deload week — reduce intensity for recovery';
        } else if (we.weight <= 0.0) {
          if (c >= 0.95 && metrics.avgRepsPerSet >= we.targetReps) {
            final add =
                prof.experienceLevel == ExperienceLevel.advanced ? 2 : 1;
            newReps = we.targetReps + add;
            reason = 'Bodyweight: excellent completion — +$add rep(s)';
          } else if (c >= 0.90 && metrics.performanceTrend > 0) {
            newSets = we.sets + 1;
            reason = 'Bodyweight: good progress — +1 set';
          } else if (c < 0.70 || perceived == ExerciseDifficulty.hard) {
            final sub =
                prof.experienceLevel == ExperienceLevel.beginner ? 1 : 2;
            newReps = (we.targetReps - sub).clamp(1, we.targetReps);
            reason = 'Bodyweight: struggling — -$sub rep(s)';
          } else {
            reason = 'Bodyweight: maintain current level';
          }
        } else {
          if (c >= 0.95 &&
              metrics.avgRepsPerSet >= we.targetReps &&
              perceived != ExerciseDifficulty.hard &&
              metrics.performanceTrend >= 0) {
            newWeight = we.weight * increaseFactor;

            if (metrics.performanceTrend > 5.0 && c >= 0.98) {
              newReps = we.targetReps + 1;
              reason = 'Excellent progress — increase weight & reps';
            } else {
              reason =
                  'Strong performance — increase weight by ${((increaseFactor - 1) * 100).toStringAsFixed(1)}%';
            }
          } else if (c >= 0.85 &&
              c < 0.95 &&
              perceived != ExerciseDifficulty.hard) {
            if (metrics.estimated1RM > 0) {
              final new1RM = metrics.estimated1RM * (1.0 + baseIncreasePct / 2);
              newWeight = calculateWeightForReps(new1RM, we.targetReps);
              reason = 'Good progress — calculated weight from estimated 1RM';
            } else {
              newWeight = we.weight * (1.0 + baseIncreasePct / 2);
              reason = 'Steady progress — small weight increase';
            }
          } else if (c < 0.75 || perceived == ExerciseDifficulty.hard) {
            newWeight = we.weight * decreaseFactor;

            if (c < 0.60) {
              newReps = (we.targetReps - 2).clamp(1, we.targetReps);
              reason = 'Struggling significantly — reduce weight & reps';
            } else {
              newReps = (we.targetReps - 1).clamp(1, we.targetReps);
              reason = 'Hard workout — reduce weight & reps slightly';
            }
          } else if (metrics.performanceTrend < -5.0 &&
              metrics.weightTrend < 0) {
            newWeight = we.weight * 0.90;
            reason = 'Negative trend detected — reduce intensity';
          } else if (metrics.avgDurationSeconds > 120) {
            newWeight = we.weight * 0.95;
            reason = 'Sets taking too long — reduce weight for better form';
          } else if (recoveryModifier < 0.95) {
            newWeight = we.weight * recoveryModifier;
            reason = 'Insufficient recovery time — adjusted for fatigue';
          } else {
            reason = 'Performance stable — maintain current prescription';
          }
        }
      }

      newWeight = (newWeight * 2).round() / 2.0;

      newReps = newReps.clamp(1, 50);
      newSets = newSets.clamp(1, 10);

      adjustedExercises.add(
        we.copyWith(sets: newSets, targetReps: newReps, weight: newWeight),
      );

      reasons[we.exercise.id] = reason;
    }

    final adjusted = workout.copyWith(exercises: adjustedExercises);
    return {
      'workout': adjusted,
      'reasons': reasons,
      'needsDeload': needsDeload,
    };
  }
}
