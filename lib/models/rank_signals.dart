class RankSignals {
  final List<double> perExerciseRankPositions;
  final int workoutCount;
  final int currentStreak;
  final double totalWeightLifted;
  final int unlockedAchievementCount;
  final int totalAchievementCount;
  final double weeklyProgressPercentage;

  final double? avgPerformanceTrend;

  const RankSignals({
    required this.perExerciseRankPositions,
    required this.workoutCount,
    required this.currentStreak,
    required this.totalWeightLifted,
    required this.unlockedAchievementCount,
    required this.totalAchievementCount,
    required this.weeklyProgressPercentage,
    this.avgPerformanceTrend,
  });
}
