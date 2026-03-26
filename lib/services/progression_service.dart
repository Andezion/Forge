import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../models/workout_history.dart';
import '../models/workout_session.dart';
import '../models/user.dart';
import '../models/exercise.dart';
import '../models/wellness_entry.dart';
import 'profile_service.dart';
import 'goal_coefficients_service.dart';
import 'data_manager.dart';
import 'wellness_service.dart';

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
  final GoalCoefficientsService _goalService = GoalCoefficientsService();
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

  double getRecoveryModifier(int daysSinceLastWorkout, int userAge,
      {String? gender}) {
    const optimalRecoveryDays = 2.5;

    double ageModifier = 1.0;
    if (userAge > 60) {
      ageModifier = 1.6;
    } else if (userAge > 50) {
      ageModifier = 1.4;
    } else if (userAge > 40) {
      ageModifier = 1.2;
    }

    final genderModifier = gender == 'female' ? 0.95 : 1.0;

    final optimalWithAge = optimalRecoveryDays * ageModifier * genderModifier;

    if (daysSinceLastWorkout < optimalWithAge) {
      return 0.90 + (daysSinceLastWorkout / optimalWithAge) * 0.10;
    } else if (daysSinceLastWorkout <= optimalWithAge * 1.6) {
      return 1.0;
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
    String? exerciseName,
  }) {
    final sessions = <ExerciseResult>[];
    final sessionDates = <DateTime>[];

    for (var h in histories.reversed) {
      for (var er in h.session.exerciseResults) {
        final matchById = er.exercise.id == exerciseId;
        final matchByName = exerciseName != null &&
            er.exercise.name.toLowerCase() == exerciseName.toLowerCase();
        if (matchById || matchByName) {
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
    int totalDuration = 0;
    ExerciseDifficulty? lastPerceived;

    final weights = <double>[];
    final completionRates = <double>[];
    double maxEstimated1RM = 0.0;

    for (var er in sessions) {
      final int sets = er.setResults.length;

      final double completion;
      final double avgWeightThisSession;
      final double repsThisSession;

      if (sets == 0) {
        completion = 1.0;
        avgWeightThisSession = er.targetWeight;
        repsThisSession = er.targetReps.toDouble();
        if (er.targetWeight > 0) {
          final estimated = calculate1RM(er.targetWeight, er.targetReps);
          if (estimated > maxEstimated1RM) maxEstimated1RM = estimated;
        }
      } else {
        final int achievedReps =
            er.setResults.fold(0, (s, r) => s + r.actualReps);
        final int possibleReps = er.targetReps * sets;
        completion = possibleReps > 0
            ? (achievedReps / possibleReps).clamp(0.0, 1.0)
            : 1.0;
        avgWeightThisSession =
            er.setResults.fold(0.0, (s, r) => s + r.weight) / sets;
        repsThisSession = achievedReps / sets;
        totalDuration += er.setResults.fold(0, (s, r) => s + r.durationSeconds);
        for (var setResult in er.setResults) {
          final estimated =
              calculate1RM(setResult.weight, setResult.actualReps);
          if (estimated > maxEstimated1RM) maxEstimated1RM = estimated;
        }
      }

      totalCompletion += completion;
      completionRates.add(completion);
      weights.add(avgWeightThisSession);
      totalWeight += avgWeightThisSession;
      totalReps += repsThisSession;
      lastPerceived = er.perceivedDifficulty ?? lastPerceived;
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
      weightTrend = firstHalf - secondHalf;
    }

    double performanceTrend = 0.0;
    if (completionRates.length >= 2 && weights.length >= 2) {
      final firstPerf = (completionRates[0] * weights[0]);
      final lastPerf = (completionRates.last * weights.last);
      performanceTrend = firstPerf - lastPerf;
    }

    final daysSince = sessionDates.isNotEmpty
        ? DateTime.now().difference(sessionDates.first).inDays
        : 0;

    return ProgressMetrics(
      completionRate: (totalCompletion / count).clamp(0.0, 1.0),
      avgWeight: totalWeight / count,
      avgRepsPerSet: count == 0 ? 0.0 : (totalReps / count),
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
    WellnessEntry? todayWellness,
  }) async {
    if (profile == null) {
      final ps = ProfileService();
      await ps.load();
      final goals = ps.goals
          .map((g) => TrainingGoal.values.firstWhere((e) => e.name == g,
              orElse: () => TrainingGoal.generalFitness))
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

    final trainingParams = _goalService.calculateFinalParameters(
      profile: prof,
      wellness: todayWellness,
    );

    final wellnessModifiers =
        _goalService.calculateWellnessModifiers(todayWellness);

    final adjustedExercises = <WorkoutExercise>[];
    final reasons = <String, String>{};

    final needsDeload = shouldDeload(histories);
    final userAge = prof.age ?? 30;

    for (var we in workout.exercises) {
      final metrics = analyzeExerciseHistory(
        we.exercise.id,
        histories,
        lookback: lookback,
        exerciseName: we.exercise.name,
      );

      double newWeight = we.weight;
      int newReps = we.targetReps;
      int newSets = we.sets;
      String reason = 'No history — using current parameters';

      if (metrics.sessionsCount == 0) {
        newReps = _goalService.calculateTargetReps(
          params: trainingParams,
          wellnessModifiers: wellnessModifiers,
        );
        newSets = _goalService.calculateTargetSets(
          params: trainingParams,
          wellnessModifiers: wellnessModifiers,
        );
        reason = 'New exercise - parameters tailored to your goals';
      } else {
        final c = metrics.completionRate;
        final perceived = metrics.lastPerceivedDifficulty;
        final wasHard = perceived == ExerciseDifficulty.hard;

        final recoveryModifier = getRecoveryModifier(
          metrics.daysSinceLastSession,
          userAge,
          gender: prof.gender?.name,
        );

        if (needsDeload) {
          if (we.weight > 0) {
            newWeight = we.weight * 0.70 * wellnessModifiers.weightMultiplier;
          }
          newSets = (we.sets * 0.75 * wellnessModifiers.volumeMultiplier)
              .round()
              .clamp(1, we.sets);
          newReps = (we.targetReps * 0.9).round().clamp(1, we.targetReps);
          reason = 'Week deload - reducing intensity for recovery';
        } else if (we.weight <= 0.0) {
          if (c >= 0.95 && metrics.avgRepsPerSet >= we.targetReps) {
            final actualReps = metrics.avgRepsPerSet > 0
                ? metrics.avgRepsPerSet.round()
                : we.targetReps;
            newReps = _goalService.calculateTargetReps(
              params: trainingParams,
              wellnessModifiers: wellnessModifiers,
              previousReps: actualReps,
            );
            newReps = (newReps * 1.1).round().clamp(actualReps + 1, 50);
            reason = 'Excellent performance - increasing repetitions';
          } else if (c >= 0.85 && metrics.performanceTrend > 0) {
            newSets = (we.sets + 1).clamp(1, 10);
            reason = 'Good progress - adding a set';
          } else if (c < 0.70 || wasHard) {
            newReps = (we.targetReps * 0.85).round().clamp(1, we.targetReps);
            reason = 'Difficult performance - reducing repetitions';
          } else {
            reason = 'Bodyweight exercise - maintaining level';
          }
        } else {
          newWeight = _goalService.calculateNextWeight(
            currentWeight: we.weight,
            completionRate: c,
            params: trainingParams,
            wellnessModifiers: wellnessModifiers,
            wasHard: wasHard,
          );

          if (newWeight > we.weight) {
            final focusMultiplier = _getTrainingFocusMultiplier(we, prof);
            final increase = newWeight - we.weight;
            newWeight = we.weight + increase * focusMultiplier;
          }

          if (metrics.weightTrend > 0 &&
              c >= 0.85 &&
              !wasHard &&
              newWeight > we.weight) {
            final momentumBonus =
                (metrics.weightTrend / we.weight).clamp(0.0, 0.02);
            newWeight *= (1.0 + momentumBonus);
          }

          final actualReps = metrics.avgRepsPerSet > 0
              ? metrics.avgRepsPerSet.round()
              : we.targetReps;
          newReps = _goalService.calculateTargetReps(
            params: trainingParams,
            wellnessModifiers: wellnessModifiers,
            previousReps: actualReps,
          );

          int baseSets = we.sets;
          if (c >= 0.95 && !wasHard && baseSets < trainingParams.targetSets) {
            baseSets += 1;
          } else if (c < 0.70 || wasHard) {
            baseSets = (baseSets - 1).clamp(1, baseSets);
          }
          newSets = (baseSets * wellnessModifiers.volumeMultiplier)
              .round()
              .clamp(1, 10);

          if (recoveryModifier < 0.95) {
            newWeight *= recoveryModifier;
            reason = 'Insufficient recovery - weight adjusted down';
          } else if (c >= 0.95 && !wasHard && metrics.performanceTrend >= 0) {
            reason =
                'Excellent performance - weight progression by ${((newWeight - we.weight) / we.weight * 100).toStringAsFixed(1)}%';
          } else if (c >= 0.85) {
            reason = 'Stable progress - moderate load increase';
          } else if (c < 0.75 || wasHard) {
            reason = 'Difficult workout - reducing intensity';
          } else if (metrics.performanceTrend < -5.0) {
            reason = 'Negative trend - adjusting load for recovery';
          } else {
            reason = 'Maintaining current level considering your goals';
          }

          if (wellnessModifiers.weightMultiplier < 0.9) {
            reason += ' (Considering wellness)';
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

  double _getTrainingFocusMultiplier(WorkoutExercise we, UserProfile prof) {
    if (prof.trainingFocus.isEmpty) return 1.0;

    final focusSet = prof.trainingFocus.map((s) => s.toLowerCase()).toSet();

    final expandedFocus = <String>{};
    for (final f in focusSet) {
      switch (f) {
        case 'arms':
        case 'руки':
          expandedFocus.addAll(['biceps', 'triceps', 'forearms', 'wrists']);
          break;
        case 'upper body':
        case 'верх тела':
          expandedFocus
              .addAll(['chest', 'back', 'shoulders', 'biceps', 'triceps']);
          break;
        case 'legs':
        case 'ноги':
          expandedFocus.addAll(['legs', 'glutes', 'calves']);
          break;
        default:
          expandedFocus.add(f);
      }
    }

    double multiplier = 1.0;

    for (final mg in we.exercise.muscleGroups) {
      if (expandedFocus.contains(mg.group.name.toLowerCase())) {
        final bonus = switch (mg.intensity) {
          MuscleGroupIntensity.primary => 0.30,
          MuscleGroupIntensity.secondary => 0.15,
          MuscleGroupIntensity.stabilizer => 0.05,
        };
        if (1.0 + bonus > multiplier) multiplier = 1.0 + bonus;
      }
    }

    return multiplier;
  }

  Future<void> applyProgressionToProgram(String workoutId) async {
    final dataManager = DataManager();
    final workout = dataManager.getWorkoutById(workoutId);
    if (workout == null) {
      debugPrint('[PROGRESSION] Workout not found: $workoutId');
      return;
    }

    final histories = dataManager.workoutHistory;

    final wellnessService = WellnessService();
    await wellnessService.load();
    final todayWellness = wellnessService.entries.isNotEmpty
        ? wellnessService.entries.last
        : null;

    final profileService = ProfileService();
    await profileService.load();

    final goals = profileService.goals
        .map((g) => TrainingGoal.values.firstWhere((e) => e.name == g,
            orElse: () => TrainingGoal.generalFitness))
        .toList();
    final experience = profileService.experienceLevel != null
        ? ExperienceLevel.values.firstWhere(
            (e) => e.name == profileService.experienceLevel,
            orElse: () => ExperienceLevel.intermediate)
        : ExperienceLevel.intermediate;
    final intensity = profileService.preferredIntensity != null
        ? TrainingIntensity.values.firstWhere(
            (e) => e.name == profileService.preferredIntensity,
            orElse: () => TrainingIntensity.moderate)
        : TrainingIntensity.moderate;

    final profile = UserProfile(
      goals: goals,
      experienceLevel: experience,
      trainingFocus: profileService.trainingFocus,
      preferredIntensity: intensity,
      age: profileService.age,
      weightKg: profileService.weightKg,
      yearsTraining: profileService.yearsTraining,
    );

    final result = await suggestNextWorkout(
      workout,
      histories,
      lookback: 5,
      profile: profile,
      todayWellness: todayWellness,
    );

    final updatedWorkout = result['workout'] as Workout;
    final reasons = result['reasons'] as Map<String, String>;

    dataManager.updateWorkoutById(workoutId, updatedWorkout);

    debugPrint('[PROGRESSION] Applied progression to program: ${workout.name}');
    for (var entry in reasons.entries) {
      debugPrint('[PROGRESSION]   ${entry.key}: ${entry.value}');
    }
  }
}
