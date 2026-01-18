import '../models/exercise.dart';
import '../models/workout_history.dart';

/// Отслеживает восстановление каждой группы мышц
class MuscleRecoveryTracker {
  /// Оптимальные периоды восстановления для каждой группы мышц (в днях)
  static const Map<MuscleGroup, int> _optimalRecoveryDays = {
    MuscleGroup.legs: 3, // Большие мышцы - дольше восстанавливаются
    MuscleGroup.back: 3, // Большие мышцы
    MuscleGroup.chest: 2, // Средние мышцы
    MuscleGroup.shoulders: 2, // Средние мышцы
    MuscleGroup.glutes: 3, // Большие мышцы
    MuscleGroup.biceps: 2, // Малые мышцы
    MuscleGroup.triceps: 2, // Малые мышцы
    MuscleGroup.forearms: 1, // Малые мышцы, быстрое восстановление
    MuscleGroup.wrists: 1, // Малые мышцы
    MuscleGroup.core: 1, // Можно тренировать часто
    MuscleGroup.calves: 2, // Средние мышцы
    MuscleGroup.cardio: 1, // Можно каждый день
  };

  /// Рассчитывает количество дней отдыха для каждой группы мышц
  Map<MuscleGroup, int> calculateDaysSinceLastTraining(
      List<WorkoutHistory> histories) {
    final result = <MuscleGroup, int>{};
    final now = DateTime.now();

    // Инициализируем все группы мышц большим значением
    for (var group in MuscleGroup.values) {
      result[group] = 999; // Никогда не тренировали
    }

    if (histories.isEmpty) {
      return result;
    }

    // Создаем карту: группа мышц -> последняя дата тренировки
    final lastTrainingDates = <MuscleGroup, DateTime>{};

    // Проходим по истории тренировок (от новых к старым)
    for (var history in histories.reversed) {
      final session = history.session;

      // Проходим по всем упражнениям в тренировке
      for (var exerciseResult in session.exerciseResults) {
        final exercise = exerciseResult.exercise;

        // Проходим по всем группам мышц в упражнении
        for (var muscleTag in exercise.muscleGroups) {
          final group = muscleTag.group;

          // Если это первая встреча с этой группой мышц, сохраняем дату
          if (!lastTrainingDates.containsKey(group)) {
            lastTrainingDates[group] = history.date;
          }
        }
      }
    }

    // Рассчитываем количество дней для каждой группы
    for (var entry in lastTrainingDates.entries) {
      final daysSince = now.difference(entry.value).inDays;
      result[entry.key] = daysSince;
    }

    return result;
  }

  /// Рассчитывает приоритет восстановления для каждой группы мышц (0.0 - 1.0)
  /// 1.0 = нужна срочная тренировка (давно не тренировали)
  /// 0.0 = недавно тренировали, нужен отдых
  Map<MuscleGroup, double> calculateRecoveryPriority(
      Map<MuscleGroup, int> daysSinceTraining) {
    final result = <MuscleGroup, double>{};

    for (var entry in daysSinceTraining.entries) {
      final group = entry.key;
      final daysSince = entry.value;
      final optimalDays = _optimalRecoveryDays[group] ?? 2;

      // Формула приоритета:
      // - Если прошло меньше оптимального времени -> низкий приоритет (нужен отдых)
      // - Если прошло больше оптимального -> высокий приоритет (пора тренировать)
      // - Если прошло намного больше -> очень высокий приоритет

      if (daysSince < optimalDays) {
        // Недостаточно отдыха: 0.0 - 0.3
        result[group] = (daysSince / optimalDays) * 0.3;
      } else if (daysSince == optimalDays) {
        // Оптимальное время: 0.7
        result[group] = 0.7;
      } else if (daysSince < optimalDays * 2) {
        // Хорошее время для тренировки: 0.7 - 1.0
        final excess = daysSince - optimalDays;
        result[group] = 0.7 + (excess / optimalDays) * 0.3;
      } else {
        // Слишком долго не тренировали: 1.0+
        result[group] =
            1.0 + ((daysSince - optimalDays * 2) / 7.0).clamp(0, 0.5);
      }
    }

    return result;
  }

