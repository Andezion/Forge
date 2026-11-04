import 'package:flutter/material.dart';
import 'strength_rank.dart';

enum PersonalExercise { pushUps }

extension PersonalExerciseExt on PersonalExercise {
  IconData get icon {
    switch (this) {
      case PersonalExercise.pushUps:
        return Icons.fitness_center;
    }
  }
}

class PersonalChallenge {
  final PersonalExercise exercise;
  final int targetReps;
  final StrengthRank tier;

  const PersonalChallenge({
    required this.exercise,
    required this.targetReps,
    required this.tier,
  });

  String get id => '${exercise.name}_$targetReps';

  static const List<int> pushUpTargets = [10, 25, 50, 100, 250, 500, 1000];

  static List<PersonalChallenge> forExercise(PersonalExercise exercise) {
    const targets = pushUpTargets;
    return [
      for (var i = 0; i < targets.length; i++)
        PersonalChallenge(
          exercise: exercise,
          targetReps: targets[i],
          tier: StrengthRank.values[i],
        ),
    ];
  }
}
