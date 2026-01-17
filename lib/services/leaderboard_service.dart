import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../models/workout_history.dart';

class LeaderboardService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<void> syncUserStats({
    required List<WorkoutHistory> workoutHistory,
    required bool isProfileHidden,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final stats = _calculateStats(workoutHistory, userId, isProfileHidden);

      await _db.collection('user_stats').doc(userId).set(
            stats.toJson(),
            SetOptions(merge: true),
          );

      debugPrint('[LEADERBOARD] Stats synced for user $userId');
    } catch (e) {
      debugPrint('[LEADERBOARD] Error syncing stats: $e');
    }
  }

  UserStats _calculateStats(
    List<WorkoutHistory> workoutHistory,
    String userId,
    bool isProfileHidden,
  ) {
    final displayName = _auth.currentUser?.displayName ??
        _auth.currentUser?.email?.split('@').first ??
        'User';

    final workoutCount = workoutHistory.length;

    double totalWeight = 0;
    for (var history in workoutHistory) {
      for (var exerciseResult in history.session.exerciseResults) {
        for (var setResult in exerciseResult.setResults) {
          totalWeight += setResult.weight * setResult.actualReps;
        }
      }
    }

    int currentStreak = _calculateStreak(workoutHistory);

    final lastWorkout =
        workoutHistory.isNotEmpty ? workoutHistory.last.date : DateTime.now();

    final exerciseRecords = _calculateExerciseRecords(workoutHistory);

    final weeklyProgress = _calculateWeeklyProgress(workoutHistory);

    return UserStats(
      userId: userId,
      displayName: displayName,
      workoutCount: workoutCount,
      totalWeightLifted: totalWeight,
      currentStreak: currentStreak,
      lastWorkoutDate: lastWorkout,
      exerciseRecords: exerciseRecords,
      isProfileHidden: isProfileHidden,
      updatedAt: DateTime.now(),
      weeklyProgressPercentage: weeklyProgress,
    );
  }

  int _calculateStreak(List<WorkoutHistory> workoutHistory) {
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

  Map<String, double> _calculateExerciseRecords(
    List<WorkoutHistory> workoutHistory,
  ) {
    final records = <String, double>{};

    for (var history in workoutHistory) {
      for (var exerciseResult in history.session.exerciseResults) {
        final exerciseId = exerciseResult.exercise.id;
        double maxWeight = records[exerciseId] ?? 0.0;

        for (var setResult in exerciseResult.setResults) {
          if (setResult.weight > maxWeight) {
            maxWeight = setResult.weight;
          }
        }

        records[exerciseId] = maxWeight;
      }
    }

    return records;
  }

  Stream<List<UserStats>> getWorkoutCountLeaderboard({
    int limit = 100,
    String? scope,
  }) {
    var query = _db
        .collection('user_stats')
        .where('isProfileHidden', isEqualTo: false)
        .orderBy('workoutCount', descending: true)
        .limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return UserStats.fromJson(doc.data());
            } catch (e) {
              debugPrint('[LEADERBOARD] Error parsing user stats: $e');
              return null;
            }
          })
          .whereType<UserStats>()
          .toList();
    });
  }

  Stream<List<UserStats>> getTotalWeightLeaderboard({
    int limit = 100,
    String? scope,
  }) {
    var query = _db
        .collection('user_stats')
        .where('isProfileHidden', isEqualTo: false)
        .orderBy('totalWeightLifted', descending: true)
        .limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return UserStats.fromJson(doc.data());
            } catch (e) {
              debugPrint('[LEADERBOARD] Error parsing user stats: $e');
              return null;
            }
          })
          .whereType<UserStats>()
          .toList();
    });
  }

  Stream<List<UserStats>> getStreakLeaderboard({
    int limit = 100,
    String? scope,
  }) {
    var query = _db
        .collection('user_stats')
        .where('isProfileHidden', isEqualTo: false)
        .orderBy('currentStreak', descending: true)
        .limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return UserStats.fromJson(doc.data());
            } catch (e) {
              debugPrint('[LEADERBOARD] Error parsing user stats: $e');
              return null;
            }
          })
          .whereType<UserStats>()
          .toList();
    });
  }

  Stream<List<UserStats>> getExerciseRecordLeaderboard({
    required String exerciseId,
    int limit = 100,
    String? scope,
  }) {
    return _db
        .collection('user_stats')
        .where('isProfileHidden', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .map((doc) {
            try {
              return UserStats.fromJson(doc.data());
            } catch (e) {
              debugPrint('[LEADERBOARD] Error parsing user stats: $e');
              return null;
            }
          })
          .whereType<UserStats>()
          .where((user) => user.exerciseRecords.containsKey(exerciseId))
          .toList();

      users.sort((a, b) {
        final aRecord = a.exerciseRecords[exerciseId] ?? 0.0;
        final bRecord = b.exerciseRecords[exerciseId] ?? 0.0;
        return bRecord.compareTo(aRecord);
      });

      return users.take(limit).toList();
    });
  }

  Future<UserStats?> getCurrentUserStats() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final doc = await _db.collection('user_stats').doc(userId).get();
      if (doc.exists) {
        return UserStats.fromJson(doc.data()!);
      }
    } catch (e) {
      debugPrint('[LEADERBOARD] Error fetching current user stats: $e');
    }
    return null;
  }

  Stream<List<UserStats>> getProgressLeaderboard({
    int limit = 100,
    String? scope,
  }) {
    return _db
        .collection('user_stats')
        .where('isProfileHidden', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .map((doc) {
            try {
              return UserStats.fromJson(doc.data());
            } catch (e) {
              debugPrint('[LEADERBOARD] Error parsing user stats: $e');
              return null;
            }
          })
          .whereType<UserStats>()
          .where((user) => user.weeklyProgressPercentage > 0)
          .toList();

      users.sort((a, b) =>
          b.weeklyProgressPercentage.compareTo(a.weeklyProgressPercentage));

      return users.take(limit).toList();
    });
  }

  double _calculateWeeklyProgress(List<WorkoutHistory> workoutHistory) {
    if (workoutHistory.isEmpty) return 0.0;

    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    double currentWeekWeight = 0;
    for (var history in workoutHistory) {
      if (history.date.isAfter(oneWeekAgo)) {
        for (var exerciseResult in history.session.exerciseResults) {
          for (var setResult in exerciseResult.setResults) {
            currentWeekWeight += setResult.weight * setResult.actualReps;
          }
        }
      }
    }

    double previousWeekWeight = 0;
    for (var history in workoutHistory) {
      if (history.date.isAfter(twoWeeksAgo) &&
          history.date.isBefore(oneWeekAgo)) {
        for (var exerciseResult in history.session.exerciseResults) {
          for (var setResult in exerciseResult.setResults) {
            previousWeekWeight += setResult.weight * setResult.actualReps;
          }
        }
      }
    }

    if (previousWeekWeight == 0) return 0.0;

    final progress =
        ((currentWeekWeight - previousWeekWeight) / previousWeekWeight) * 100;
    return progress.clamp(-100, 1000);
  }
}
