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
  // weightTrend: regression slope in kg per session (positive = gaining weight)
  final double weightTrend;
  // performanceTrend: regression slope in reps per session (positive = gaining reps)
  final double performanceTrend;
  final double estimated1RM;
  final int daysSinceLastSession;
  // Most recent session's actual values — used as the base for next suggestion
  final double lastActualWeight;
  final double lastActualReps;

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
    this.lastActualWeight = 0.0,
    this.lastActualReps = 0.0,
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

  // Least-squares linear regression slope for a chronologically ordered series.
  double _linearSlope(List<double> values) {
    final n = values.length;
    if (n < 2) return 0.0;
    double xMean = (n - 1) / 2.0;
    double yMean = values.fold(0.0, (a, b) => a + b) / n;
    double num = 0.0, den = 0.0;
    for (var i = 0; i < n; i++) {
      final dx = i - xMean;
      num += dx * (values[i] - yMean);
      den += dx * dx;
    }
    return den == 0.0 ? 0.0 : num / den;
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

  /// Analyses an exercise over the last [lookbackDays] days.
  ///
  /// [weightTrend] and [performanceTrend] are now linear-regression slopes
  /// (kg/session and reps/session respectively), computed from actual data
  /// sorted chronologically oldest-first.
  ProgressMetrics analyzeExerciseHistory(
    String exerciseId,
    List<WorkoutHistory> histories, {
    int lookbackDays = 30,
    String? exerciseName,
  }) {
    final cutoff = DateTime.now().subtract(Duration(days: lookbackDays));

    // Collect matching sessions within the window, sorted oldest → newest.
    final sortedHistories = histories.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final sessions = <ExerciseResult>[];
    final sessionDates = <DateTime>[];

    for (var h in sortedHistories) {
      if (h.date.isBefore(cutoff)) continue;
      for (var er in h.session.exerciseResults) {
        final matchById = er.exercise.id == exerciseId;
        final matchByName = exerciseName != null &&
            er.exercise.name.toLowerCase() == exerciseName.toLowerCase();
        if (matchById || matchByName) {
          sessions.add(er);
          sessionDates.add(h.date);
        }
      }
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
        lastActualWeight: 0.0,
        lastActualReps: 0.0,
      );
    }

    double totalCompletion = 0.0;
    double totalWeight = 0.0;
    double totalReps = 0.0;
    int totalDuration = 0;
    ExerciseDifficulty? lastPerceived;

    final weightPerSession = <double>[];
    final repsPerSession = <double>[];
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
      weightPerSession.add(avgWeightThisSession);
      repsPerSession.add(repsThisSession);
      totalWeight += avgWeightThisSession;
      totalReps += repsThisSession;
      lastPerceived = er.perceivedDifficulty ?? lastPerceived;
    }

    final count = sessions.length;

    final weightSlope = _linearSlope(weightPerSession);
    final repsSlope = _linearSlope(repsPerSession);

    final daysSince = sessionDates.isNotEmpty
        ? DateTime.now().difference(sessionDates.last).inDays
        : 0;

    return ProgressMetrics(
      completionRate: (totalCompletion / count).clamp(0.0, 1.0),
      avgWeight: totalWeight / count,
      avgRepsPerSet: count == 0 ? 0.0 : (totalReps / count),
      sessionsCount: count,
      avgDurationSeconds: count == 0 ? 0 : (totalDuration ~/ count),
      lastPerceivedDifficulty: lastPerceived,
      weightTrend: weightSlope,
      performanceTrend: repsSlope,
      estimated1RM: maxEstimated1RM,
      daysSinceLastSession: daysSince,
      lastActualWeight: weightPerSession.last,
      lastActualReps: repsPerSession.last,
    );
  }

  Future<Map<String, dynamic>> suggestNextWorkout(
    Workout workout,
    List<WorkoutHistory> histories, {
    int lookbackDays = 30,
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
        lookbackDays: lookbackDays,
        exerciseName: we.exercise.name,
      );

      double newWeight = we.weight;
      int newReps = we.targetReps;
      int newSets = we.sets;
      String reason = 'No history — using programmed parameters';

      if (metrics.sessionsCount == 0) {
        final suggestedReps = _goalService.calculateTargetReps(
          params: trainingParams,
          wellnessModifiers: wellnessModifiers,
        );
        final suggestedSets = _goalService.calculateTargetSets(
          params: trainingParams,
          wellnessModifiers: wellnessModifiers,
        );
        newReps = suggestedReps > we.targetReps ? suggestedReps : we.targetReps;
        newSets = suggestedSets > we.sets ? suggestedSets : we.sets;
        reason = 'New exercise — parameters tailored to your goals';
      } else {
        final c = metrics.completionRate;
        final wasHard =
            metrics.lastPerceivedDifficulty == ExerciseDifficulty.hard;

        final recoveryModifier = getRecoveryModifier(
          metrics.daysSinceLastSession,
          userAge,
          gender: prof.gender?.name,
        );

        if (needsDeload) {
          // Deload relative to what the user actually lifted, not program weight.
          final deloadBase =
              metrics.lastActualWeight > 0 ? metrics.lastActualWeight : we.weight;
          newWeight = deloadBase * 0.90;
          newReps =
              metrics.lastActualReps > 0 ? metrics.lastActualReps.round() : we.targetReps;
          newSets = we.sets;
          reason = 'Deload week — recovering at 90% of your last weight';
        } else if (we.weight <= 0.0) {
          // Bodyweight exercise: drive reps from actual history.
          final lastReps = metrics.lastActualReps > 0
              ? metrics.lastActualReps.round()
              : we.targetReps;
          final repsSlope = metrics.performanceTrend.clamp(-2.0, 3.0);

          if (c >= 0.95 && !wasHard) {
            final increment = repsSlope >= 1.0
                ? repsSlope
                : 1.0; // at least +1 rep when excelling
            newReps = (lastReps + increment * wellnessModifiers.volumeMultiplier)
                .round()
                .clamp(1, 200);
            reason = 'Excellent performance — +${increment.toStringAsFixed(0)} rep target';
          } else if (c >= 0.85 && metrics.performanceTrend > 0) {
            newSets = (we.sets + 1).clamp(1, 10);
            newReps = lastReps;
            reason = 'Good progress — adding a set';
          } else if (c < 0.70 || wasHard) {
            newReps = lastReps;
            reason = 'Challenging workout — maintaining last session reps';
          } else {
            newReps = lastReps;
            reason = 'Bodyweight exercise — maintaining level';
          }
        } else {
          // Weighted exercise — core of the new algorithm.
          final lastWeight =
              metrics.lastActualWeight > 0 ? metrics.lastActualWeight : we.weight;
          final lastReps = metrics.lastActualReps > 0
              ? metrics.lastActualReps.round()
              : we.targetReps;

          double weightIncrement;
          int repsChange;

          final hasMeaningfulTrend = metrics.sessionsCount >= 3 &&
              metrics.weightTrend.abs() > 0.3;

          if (hasMeaningfulTrend) {
            final maxGainPerSession = (lastWeight * 0.10).clamp(0.5, 5.0);
            weightIncrement =
                metrics.weightTrend.clamp(-2.5, maxGainPerSession);
            repsChange = metrics.performanceTrend.clamp(-3.0, 3.0).round();
          } else {
            if (c >= 0.95 && !wasHard) {
              weightIncrement =
                  lastWeight * trainingParams.weightIncreaseCoefficient;
            } else if (c >= 0.85) {
              weightIncrement =
                  lastWeight * trainingParams.weightIncreaseCoefficient / 2;
            } else if (c < 0.75 || wasHard) {
              weightIncrement =
                  -lastWeight * trainingParams.weightDecreaseCoefficient;
            } else {
              weightIncrement = 0.0;
            }
            repsChange = 0;
          }

          if (weightIncrement > 0) {
            final focusMultiplier = _getTrainingFocusMultiplier(we, prof);
            weightIncrement *= focusMultiplier;
          }

          // Scale the increment by wellness and recovery — never reduce the
          // base (lastWeight), only dampen how much we add or subtract.
          weightIncrement *=
              wellnessModifiers.weightMultiplier * recoveryModifier;

          newWeight = lastWeight + weightIncrement;
          // Floor: never recommend going below what was actually lifted.
          if (newWeight < lastWeight) newWeight = lastWeight;

          newReps = (lastReps + repsChange * wellnessModifiers.volumeMultiplier)
              .round()
              .clamp(1, 200);

          // Sets: add one if consistently completing all reps without struggle.
          int baseSets = we.sets;
          if (c >= 0.95 && !wasHard && baseSets < trainingParams.targetSets) {
            baseSets += 1;
          }
          newSets = (baseSets * wellnessModifiers.volumeMultiplier)
              .round()
              .clamp(we.sets, 10);

          // Build reason string.
          if (needsDeload) {
            reason = 'Deload week — recovering at 90% of your last weight';
          } else if (wellnessModifiers.weightMultiplier < 0.9) {
            reason = 'Reduced load — wellness adjustment applied';
          } else if (recoveryModifier < 0.95) {
            reason = 'Limited recovery — maintaining last session weight';
          } else if (weightIncrement > 0.25) {
            reason =
                'Trending up — +${weightIncrement.toStringAsFixed(1)} kg based on your last month';
          } else if (weightIncrement < -0.25) {
            reason = 'Load reduced — easing off based on your recent trend';
          } else {
            reason = 'Stable — maintaining your last session weight';
          }

          if (wellnessModifiers.weightMultiplier < 0.9) {
            reason += ' (wellness considered)';
          }
        }
      }

      // Round weight to nearest 0.5 kg.
      newWeight = (newWeight * 2).round() / 2.0;
      if (newSets < we.sets) newSets = we.sets;

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
