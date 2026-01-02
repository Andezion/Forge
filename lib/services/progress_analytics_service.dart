import '../models/chart_data.dart';
import '../models/workout_history.dart';

class ProgressAnalyticsService {
  ExerciseProgressData analyzeExerciseProgress(
    String exerciseId,
    String exerciseName,
    List<WorkoutHistory> histories, {
    int lookbackDays = 90,
  }) {
    final cutoffDate = DateTime.now().subtract(Duration(days: lookbackDays));

    final relevantHistories = histories
        .where((h) => h.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final maxWeightPoints = <ChartDataPoint>[];
    final volumePoints = <ChartDataPoint>[];
    final intensityPoints = <ChartDataPoint>[];

    double currentMax = 0;
    double previousMax = 0;
    bool foundCurrent = false;

    for (var history in relevantHistories) {
      for (var exerciseResult in history.session.exerciseResults) {
        if (exerciseResult.exercise.id == exerciseId) {
          double maxWeight = 0;
          double totalVolume = 0;

          for (var set in exerciseResult.setResults) {
            if (set.weight > maxWeight) {
              maxWeight = set.weight;
            }
            totalVolume += set.weight * set.actualReps;
          }

          if (!foundCurrent && maxWeight > 0) {
            currentMax = maxWeight;
            foundCurrent = true;
          } else if (foundCurrent && previousMax == 0 && maxWeight > 0) {
            previousMax = maxWeight;
          }

          maxWeightPoints.add(ChartDataPoint(
            date: history.date,
            value: maxWeight,
          ));

          volumePoints.add(ChartDataPoint(
            date: history.date,
            value: totalVolume,
          ));

          if (exerciseResult.setResults.isNotEmpty && maxWeight > 0) {
            final avgWeight = exerciseResult.setResults
                    .map((s) => s.weight)
                    .reduce((a, b) => a + b) /
                exerciseResult.setResults.length;
            intensityPoints.add(ChartDataPoint(
              date: history.date,
              value: (avgWeight / maxWeight) * 100,
            ));
          }
        }
      }
    }

    double progressPercentage = 0;
    if (previousMax > 0) {
      progressPercentage = ((currentMax - previousMax) / previousMax) * 100;
    }

    return ExerciseProgressData(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      maxWeightData: maxWeightPoints,
      volumeData: volumePoints,
      intensityData: intensityPoints,
      currentMax: currentMax,
      previousMax: previousMax,
      progressPercentage: progressPercentage,
    );
  }

  BodyWeightData analyzeBodyWeight(
    List<WorkoutHistory> histories,
    double currentWeight, {
    int lookbackDays = 90,
  }) {
    final weightPoints = <ChartDataPoint>[];

    weightPoints.add(ChartDataPoint(
      date: DateTime.now(),
      value: currentWeight,
    ));

    final startWeight = currentWeight;
    final weightChange = 0.0;

    return BodyWeightData(
      weightData: weightPoints,
      currentWeight: currentWeight,
      startWeight: startWeight,
      weightChange: weightChange,
      averageWeight: currentWeight,
    );
  }

  OverallStrengthData analyzeOverallStrength(
    List<WorkoutHistory> histories, {
    int lookbackDays = 90,
  }) {
    final cutoffDate = DateTime.now().subtract(Duration(days: lookbackDays));

    final relevantHistories = histories
        .where((h) => h.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final totalStrengthPoints = <ChartDataPoint>[];
    final averageStrengthPoints = <ChartDataPoint>[];
    final exerciseMaxes = <String, double>{};

    for (var history in relevantHistories) {
      double sessionTotalStrength = 0;
      int exerciseCount = 0;

      for (var exerciseResult in history.session.exerciseResults) {
        double maxWeight = 0;
        for (var set in exerciseResult.setResults) {
          if (set.weight > maxWeight) {
            maxWeight = set.weight;
          }
        }

        if (maxWeight > 0) {
          sessionTotalStrength += maxWeight;
          exerciseCount++;

          final exerciseId = exerciseResult.exercise.id;
          if (!exerciseMaxes.containsKey(exerciseId) ||
              exerciseMaxes[exerciseId]! < maxWeight) {
            exerciseMaxes[exerciseId] = maxWeight;
          }
        }
      }

      if (sessionTotalStrength > 0) {
        totalStrengthPoints.add(ChartDataPoint(
          date: history.date,
          value: sessionTotalStrength,
        ));

        if (exerciseCount > 0) {
          averageStrengthPoints.add(ChartDataPoint(
            date: history.date,
            value: sessionTotalStrength / exerciseCount.toDouble(),
          ));
        }
      }
    }

    final currentTotal =
        totalStrengthPoints.isNotEmpty ? totalStrengthPoints.last.value : 0.0;

    double previousTotal = 0;
    if (totalStrengthPoints.length > 1) {
      previousTotal = totalStrengthPoints[totalStrengthPoints.length - 2].value;
    }

    final progressPercentage = previousTotal > 0
        ? ((currentTotal - previousTotal) / previousTotal) * 100.0
        : 0.0;

    final contributions = <String, double>{};
    for (var exerciseId in exerciseMaxes.keys) {
      for (var history in relevantHistories.reversed) {
        for (var result in history.session.exerciseResults) {
          if (result.exercise.id == exerciseId) {
            contributions[result.exercise.name] = exerciseMaxes[exerciseId]!;
            break;
          }
        }
        if (contributions.length == exerciseMaxes.length) break;
      }
    }

    return OverallStrengthData(
      totalStrengthData: totalStrengthPoints,
      averageStrengthData: averageStrengthPoints,
      currentTotalStrength: currentTotal,
      previousTotalStrength: previousTotal,
      progressPercentage: progressPercentage,
      exerciseContributions: contributions,
    );
  }

  WorkoutVolumeData analyzeWorkoutVolume(
    List<WorkoutHistory> histories, {
    int lookbackDays = 90,
  }) {
    final cutoffDate = DateTime.now().subtract(Duration(days: lookbackDays));

    final relevantHistories = histories
        .where((h) => h.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final dailyVolumePoints = <ChartDataPoint>[];
    final weeklyVolumes = <DateTime, double>{};

    for (var history in relevantHistories) {
      double dailyVolume = 0;

      for (var exerciseResult in history.session.exerciseResults) {
        for (var set in exerciseResult.setResults) {
          dailyVolume += set.weight * set.actualReps.toDouble();
        }
      }

      dailyVolumePoints.add(ChartDataPoint(
        date: history.date,
        value: dailyVolume,
      ));

      final weekStart = _getWeekStart(history.date);
      weeklyVolumes[weekStart] = (weeklyVolumes[weekStart] ?? 0) + dailyVolume;
    }

    final weeklyVolumePoints = weeklyVolumes.entries
        .map((e) => ChartDataPoint(date: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final currentWeek =
        weeklyVolumePoints.isNotEmpty ? weeklyVolumePoints.last.value : 0.0;
    final previousWeek = weeklyVolumePoints.length > 1
        ? weeklyVolumePoints[weeklyVolumePoints.length - 2].value
        : 0.0;

    final averageVolume = weeklyVolumePoints.isNotEmpty
        ? weeklyVolumePoints.map((p) => p.value).reduce((a, b) => a + b) /
            weeklyVolumePoints.length.toDouble()
        : 0.0;

    return WorkoutVolumeData(
      weeklyVolumeData: weeklyVolumePoints,
      dailyVolumeData: dailyVolumePoints,
      currentWeekVolume: currentWeek,
      previousWeekVolume: previousWeek,
      averageVolume: averageVolume,
    );
  }

  WorkoutFrequencyData analyzeWorkoutFrequency(
    List<WorkoutHistory> histories, {
    int lookbackDays = 90,
  }) {
    final cutoffDate = DateTime.now().subtract(Duration(days: lookbackDays));

    final relevantHistories = histories
        .where((h) => h.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final weeklyFrequency = <DateTime, int>{};

    for (var history in relevantHistories) {
      final weekStart = _getWeekStart(history.date);
      weeklyFrequency[weekStart] = (weeklyFrequency[weekStart] ?? 0) + 1;
    }

    final weeklyFrequencyPoints = weeklyFrequency.entries
        .map((e) => ChartDataPoint(
              date: e.key,
              value: e.value.toDouble(),
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final currentWeekFreq = weeklyFrequencyPoints.isNotEmpty
        ? weeklyFrequencyPoints.last.value
        : 0.0;

    final averageFreq = weeklyFrequencyPoints.isNotEmpty
        ? weeklyFrequencyPoints.map((p) => p.value).reduce((a, b) => a + b) /
            weeklyFrequencyPoints.length.toDouble()
        : 0.0;

    int streak = 0;
    final sortedDates = relevantHistories
        .map((h) => h.dateOnly)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    DateTime? lastDate;
    for (var date in sortedDates) {
      if (lastDate == null) {
        lastDate = date;
        streak = 1;
      } else {
        final difference = lastDate.difference(date).inDays;
        if (difference <= 2) {
          streak++;
          lastDate = date;
        } else {
          break;
        }
      }
    }

    return WorkoutFrequencyData(
      weeklyFrequencyData: weeklyFrequencyPoints,
      currentWeekFrequency: currentWeekFreq,
      averageFrequency: averageFreq,
      totalWorkouts: relevantHistories.length,
      currentStreak: streak,
    );
  }

  ConsistencyData analyzeConsistency(
    List<WorkoutHistory> histories, {
    int lookbackDays = 90,
  }) {
    final cutoffDate = DateTime.now().subtract(Duration(days: lookbackDays));

    final relevantHistories = histories
        .where((h) => h.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final completionRatePoints = <ChartDataPoint>[];
    int totalCompleted = 0;
    int totalPlanned = 0;

    for (var history in relevantHistories) {
      int sessionCompleted = 0;
      int sessionPlanned = 0;

      for (var exerciseResult in history.session.exerciseResults) {
        sessionPlanned += exerciseResult.targetSets;
        sessionCompleted += exerciseResult.setResults.length;
      }

      totalCompleted += sessionCompleted;
      totalPlanned += sessionPlanned;

      if (sessionPlanned > 0) {
        completionRatePoints.add(ChartDataPoint(
          date: history.date,
          value:
              (sessionCompleted.toDouble() / sessionPlanned.toDouble()) * 100,
        ));
      }
    }

    final overallRate = totalPlanned > 0
        ? (totalCompleted.toDouble() / totalPlanned.toDouble()) * 100
        : 0.0;

    return ConsistencyData(
      completionRateData: completionRatePoints,
      overallCompletionRate: overallRate,
      totalSetsCompleted: totalCompleted,
      totalSetsPlanned: totalPlanned,
    );
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: weekday - 1));
  }
}
