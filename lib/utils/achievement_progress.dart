import '../models/achievement.dart';
import '../models/workout_history.dart';
import '../services/progression_service.dart';
import 'strength_coefficients.dart';

class AchievementProgressInput {
  final List<WorkoutHistory> workoutHistory;
  final int friendsCount;
  final double bodyWeightKg;
  final bool isMale;
  final int challengeWinCount;
  final int completedChallengeCount;

  const AchievementProgressInput({
    required this.workoutHistory,
    required this.friendsCount,
    required this.bodyWeightKg,
    required this.isMale,
    required this.challengeWinCount,
    required this.completedChallengeCount,
  });
}

class AchievementProgress {
  static const _bigThreeNames = ['Squat', 'Bench Press', 'Deadlift'];

  static List<Achievement> calculateAll(AchievementProgressInput input) {
    final achievements = Achievements.getAll();
    final totalWorkouts = input.workoutHistory.length;

    double totalWeight = 0;
    for (final workout in input.workoutHistory) {
      for (final exercise in workout.session.exerciseResults) {
        for (final set in exercise.setResults) {
          if (set.weight > 0 && set.actualReps > 0) {
            totalWeight += set.weight * set.actualReps;
          }
        }
      }
    }

    final currentStreak = _calculateStreak(input.workoutHistory);
    final wilks = _bestWilksCoefficient(input);

    return achievements.map((achievement) {
      int progress = 0;
      bool isUnlocked = false;
      DateTime? unlockedAt;

      switch (achievement.id) {
        case 'first_workout':
        case 'workout_10':
        case 'workout_50':
        case 'workout_100':
        case 'workout_500':
          progress = totalWorkouts;
          isUnlocked = totalWorkouts >= achievement.requiredValue;
          if (isUnlocked && input.workoutHistory.isNotEmpty) {
            unlockedAt =
                input.workoutHistory.take(achievement.requiredValue).last.date;
          }
          break;

        case 'total_weight_1000':
        case 'total_weight_10000':
        case 'total_weight_100000':
          progress = totalWeight.toInt();
          isUnlocked = totalWeight >= achievement.requiredValue;
          if (isUnlocked && input.workoutHistory.isNotEmpty) {
            unlockedAt = input.workoutHistory.last.date;
          }
          break;

        case 'wilks_300':
        case 'wilks_400':
          progress = wilks.toInt();
          isUnlocked = wilks >= achievement.requiredValue;
          break;

        case 'streak_7':
        case 'streak_30':
        case 'streak_100':
          progress = currentStreak;
          isUnlocked = currentStreak >= achievement.requiredValue;
          break;

        case 'first_friend':
        case 'friends_10':
          progress = input.friendsCount;
          isUnlocked = progress >= achievement.requiredValue;
          break;

        case 'challenge_winner':
          progress = input.challengeWinCount;
          isUnlocked = input.challengeWinCount >= achievement.requiredValue;
          break;

        case 'challenge_5':
          progress = input.completedChallengeCount;
          isUnlocked =
              input.completedChallengeCount >= achievement.requiredValue;
          break;

        default:
          progress = 0;
      }

      return achievement.copyWith(
        currentProgress: progress,
        isUnlocked: isUnlocked,
        unlockedAt: unlockedAt,
      );
    }).toList();
  }

  static double _bestWilksCoefficient(AchievementProgressInput input) {
    if (input.bodyWeightKg <= 0) return 0.0;
    final progression = ProgressionService();
    final bestEstimated1RM = <String, double>{};

    for (final workout in input.workoutHistory) {
      for (final exercise in workout.session.exerciseResults) {
        if (!_bigThreeNames.contains(exercise.exercise.name)) continue;
        for (final set in exercise.setResults) {
          if (set.weight <= 0 || set.actualReps <= 0) continue;
          final e1rm = progression.calculate1RM(set.weight, set.actualReps);
          final name = exercise.exercise.name;
          if (!bestEstimated1RM.containsKey(name) ||
              e1rm > bestEstimated1RM[name]!) {
            bestEstimated1RM[name] = e1rm;
          }
        }
      }
    }

    if (bestEstimated1RM.isEmpty) return 0.0;
    final total = bestEstimated1RM.values.fold(0.0, (a, b) => a + b);
    return StrengthCoefficients.wilks(input.bodyWeightKg, total,
        isMale: input.isMale);
  }

  static int _calculateStreak(List<WorkoutHistory> workoutHistory) {
    if (workoutHistory.isEmpty) return 0;

    final sortedDates = workoutHistory
        .map((h) => DateTime(h.date.year, h.date.month, h.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime? lastDate;

    for (var date in sortedDates) {
      if (lastDate == null) {
        final daysDiff = DateTime.now().difference(date).inDays;
        if (daysDiff <= 1) {
          lastDate = date;
          streak = 1;
        } else {
          break;
        }
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

    return streak;
  }
}
