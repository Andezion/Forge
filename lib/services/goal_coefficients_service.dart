import '../models/user.dart';
import '../models/wellness_entry.dart';

class TrainingParameters {
  final int minReps;
  final int maxReps;
  final int targetSets;
  final double weightIncreaseCoefficient;
  final double weightDecreaseCoefficient;
  final int restSeconds;

  const TrainingParameters({
    required this.minReps,
    required this.maxReps,
    required this.targetSets,
    required this.weightIncreaseCoefficient,
    required this.weightDecreaseCoefficient,
    required this.restSeconds,
  });
}

class WellnessModifiers {
  final double weightMultiplier;
  final double volumeMultiplier;
  final double recoveryMultiplier;

  const WellnessModifiers({
    required this.weightMultiplier,
    required this.volumeMultiplier,
    required this.recoveryMultiplier,
  });
}

class GoalCoefficientsService {
  TrainingParameters getParametersForGoal(TrainingGoal goal) {
    switch (goal) {
      case TrainingGoal.strength:
        return const TrainingParameters(
          minReps: 1,
          maxReps: 5,
          targetSets: 5,
          weightIncreaseCoefficient: 0.025,
          weightDecreaseCoefficient: 0.10,
          restSeconds: 180,
        );

      case TrainingGoal.hypertrophy:
        return const TrainingParameters(
          minReps: 8,
          maxReps: 12,
          targetSets: 4,
          weightIncreaseCoefficient: 0.05,
          weightDecreaseCoefficient: 0.10,
          restSeconds: 90,
        );

      case TrainingGoal.endurance:
        return const TrainingParameters(
          minReps: 15,
          maxReps: 25,
          targetSets: 3,
          weightIncreaseCoefficient: 0.05,
          weightDecreaseCoefficient: 0.075,
          restSeconds: 60,
        );

      case TrainingGoal.fatLoss:
        return const TrainingParameters(
          minReps: 12,
          maxReps: 20,
          targetSets: 3,
          weightIncreaseCoefficient: 0.05,
          weightDecreaseCoefficient: 0.075,
          restSeconds: 45,
        );

      case TrainingGoal.generalFitness:
        return const TrainingParameters(
          minReps: 8,
          maxReps: 15,
          targetSets: 3,
          weightIncreaseCoefficient: 0.05,
          weightDecreaseCoefficient: 0.075,
          restSeconds: 75,
        );
    }
  }

  TrainingParameters getAverageParameters(List<TrainingGoal> goals) {
    if (goals.isEmpty) {
      return getParametersForGoal(TrainingGoal.generalFitness);
    }

    if (goals.length == 1) {
      return getParametersForGoal(goals.first);
    }

    int totalMinReps = 0;
    int totalMaxReps = 0;
    int totalSets = 0;
    double totalIncrease = 0.0;
    double totalDecrease = 0.0;
    int totalRest = 0;

    for (var goal in goals) {
      final params = getParametersForGoal(goal);
      totalMinReps += params.minReps;
      totalMaxReps += params.maxReps;
      totalSets += params.targetSets;
      totalIncrease += params.weightIncreaseCoefficient;
      totalDecrease += params.weightDecreaseCoefficient;
      totalRest += params.restSeconds;
    }

    final count = goals.length;

    return TrainingParameters(
      minReps: (totalMinReps / count).round(),
      maxReps: (totalMaxReps / count).round(),
      targetSets: (totalSets / count).round().clamp(3, 5),
      weightIncreaseCoefficient: totalIncrease / count,
      weightDecreaseCoefficient: totalDecrease / count,
      restSeconds: (totalRest / count).round(),
    );
  }

  TrainingParameters applyExperienceModifiers(
    TrainingParameters params,
    ExperienceLevel experience,
  ) {
    switch (experience) {
      case ExperienceLevel.beginner:
        return TrainingParameters(
          minReps: params.minReps,
          maxReps: params.maxReps,
          targetSets: (params.targetSets * 0.75).round().clamp(2, 5),
          weightIncreaseCoefficient: params.weightIncreaseCoefficient * 1.5,
          weightDecreaseCoefficient: params.weightDecreaseCoefficient,
          restSeconds: (params.restSeconds * 1.2).round(),
        );

      case ExperienceLevel.intermediate:
        return params;

      case ExperienceLevel.advanced:
        return TrainingParameters(
          minReps: params.minReps,
          maxReps: params.maxReps,
          targetSets: (params.targetSets * 1.2).round().clamp(3, 6),
          weightIncreaseCoefficient: params.weightIncreaseCoefficient * 0.6,
          weightDecreaseCoefficient: params.weightDecreaseCoefficient * 0.8,
          restSeconds: params.restSeconds,
        );
    }
  }

