import '../models/exercise.dart';
import '../constants/app_strings.dart';

class MuscleGroupUtils {
  static String getLabel(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return AppStrings.muscleGroupChest;
      case MuscleGroup.back:
        return AppStrings.muscleGroupBack;
      case MuscleGroup.legs:
        return AppStrings.muscleGroupLegs;
      case MuscleGroup.shoulders:
        return AppStrings.muscleGroupShoulders;
      case MuscleGroup.biceps:
        return AppStrings.muscleGroupBiceps;
      case MuscleGroup.triceps:
        return AppStrings.muscleGroupTriceps;
      case MuscleGroup.forearms:
        return AppStrings.muscleGroupForearms;
      case MuscleGroup.wrists:
        return AppStrings.muscleGroupWrists;
      case MuscleGroup.core:
        return AppStrings.muscleGroupCore;
      case MuscleGroup.glutes:
        return AppStrings.muscleGroupGlutes;
      case MuscleGroup.calves:
        return AppStrings.muscleGroupCalves;
      case MuscleGroup.cardio:
        return AppStrings.muscleGroupCardio;
    }
  }

  static String getIntensityLabel(MuscleGroupIntensity intensity) {
    switch (intensity) {
      case MuscleGroupIntensity.primary:
        return AppStrings.intensityPrimary;
      case MuscleGroupIntensity.secondary:
        return AppStrings.intensitySecondary;
      case MuscleGroupIntensity.stabilizer:
        return AppStrings.intensityStabilizer;
    }
  }

  static String getDescription(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return 'Pectoral muscles';
      case MuscleGroup.back:
        return 'Back muscles including lats and traps';
      case MuscleGroup.legs:
        return 'Quadriceps and hamstrings';
      case MuscleGroup.shoulders:
        return 'Deltoid muscles';
      case MuscleGroup.biceps:
        return 'Front arm muscles';
      case MuscleGroup.triceps:
        return 'Back arm muscles';
      case MuscleGroup.forearms:
        return 'Lower arm muscles';
      case MuscleGroup.wrists:
        return 'Wrist flexors and extensors';
      case MuscleGroup.core:
        return 'Abdominal and lower back muscles';
      case MuscleGroup.glutes:
        return 'Gluteal muscles';
      case MuscleGroup.calves:
        return 'Lower leg muscles';
      case MuscleGroup.cardio:
        return 'Cardiovascular exercise';
    }
  }

  static List<MuscleGroup> getAllGroups() {
    return MuscleGroup.values;
  }

  static List<MuscleGroupIntensity> getAllIntensities() {
    return MuscleGroupIntensity.values;
  }
}
