import '../l10n/l10n.dart';
import '../models/exercise.dart';

class MuscleGroupUtils {
  static String getLabel(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return L10n.current.muscleGroupChest;
      case MuscleGroup.back:
        return L10n.current.muscleGroupBack;
      case MuscleGroup.legs:
        return L10n.current.muscleGroupLegs;
      case MuscleGroup.shoulders:
        return L10n.current.muscleGroupShoulders;
      case MuscleGroup.biceps:
        return L10n.current.muscleGroupBiceps;
      case MuscleGroup.triceps:
        return L10n.current.muscleGroupTriceps;
      case MuscleGroup.forearms:
        return L10n.current.muscleGroupForearms;
      case MuscleGroup.wrists:
        return L10n.current.muscleGroupWrists;
      case MuscleGroup.core:
        return L10n.current.muscleGroupCore;
      case MuscleGroup.glutes:
        return L10n.current.muscleGroupGlutes;
      case MuscleGroup.calves:
        return L10n.current.muscleGroupCalves;
      case MuscleGroup.cardio:
        return L10n.current.muscleGroupCardio;
    }
  }

  static String getIntensityLabel(MuscleGroupIntensity intensity) {
    switch (intensity) {
      case MuscleGroupIntensity.primary:
        return L10n.current.intensityPrimary;
      case MuscleGroupIntensity.secondary:
        return L10n.current.intensitySecondary;
      case MuscleGroupIntensity.stabilizer:
        return L10n.current.intensityStabilizer;
    }
  }

  static List<MuscleGroup> getAllGroups() {
    return MuscleGroup.values;
  }

  static List<MuscleGroupIntensity> getAllIntensities() {
    return MuscleGroupIntensity.values;
  }
}
