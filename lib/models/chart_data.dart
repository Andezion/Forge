class ChartDataPoint {
  final DateTime date;
  final double value;

  ChartDataPoint({
    required this.date,
    required this.value,
  });
}

class ExerciseProgressData {
  final String exerciseId;
  final String exerciseName;
  final List<ChartDataPoint> maxWeightData;
  final List<ChartDataPoint> volumeData;
  final List<ChartDataPoint> intensityData;
  final double currentMax;
  final double previousMax;
  final double progressPercentage;

  ExerciseProgressData({
    required this.exerciseId,
    required this.exerciseName,
    required this.maxWeightData,
    required this.volumeData,
    required this.intensityData,
    required this.currentMax,
    required this.previousMax,
    required this.progressPercentage,
  });
}

class BodyWeightData {
  final List<ChartDataPoint> weightData;
  final double currentWeight;
  final double startWeight;
  final double weightChange;
  final double averageWeight;

  BodyWeightData({
    required this.weightData,
    required this.currentWeight,
    required this.startWeight,
    required this.weightChange,
    required this.averageWeight,
  });
}

class OverallStrengthData {
  final List<ChartDataPoint> totalStrengthData;
  final List<ChartDataPoint> averageStrengthData;
  final double currentTotalStrength;
  final double previousTotalStrength;
  final double progressPercentage;
  final Map<String, double> exerciseContributions;

  OverallStrengthData({
    required this.totalStrengthData,
    required this.averageStrengthData,
    required this.currentTotalStrength,
    required this.previousTotalStrength,
    required this.progressPercentage,
    required this.exerciseContributions,
  });
}

class WorkoutVolumeData {
  final List<ChartDataPoint> weeklyVolumeData;
  final List<ChartDataPoint> dailyVolumeData;
  final double totalPeriodVolume;
  final double currentWeekVolume;
  final double previousWeekVolume;
  final double averageVolume;

  WorkoutVolumeData({
    required this.weeklyVolumeData,
    required this.dailyVolumeData,
    required this.totalPeriodVolume,
    required this.currentWeekVolume,
    required this.previousWeekVolume,
    required this.averageVolume,
  });
}

class WorkoutFrequencyData {
  final List<ChartDataPoint> weeklyFrequencyData;
  final double currentWeekFrequency;
  final double averageFrequency;
  final int totalWorkouts;
  final int currentStreak;

  WorkoutFrequencyData({
    required this.weeklyFrequencyData,
    required this.currentWeekFrequency,
    required this.averageFrequency,
    required this.totalWorkouts,
    required this.currentStreak,
  });
}

class ConsistencyData {
  final List<ChartDataPoint> completionRateData;
  final double overallCompletionRate;
  final int totalSetsCompleted;
  final int totalSetsPlanned;

  ConsistencyData({
    required this.completionRateData,
    required this.overallCompletionRate,
    required this.totalSetsCompleted,
    required this.totalSetsPlanned,
  });
}
