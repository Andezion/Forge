import '../models/exercise.dart';
import '../models/workout_history.dart';

class MuscleRecoveryTracker {
  static const Map<MuscleGroup, int> _optimalRecoveryDays = {
    MuscleGroup.legs: 3,
    MuscleGroup.back: 3,
    MuscleGroup.chest: 2,
    MuscleGroup.shoulders: 2,
    MuscleGroup.glutes: 3,
    MuscleGroup.biceps: 2,
    MuscleGroup.triceps: 2,
    MuscleGroup.forearms: 1,
    MuscleGroup.wrists: 1,
    MuscleGroup.core: 1,
    MuscleGroup.calves: 2,
    MuscleGroup.cardio: 1,
  };

  Map<MuscleGroup, int> calculateDaysSinceLastTraining(
      List<WorkoutHistory> histories,
      {Map<String, Exercise>? currentExercises}) {
    final result = <MuscleGroup, int>{};
    final now = DateTime.now();

    for (var group in MuscleGroup.values) {
      result[group] = 14;
    }

    if (histories.isEmpty) {
      return result;
    }

    final lastTrainingDates = <MuscleGroup, DateTime>{};

    for (var history in histories.reversed) {
      final session = history.session;

      for (var exerciseResult in session.exerciseResults) {
        final exercise = exerciseResult.exercise;

        var muscleGroups = exercise.muscleGroups;
        if (muscleGroups.isEmpty && currentExercises != null) {
          final currentExercise = currentExercises[exercise.id];
          if (currentExercise != null) {
            muscleGroups = currentExercise.muscleGroups;
          }
        }

        for (var muscleTag in muscleGroups) {
          final group = muscleTag.group;

          if (!lastTrainingDates.containsKey(group)) {
            lastTrainingDates[group] = history.date;
          }
        }
      }
    }

    for (var entry in lastTrainingDates.entries) {
      final daysSince = now.difference(entry.value).inDays;
      result[entry.key] = daysSince;
    }

    return result;
  }

  Map<MuscleGroup, double> calculateRecoveryPriority(
      Map<MuscleGroup, int> daysSinceTraining) {
    final result = <MuscleGroup, double>{};

    for (var entry in daysSinceTraining.entries) {
      final group = entry.key;
      final daysSince = entry.value;
      final optimalDays = _optimalRecoveryDays[group] ?? 2;

      if (daysSince < optimalDays) {
        result[group] = (daysSince / optimalDays) * 0.3;
      } else if (daysSince == optimalDays) {
        result[group] = 0.7;
      } else if (daysSince < optimalDays * 2) {
        final excess = daysSince - optimalDays;
        result[group] = 0.7 + (excess / optimalDays) * 0.3;
      } else {
        result[group] =
            1.0 + ((daysSince - optimalDays * 2) / 7.0).clamp(0, 0.5);
      }
    }

    return result;
  }

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
      final weight = muscleTag.score;

      totalPriority += priority * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? totalPriority / totalWeight : 0.5;
  }

  Map<MuscleGroup, String> getRecoveryRecommendations(
      Map<MuscleGroup, int> daysSinceTraining) {
    final result = <MuscleGroup, String>{};

    for (var entry in daysSinceTraining.entries) {
      final group = entry.key;
      final daysSince = entry.value;
      final optimalDays = _optimalRecoveryDays[group] ?? 2;

      if (daysSince >= 10) {
        result[group] = 'Really need to train!';
      } else if (daysSince >= 7) {
        result[group] = 'Definitely time to train';
      } else if (daysSince < 1) {
        result[group] = 'Trained today - rest';
      } else if (daysSince < optimalDays) {
        result[group] = 'Recovery ($daysSince/$optimalDays days)';
      } else if (daysSince == optimalDays) {
        result[group] = 'Ready to train';
      } else if (daysSince < optimalDays * 2) {
        result[group] = 'Good time to train';
      } else {
        result[group] = 'Long time no train ($daysSince days)';
      }
    }

    return result;
  }

  List<MuscleGroup> getMusclesToTrain(
      Map<MuscleGroup, double> recoveryPriorities) {
    return recoveryPriorities.entries
        .where((e) => e.value >= 0.7)
        .map((e) => e.key)
        .toList()
      ..sort(
          (a, b) => recoveryPriorities[b]!.compareTo(recoveryPriorities[a]!));
  }

  List<MuscleGroup> getMusclesToRest(
      Map<MuscleGroup, double> recoveryPriorities) {
    return recoveryPriorities.entries
        .where((e) => e.value < 0.3)
        .map((e) => e.key)
        .toList()
      ..sort(
          (a, b) => recoveryPriorities[a]!.compareTo(recoveryPriorities[b]!));
  }

  bool isSafeToTrain(MuscleGroup group, int daysSinceTraining) {
    final optimalDays = _optimalRecoveryDays[group] ?? 2;
    return daysSinceTraining >= optimalDays;
  }

  static String getMuscleGroupDisplayName(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.legs:
        return 'Legs';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.wrists:
        return 'Wrists';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.cardio:
        return 'Cardio';
    }
  }
}
