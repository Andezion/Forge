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
  final double
      weightTrend; // Положительный = рост веса, отрицательный = снижение
  final double performanceTrend; // Общий тренд производительности
  final double estimated1RM; // Расчётный максимум на 1 повтор
  final int daysSinceLastSession; // Дней с последней тренировки

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
  /// Расчёт 1RM (One-Rep Max) по формуле Эпли
  /// 1RM = вес × (1 + повторения / 30)
  double calculate1RM(double weight, int reps) {
    if (weight <= 0 || reps <= 0) return 0.0;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30.0);
  }

  /// Расчёт веса для заданного количества повторений на основе 1RM
  double calculateWeightForReps(double oneRM, int targetReps) {
    if (oneRM <= 0 || targetReps <= 0) return 0.0;
    if (targetReps == 1) return oneRM;
    // Обратная формула: вес = 1RM / (1 + reps / 30)
    return oneRM / (1 + targetReps / 30.0);
  }

  /// Определение необходимости разгрузочной недели
  /// Возвращает true, если пользователь должен взять лёгкую неделю
  bool shouldDeload(
    List<WorkoutHistory> recentHistories, {
    int checkLastWorkouts = 6,
  }) {
    if (recentHistories.length < checkLastWorkouts) return false;

    // Считаем тяжёлые тренировки (воспринимаемая сложность = hard)
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

    // Если более 60% упражнений были тяжёлыми, нужна разгрузка
    if (totalExercises > 0 && (hardWorkouts / totalExercises) > 0.6) {
      return true;
    }

    return false;
  }

  /// Расчёт корректировки в зависимости от времени восстановления
  double getRecoveryModifier(int daysSinceLastWorkout, int userAge) {
    // Базовое оптимальное время восстановления: 2-3 дня
    const optimalRecoveryDays = 2.5;

    // Корректировка на возраст (старше = дольше восстановление)
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
      // Недостаточно восстановился - снизить нагрузку на 5-10%
      return 0.90 + (daysSinceLastWorkout / optimalWithAge) * 0.10;
    } else if (daysSinceLastWorkout > optimalWithAge * 2.5) {
      // Слишком долгий перерыв - снизить нагрузку на 10-20%
      final daysOver = daysSinceLastWorkout - (optimalWithAge * 2.5);
      final reduction =
          (daysOver / 7.0) * 0.05; // -5% за каждую неделю перерыва
      return (1.0 - reduction).clamp(0.80, 1.0);
    }

    return 1.0; // Оптимальное время восстановления
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

    // Для расчёта тренда
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

      // Расчёт максимального 1RM за все сессии
      for (var setResult in er.setResults) {
        final estimated = calculate1RM(setResult.weight, setResult.actualReps);
        if (estimated > maxEstimated1RM) {
          maxEstimated1RM = estimated;
        }
      }
    }

    final count = sessions.length;

    // Расчёт тренда веса (положительный = растёт, отрицательный = падает)
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

    // Расчёт тренда производительности (комбинация веса и completion rate)
    double performanceTrend = 0.0;
    if (completionRates.length >= 2 && weights.length >= 2) {
      final firstPerf = (completionRates[0] * weights[0]);
      final lastPerf = (completionRates.last * weights.last);
      performanceTrend = lastPerf - firstPerf;
    }

    // Дней с последней тренировки
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

    // Определяем, нужна ли разгрузочная неделя
    final needsDeload = shouldDeload(histories);

    // Возраст пользователя для расчёта восстановления
    final userAge = prof.age ?? 30; // По умолчанию 30 лет

    for (var we in workout.exercises) {
      final metrics =
          analyzeExerciseHistory(we.exercise.id, histories, lookback: lookback);
      double newWeight = we.weight;
      int newReps = we.targetReps;
      int newSets = we.sets;
      String reason = 'No history — keep prescription';

      if (metrics.sessionsCount == 0) {
        // Нет истории - используем начальные значения
        reason = 'No recent data — keep as is';
      } else {
        // Определяем базовые параметры прогрессии в зависимости от уровня
        double baseIncreasePct;
        double baseDecreasePct;
        switch (prof.experienceLevel) {
          case ExperienceLevel.beginner:
            baseIncreasePct = 0.05; // 5% для начинающих
            baseDecreasePct = 0.05;
            break;
          case ExperienceLevel.intermediate:
            baseIncreasePct = 0.025; // 2.5% для средних
            baseDecreasePct = 0.05;
            break;
          case ExperienceLevel.advanced:
            baseIncreasePct =
                0.0125; // 1.25% для продвинутых (медленная прогрессия)
            baseDecreasePct = 0.0375;
            break;
        }

        // Корректировка на интенсивность
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

        // Корректировка на восстановление
        final recoveryModifier = getRecoveryModifier(
          metrics.daysSinceLastSession,
          userAge,
        );

        // Итоговые факторы
        final increaseFactor =
            1.0 + (baseIncreasePct * intensityMultiplier * recoveryModifier);
        final decreaseFactor = 1.0 - (baseDecreasePct * intensityMultiplier);

        final c = metrics.completionRate;
        final perceived = metrics.lastPerceivedDifficulty;

        // Если нужна разгрузка - снижаем на 20-30%
        if (needsDeload) {
          if (we.weight > 0) {
            newWeight = we.weight * 0.70; // -30% от веса
          }
          newSets =
              (we.sets * 0.75).round().clamp(1, we.sets); // Меньше подходов
          reason = 'Deload week — reduce intensity for recovery';
        }
        // Упражнения с собственным весом (вес = 0)
        else if (we.weight <= 0.0) {
          if (c >= 0.95 && metrics.avgRepsPerSet >= we.targetReps) {
            // Прогрессия через увеличение повторений
            final add =
                prof.experienceLevel == ExperienceLevel.advanced ? 2 : 1;
            newReps = we.targetReps + add;
            reason = 'Bodyweight: excellent completion — +$add rep(s)';
          } else if (c >= 0.90 && metrics.performanceTrend > 0) {
            // Хорошая прогрессия - увеличиваем сеты
            newSets = we.sets + 1;
            reason = 'Bodyweight: good progress — +1 set';
          } else if (c < 0.70 || perceived == ExerciseDifficulty.hard) {
            // Слишком тяжело - снижаем повторения
            final sub =
                prof.experienceLevel == ExperienceLevel.beginner ? 1 : 2;
            newReps = (we.targetReps - sub).clamp(1, we.targetReps);
            reason = 'Bodyweight: struggling — -$sub rep(s)';
          } else {
            reason = 'Bodyweight: maintain current level';
          }
        }
        // Упражнения с весом
        else {
          // Отличная производительность - увеличиваем вес
          if (c >= 0.95 &&
              metrics.avgRepsPerSet >= we.targetReps &&
              perceived != ExerciseDifficulty.hard &&
              metrics.performanceTrend >= 0) {
            newWeight = we.weight * increaseFactor;

            // Если тренд очень хороший, можно добавить повторения
            if (metrics.performanceTrend > 5.0 && c >= 0.98) {
              newReps = we.targetReps + 1;
              reason = 'Excellent progress — increase weight & reps';
            } else {
              reason =
                  'Strong performance — increase weight by ${((increaseFactor - 1) * 100).toStringAsFixed(1)}%';
            }
          }
          // Хорошая производительность, но не идеальная
          else if (c >= 0.85 &&
              c < 0.95 &&
              perceived != ExerciseDifficulty.hard) {
            // Используем 1RM для более точной прогрессии
            if (metrics.estimated1RM > 0) {
              // Увеличиваем расчётный 1RM на небольшой процент
              final new1RM = metrics.estimated1RM * (1.0 + baseIncreasePct / 2);
              newWeight = calculateWeightForReps(new1RM, we.targetReps);
              reason = 'Good progress — calculated weight from estimated 1RM';
            } else {
              newWeight = we.weight * (1.0 + baseIncreasePct / 2);
              reason = 'Steady progress — small weight increase';
            }
          }
          // Плохая производительность - снижаем вес и/или повторения
          else if (c < 0.75 || perceived == ExerciseDifficulty.hard) {
            newWeight = we.weight * decreaseFactor;

            // Если совсем плохо - снижаем и повторения
            if (c < 0.60) {
              newReps = (we.targetReps - 2).clamp(1, we.targetReps);
              reason = 'Struggling significantly — reduce weight & reps';
            } else {
              newReps = (we.targetReps - 1).clamp(1, we.targetReps);
              reason = 'Hard workout — reduce weight & reps slightly';
            }
          }
          // Негативный тренд - пользователь регрессирует
          else if (metrics.performanceTrend < -5.0 && metrics.weightTrend < 0) {
            newWeight = we.weight * 0.90; // -10%
            reason = 'Negative trend detected — reduce intensity';
          }
          // Слишком долгое выполнение сетов
          else if (metrics.avgDurationSeconds > 120) {
            newWeight = we.weight * 0.95; // -5%
            reason = 'Sets taking too long — reduce weight for better form';
          }
          // Недостаточное восстановление
          else if (recoveryModifier < 0.95) {
            newWeight = we.weight * recoveryModifier;
            reason = 'Insufficient recovery time — adjusted for fatigue';
          }
          // Всё стабильно - оставляем как есть
          else {
            reason = 'Performance stable — maintain current prescription';
          }
        }
      }

      // Округляем вес до ближайших 0.5 кг
      newWeight = (newWeight * 2).round() / 2.0;

      // Ограничения безопасности
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
