import '../models/workout.dart';
import '../models/workout_history.dart';
import '../models/workout_session.dart';
import '../models/user.dart';
import '../models/exercise.dart';
import '../models/wellness_entry.dart';
import 'profile_service.dart';
import 'goal_coefficients_service.dart';

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

    // Получаем параметры тренировки на основе целей и опыта
    final trainingParams = _goalService.calculateFinalParameters(
      profile: prof,
      wellness: todayWellness,
    );

    // Получаем модификаторы wellness
    final wellnessModifiers =
        _goalService.calculateWellnessModifiers(todayWellness);

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
      String reason = 'Нет истории — используем текущие параметры';

      if (metrics.sessionsCount == 0) {
        // Нет истории - используем параметры на основе целей
        newReps = _goalService.calculateTargetReps(
          params: trainingParams,
          wellnessModifiers: wellnessModifiers,
        );
        newSets = _goalService.calculateTargetSets(
          params: trainingParams,
          wellnessModifiers: wellnessModifiers,
        );
        reason = 'Новое упражнение - параметры подобраны под ваши цели';
      } else {
        final c = metrics.completionRate;
        final perceived = metrics.lastPerceivedDifficulty;
        final wasHard = perceived == ExerciseDifficulty.hard;

        // Учитываем восстановление
        final recoveryModifier = getRecoveryModifier(
          metrics.daysSinceLastSession,
          userAge,
        );

        if (needsDeload) {
          // Неделя разгрузки
          if (we.weight > 0) {
            newWeight = we.weight * 0.70 * wellnessModifiers.weightMultiplier;
          }
          newSets = (we.sets * 0.75 * wellnessModifiers.volumeMultiplier)
              .round()
              .clamp(1, we.sets);
          newReps = (we.targetReps * 0.9).round().clamp(1, we.targetReps);
          reason =
              'Неделя разгрузки - снижение интенсивности для восстановления';
        } else if (we.weight <= 0.0) {
          // Упражнения с собственным весом
          if (c >= 0.95 && metrics.avgRepsPerSet >= we.targetReps) {
            newReps = _goalService.calculateTargetReps(
              params: trainingParams,
              wellnessModifiers: wellnessModifiers,
              previousReps: we.targetReps,
            );
            newReps = (newReps * 1.1).round().clamp(we.targetReps + 1, 50);
            reason = 'Отличное выполнение - увеличиваем повторения';
          } else if (c >= 0.85 && metrics.performanceTrend > 0) {
            newSets = _goalService.calculateTargetSets(
              params: trainingParams,
              wellnessModifiers: wellnessModifiers,
            );
            newSets = (newSets + 1).clamp(we.sets, 10);
            reason = 'Хороший прогресс - добавляем сет';
          } else if (c < 0.70 || wasHard) {
            newReps = (we.targetReps * 0.85).round().clamp(1, we.targetReps);
            reason = 'Сложное выполнение - снижаем повторения';
          } else {
            reason = 'Упражнение с весом тела - поддерживаем уровень';
          }
        } else {
          // Упражнения с весом
          newWeight = _goalService.calculateNextWeight(
            currentWeight: we.weight,
            completionRate: c,
            params: trainingParams,
            wellnessModifiers: wellnessModifiers,
            wasHard: wasHard,
          );

          // Корректируем повторения и сеты на основе целей
          newReps = _goalService.calculateTargetReps(
            params: trainingParams,
            wellnessModifiers: wellnessModifiers,
            previousReps: we.targetReps,
          );

          newSets = _goalService.calculateTargetSets(
            params: trainingParams,
            wellnessModifiers: wellnessModifiers,
          );

          // Применяем восстановление
          if (recoveryModifier < 0.95) {
            newWeight *= recoveryModifier;
            reason = 'Недостаточное восстановление - скорректирован вес';
          } else if (c >= 0.95 && !wasHard && metrics.performanceTrend >= 0) {
            reason =
                'Отличная производительность - прогрессия веса на ${((newWeight - we.weight) / we.weight * 100).toStringAsFixed(1)}%';
          } else if (c >= 0.85) {
            reason = 'Стабильный прогресс - умеренное увеличение нагрузки';
          } else if (c < 0.75 || wasHard) {
            reason = 'Сложная тренировка - снижение интенсивности';
          } else if (metrics.performanceTrend < -5.0) {
            reason = 'Негативный тренд - корректировка нагрузки';
          } else {
            reason = 'Поддержание текущего уровня с учетом ваших целей';
          }

          // Дополнительные корректировки на основе wellness
          if (wellnessModifiers.weightMultiplier < 0.9) {
            reason += ' (с учетом самочувствия)';
          }
        }
      }

      // Округляем вес
      newWeight = (newWeight * 2).round() / 2.0;

      // Ограничиваем значения
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