  WellnessModifiers calculateWellnessModifiers(WellnessEntry? wellness) {
    if (wellness == null) {
      return const WellnessModifiers(
        weightMultiplier: 1.0,
        volumeMultiplier: 1.0,
        recoveryMultiplier: 1.0,
      );
    }

    final energy = wellness.answers['Energy'] ?? 3;
    final mood = wellness.answers['Mood'] ?? 3;
    final tiredness = wellness.answers['Tiredness'] ?? 3;
    final stress = wellness.answers['Stress'] ?? 3;
    final muscleSoreness = wellness.answers['Muscle soreness'] ?? 3;

    final readiness = ((energy +
                mood +
                (5 - tiredness) +
                (5 - stress) +
                (5 - muscleSoreness)) /
            25.0)
        .clamp(0.0, 1.0);

    double weightMult = 0.7 + (readiness * 0.4);
    double volumeMult = 0.75 + (readiness * 0.35);
    double recoveryMult = 0.8 + ((5 - tiredness) / 5.0) * 0.4;

    if (muscleSoreness >= 4) {
      weightMult *= 0.85;
      volumeMult *= 0.85;
      recoveryMult *= 1.3;
    }

    if (energy <= 2) {
      weightMult *= 0.85;
      volumeMult *= 0.90;
    }

    return WellnessModifiers(
      weightMultiplier: weightMult.clamp(0.7, 1.1),
      volumeMultiplier: volumeMult.clamp(0.7, 1.1),
      recoveryMultiplier: recoveryMult.clamp(0.8, 1.3),
    );
  }

  TrainingParameters applyIntensityModifiers(
    TrainingParameters params,
    TrainingIntensity intensity,
  ) {
    switch (intensity) {
      case TrainingIntensity.light:
        return TrainingParameters(
          minReps: params.minReps,
          maxReps: params.maxReps,
          targetSets: (params.targetSets * 0.8).round().clamp(2, 5),
          weightIncreaseCoefficient: params.weightIncreaseCoefficient * 0.7,
          weightDecreaseCoefficient: params.weightDecreaseCoefficient * 0.8,
          restSeconds: (params.restSeconds * 1.2).round(),
        );

      case TrainingIntensity.moderate:
        return params;

      case TrainingIntensity.intense:
        return TrainingParameters(
          minReps: params.minReps,
          maxReps: params.maxReps,
          targetSets: (params.targetSets * 1.2).round().clamp(3, 6),
          weightIncreaseCoefficient: params.weightIncreaseCoefficient * 1.3,
          weightDecreaseCoefficient: params.weightDecreaseCoefficient * 1.2,
          restSeconds: (params.restSeconds * 1.1).round(),
        );
    }
  }

  TrainingParameters calculateFinalParameters({
    required UserProfile profile,
    WellnessEntry? wellness,
  }) {
    var params = getAverageParameters(profile.goals);

    params = applyExperienceModifiers(params, profile.experienceLevel);
    params = applyIntensityModifiers(params, profile.preferredIntensity);

    return params;
  }

  int calculateTargetReps({
    required TrainingParameters params,
    required WellnessModifiers wellnessModifiers,
    int? previousReps,
  }) {
    int targetReps = ((params.minReps + params.maxReps) / 2).round();

    targetReps = (targetReps * wellnessModifiers.volumeMultiplier).round();

    return targetReps.clamp(params.minReps, params.maxReps);
  }

  int calculateTargetSets({
    required TrainingParameters params,
    required WellnessModifiers wellnessModifiers,
  }) {
    int targetSets = params.targetSets;

    targetSets = (targetSets * wellnessModifiers.volumeMultiplier).round();

    return targetSets.clamp(2, 6);
  }

  double calculateNextWeight({
    required double currentWeight,
    required double completionRate,
    required TrainingParameters params,
    required WellnessModifiers wellnessModifiers,
    bool wasHard = false,
  }) {
    double newWeight = currentWeight;

    if (completionRate >= 0.95 && !wasHard) {
      newWeight *= (1.0 + params.weightIncreaseCoefficient);
    } else if (completionRate >= 0.85 && completionRate < 0.95) {
      newWeight *= (1.0 + params.weightIncreaseCoefficient / 2);
    } else if (completionRate < 0.75 || wasHard) {
      newWeight *= (1.0 - params.weightDecreaseCoefficient);
    }

    newWeight *= wellnessModifiers.weightMultiplier;

    return (newWeight * 2).round() / 2.0;
  }
}
