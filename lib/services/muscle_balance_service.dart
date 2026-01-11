import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_history.dart';

/// Результат анализа мышечного баланса
class MuscleBalanceAnalysis {
  /// Счет нагрузки на каждую группу мышц
  final Map<MuscleGroup, double> muscleLoadScores;

  /// Группы мышц, которые перетренированы (нужен отдых)
  final Set<MuscleGroup> overtrainedGroups;

  /// Группы мышц, которые недотренированы (нужна нагрузка)
  final Set<MuscleGroup> undertrainedGroups;

  /// Общий баланс тренировки (0.0 - 1.0, где 1.0 - идеальный баланс)
  final double overallBalance;

  MuscleBalanceAnalysis({
    required this.muscleLoadScores,
    required this.overtrainedGroups,
    required this.undertrainedGroups,
    required this.overallBalance,
  });
}

/// Сервис для анализа нагрузки на мышечные группы и баланса тренировок
class MuscleBalanceService {
  /// Анализирует тренировку и возвращает счет нагрузки на каждую группу мышц
  Map<MuscleGroup, double> calculateWorkoutMuscleLoad(Workout workout) {
    final muscleLoad = <MuscleGroup, double>{};

    for (var workoutExercise in workout.exercises) {
      for (var tag in workoutExercise.exercise.muscleGroups) {
        final currentLoad = muscleLoad[tag.group] ?? 0.0;

        // Учитываем количество сетов и интенсивность воздействия
        final loadScore = tag.score * workoutExercise.sets.toDouble();
        muscleLoad[tag.group] = currentLoad + loadScore;
      }
    }

    return muscleLoad;
  }