  /// Рассчитывает общую оценку приоритета для тренировки на основе групп мышц
  double calculateWorkoutPriority(
    List<MuscleGroupTag> muscleGroups,
    Map<MuscleGroup, double> recoveryPriorities,
  ) {
    if (muscleGroups.isEmpty) return 0.5;

    double totalPriority = 0.0;
    int totalWeight = 0;

    for (var muscleTag in muscleGroups) {
      final group = muscleTag.group;
      final priority = recoveryPriorities[group] ?? 0.5;
      final weight =
          muscleTag.score; // 3 для primary, 2 для secondary, 1 для stabilizer

      totalPriority += priority * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? totalPriority / totalWeight : 0.5;
  }

  /// Возвращает рекомендации по тренировке групп мышц
  Map<MuscleGroup, String> getRecoveryRecommendations(
      Map<MuscleGroup, int> daysSinceTraining) {
    final result = <MuscleGroup, String>{};

    for (var entry in daysSinceTraining.entries) {
      final group = entry.key;
      final daysSince = entry.value;
      final optimalDays = _optimalRecoveryDays[group] ?? 2;

      if (daysSince >= 999) {
        result[group] = 'Никогда не тренировали';
      } else if (daysSince < 1) {
        result[group] = 'Тренировали сегодня - отдых';
      } else if (daysSince < optimalDays) {
        result[group] = 'Восстановление ($daysSince/$optimalDays дней)';
      } else if (daysSince == optimalDays) {
        result[group] = '✅ Готово к тренировке';
      } else if (daysSince < optimalDays * 2) {
        result[group] = '✅ Хорошее время для тренировки';
      } else {
        result[group] = '⚠️ Давно не тренировали ($daysSince дней)';
      }
    }

    return result;
  }

  /// Получает группы мышц, которые нуждаются в тренировке (priority > 0.7)
  List<MuscleGroup> getMusclesToTrain(
      Map<MuscleGroup, double> recoveryPriorities) {
    return recoveryPriorities.entries
        .where((e) => e.value >= 0.7)
        .map((e) => e.key)
        .toList()
      ..sort(
          (a, b) => recoveryPriorities[b]!.compareTo(recoveryPriorities[a]!));
  }

  /// Получает группы мышц, которым нужен отдых (priority < 0.3)
  List<MuscleGroup> getMusclesToRest(
      Map<MuscleGroup, double> recoveryPriorities) {
    return recoveryPriorities.entries
        .where((e) => e.value < 0.3)
        .map((e) => e.key)
        .toList()
      ..sort(
          (a, b) => recoveryPriorities[a]!.compareTo(recoveryPriorities[b]!));
  }

  /// Проверяет, безопасно ли тренировать эту группу мышц сегодня
  bool isSafeToTrain(MuscleGroup group, int daysSinceTraining) {
    final optimalDays = _optimalRecoveryDays[group] ?? 2;
    return daysSinceTraining >= optimalDays;
  }

  /// Получает человекочитаемое название группы мышц
  static String getMuscleGroupDisplayName(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return 'Грудь';
      case MuscleGroup.back:
        return 'Спина';
      case MuscleGroup.legs:
        return 'Ноги';
      case MuscleGroup.shoulders:
        return 'Плечи';
      case MuscleGroup.biceps:
        return 'Бицепс';
      case MuscleGroup.triceps:
        return 'Трицепс';
      case MuscleGroup.forearms:
        return 'Предплечья';
      case MuscleGroup.wrists:
        return 'Кисти';
      case MuscleGroup.core:
        return 'Пресс';
      case MuscleGroup.glutes:
        return 'Ягодицы';
      case MuscleGroup.calves:
        return 'Икры';
      case MuscleGroup.cardio:
        return 'Кардио';
    }
  }
}