  /// Анализирует историю тренировок за последние N дней
  /// и возвращает накопленную нагрузку на каждую группу мышц
  Map<MuscleGroup, double> calculateRecentMuscleLoad(
    List<WorkoutHistory> histories, {
    int daysToAnalyze = 7,
  }) {
    final muscleLoad = <MuscleGroup, double>{};
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToAnalyze));

    for (var history in histories) {
      if (history.date.isBefore(cutoffDate)) continue;

      // Вес нагрузки уменьшается со временем (свежие тренировки весят больше)
      final daysSince = DateTime.now().difference(history.date).inDays;
      final timeDecay = 1.0 - (daysSince / daysToAnalyze) * 0.5;

      for (var exerciseResult in history.session.exerciseResults) {
        for (var tag in exerciseResult.exercise.muscleGroups) {
          final currentLoad = muscleLoad[tag.group] ?? 0.0;

          // Учитываем фактически выполненные сеты
          final completedSets = exerciseResult.setResults.length;
          final loadScore = tag.score * completedSets * timeDecay;

          muscleLoad[tag.group] = currentLoad + loadScore;
        }
      }
    }

    return muscleLoad;
  }

  /// Полный анализ мышечного баланса на основе истории
  MuscleBalanceAnalysis analyzeMuscleBalance(
    List<WorkoutHistory> histories, {
    int daysToAnalyze = 7,
  }) {
    final muscleLoad = calculateRecentMuscleLoad(
      histories,
      daysToAnalyze: daysToAnalyze,
    );

    if (muscleLoad.isEmpty) {
      return MuscleBalanceAnalysis(
        muscleLoadScores: {},
        overtrainedGroups: {},
        undertrainedGroups: {},
        overallBalance: 1.0,
      );
    }

    // Находим среднюю нагрузку
    final avgLoad =
        muscleLoad.values.fold(0.0, (a, b) => a + b) / muscleLoad.values.length;

    // Определяем перетренированные группы (> 150% от средней нагрузки)
    final overtrained = muscleLoad.entries
        .where((e) => e.value > avgLoad * 1.5)
        .map((e) => e.key)
        .toSet();

    // Определяем недотренированные группы (< 50% от средней нагрузки)
    final undertrained = muscleLoad.entries
        .where((e) => e.value < avgLoad * 0.5 && e.value > 0)
        .map((e) => e.key)
        .toSet();

    // Рассчитываем общий баланс (насколько равномерно распределена нагрузка)
    double balance = 1.0;
    if (muscleLoad.isNotEmpty) {
      final maxLoad = muscleLoad.values.reduce((a, b) => a > b ? a : b);
      final minLoad = muscleLoad.values.reduce((a, b) => a < b ? a : b);

      if (maxLoad > 0) {
        balance = minLoad / maxLoad;
      }
    }

    return MuscleBalanceAnalysis(
      muscleLoadScores: muscleLoad,
      overtrainedGroups: overtrained,
      undertrainedGroups: undertrained,
      overallBalance: balance,
    );
  }

  /// Проверяет, совместима ли тренировка с текущим мышечным балансом
  /// Возвращает оценку совместимости (0.0 - 1.0, где 1.0 - идеально)
  double evaluateWorkoutCompatibility(
    Workout workout,
    MuscleBalanceAnalysis recentBalance,
  ) {
    final workoutLoad = calculateWorkoutMuscleLoad(workout);

    double compatibilityScore = 1.0;

    // Штрафуем, если тренировка нагружает перетренированные группы
    for (var group in recentBalance.overtrainedGroups) {
      if (workoutLoad.containsKey(group)) {
        final loadRatio = workoutLoad[group]! /
            (recentBalance.muscleLoadScores[group] ?? 1.0);
        compatibilityScore -= loadRatio * 0.3;
      }
    }

    // Бонус, если тренировка нагружает недотренированные группы
    for (var group in recentBalance.undertrainedGroups) {
      if (workoutLoad.containsKey(group)) {
        compatibilityScore += 0.2;
      }
    }

    return compatibilityScore.clamp(0.0, 1.0);
  }

  /// Возвращает приоритетные группы мышц на основе целей тренировок
  Map<MuscleGroup, double> getMuscleGroupPriorities(
    List<String> trainingFocus,
  ) {
    final priorities = <MuscleGroup, double>{};

    for (var focus in trainingFocus) {
      switch (focus.toLowerCase()) {
        case 'armwrestling':
        case 'армрестлинг':
          priorities[MuscleGroup.wrists] = 3.0;
          priorities[MuscleGroup.forearms] = 3.0;
          priorities[MuscleGroup.biceps] = 2.5;
          priorities[MuscleGroup.back] = 2.0;
          priorities[MuscleGroup.shoulders] = 2.0;
          break;

        case 'powerlifting':
        case 'пауэрлифтинг':
          priorities[MuscleGroup.legs] = 3.0;
          priorities[MuscleGroup.back] = 3.0;
          priorities[MuscleGroup.chest] = 2.5;
          priorities[MuscleGroup.core] = 2.0;
          break;

        case 'bodybuilding':
        case 'бодибилдинг':
          priorities[MuscleGroup.chest] = 2.5;
          priorities[MuscleGroup.back] = 2.5;
          priorities[MuscleGroup.legs] = 2.5;
          priorities[MuscleGroup.shoulders] = 2.0;
          priorities[MuscleGroup.biceps] = 2.0;
          priorities[MuscleGroup.triceps] = 2.0;
          break;

        case 'crossfit':
        case 'кроссфит':
          priorities[MuscleGroup.legs] = 2.5;
          priorities[MuscleGroup.core] = 2.5;
          priorities[MuscleGroup.shoulders] = 2.0;
          priorities[MuscleGroup.cardio] = 3.0;
          break;

        case 'strength':
        case 'сила':
          priorities[MuscleGroup.legs] = 2.5;
          priorities[MuscleGroup.back] = 2.5;
          priorities[MuscleGroup.chest] = 2.0;
          break;
      }
    }

    // Если нет специфичных приоритетов, все группы равны
    if (priorities.isEmpty) {
      for (var group in MuscleGroup.values) {
        priorities[group] = 1.0;
      }
    }

    return priorities;
  }

  /// Оценивает, насколько тренировка соответствует целям пользователя
  double evaluateWorkoutForGoals(
    Workout workout,
    List<String> trainingFocus,
  ) {
    final priorities = getMuscleGroupPriorities(trainingFocus);
    final workoutLoad = calculateWorkoutMuscleLoad(workout);

    if (priorities.isEmpty || workoutLoad.isEmpty) {
      return 0.5; // Нейтральная оценка
    }

    double totalScore = 0.0;
    double maxPossibleScore = 0.0;

    for (var entry in priorities.entries) {
      final priority = entry.value;
      final load = workoutLoad[entry.key] ?? 0.0;

      maxPossibleScore += priority * 10; // Максимальная нагрузка = 10
      totalScore += priority * load.clamp(0.0, 10.0);
    }

    return maxPossibleScore > 0
        ? (totalScore / maxPossibleScore).clamp(0.0, 1.0)
        : 0.5;
  }

  /// Предлагает какие группы мышц стоит тренировать следующими
  List<MuscleGroup> suggestNextMuscleGroups(
    List<WorkoutHistory> histories,
    List<String> trainingFocus, {
    int topN = 3,
  }) {
    final balance = analyzeMuscleBalance(histories);
    final priorities = getMuscleGroupPriorities(trainingFocus);

    // Создаем список групп с оценкой приоритета
    final scores = <MuscleGroup, double>{};

    for (var group in MuscleGroup.values) {
      double score = priorities[group] ?? 1.0;

      // Бонус для недотренированных групп
      if (balance.undertrainedGroups.contains(group)) {
        score *= 1.5;
      }

      // Штраф для перетренированных групп
      if (balance.overtrainedGroups.contains(group)) {
        score *= 0.3;
      }

      // Учитываем текущую нагрузку (меньше нагрузка = выше приоритет)
      final currentLoad = balance.muscleLoadScores[group] ?? 0.0;
      final avgLoad = balance.muscleLoadScores.values.isEmpty
          ? 1.0
          : balance.muscleLoadScores.values.fold(0.0, (a, b) => a + b) /
              balance.muscleLoadScores.values.length;

      if (avgLoad > 0) {
        final loadRatio = currentLoad / avgLoad;
        score *= (2.0 - loadRatio.clamp(0.0, 1.5));
      }

      scores[group] = score;
    }

    // Сортируем по убыванию оценки
    final sortedGroups = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedGroups.take(topN).map((e) => e.key).toList();
  }
}
