import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../models/workout_history.dart';


class LeaderboardService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<List<String>> getFriendIds() async {
    final userId = _currentUserId;
    if (userId == null) return [];
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();
      return snap.docs.map((d) => d.id).toList();
    } catch (e) {
      debugPrint('[LEADERBOARD] getFriendIds error: $e');
      return [];
    }
  }

  Future<void> syncUserStats({
    required List<WorkoutHistory> workoutHistory,
    required bool isProfileHidden,
    double? userBodyWeight,
    String? country,
    String? city,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final bodyWeight = userBodyWeight ?? 70.0;

      final stats = _calculateStats(
          workoutHistory, userId, isProfileHidden, bodyWeight,
          country: country, city: city);

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
    double userBodyWeight, {
    String? country,
    String? city,
  }) {
    final displayName = _auth.currentUser?.displayName ??
        _auth.currentUser?.email?.split('@').first ??
        'User';

    final workoutCount = workoutHistory.length;

    double totalWeight = 0;
    for (var history in workoutHistory) {
      for (var exerciseResult in history.session.exerciseResults) {
        for (var setResult in exerciseResult.setResults) {
          final effectiveWeight =
              setResult.weight > 0 ? setResult.weight : userBodyWeight;
          totalWeight += effectiveWeight * setResult.actualReps;
        }
      }
    }

    int currentStreak = _calculateStreak(workoutHistory);

    final lastWorkout =
        workoutHistory.isNotEmpty ? workoutHistory.last.date : DateTime.now();

    final exerciseRecords = _calculateExerciseRecords(workoutHistory);

    final weeklyProgress =
        _calculateWeeklyProgress(workoutHistory, userBodyWeight);

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
      country: country,
      city: city,
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

  // Builds a base query filtered by scope.
  // 'My League' requires an async pre-fetch of friend IDs, so it returns null
  // and callers handle that case with the separate _leagueStream helper.
  Query<Map<String, dynamic>>? _scopedQuery(
    String field, {
    required String scope,
    required String? userCountry,
    required String? userCity,
    required int limit,
  }) {
    var q = _db.collection('user_stats').where('isProfileHidden', isEqualTo: false);

    if (scope == 'Country' && userCountry != null) {
      q = q.where('country', isEqualTo: userCountry);
    } else if (scope == 'City' && userCity != null) {
      q = q.where('city', isEqualTo: userCity);
    }
    // 'Global' and 'My League' — 'My League' handled separately
    return q.orderBy(field, descending: true).limit(limit);
  }

  Stream<List<UserStats>> _leagueStream(
    String orderField, {
    required int limit,
  }) async* {
    final friendIds = await getFriendIds();
    final allIds = [...friendIds, if (_currentUserId != null) _currentUserId!];
    if (allIds.isEmpty) { yield []; return; }

    // Firestore whereIn supports max 30 items
    final ids = allIds.take(30).toList();
    yield* _db
        .collection('user_stats')
        .where('userId', whereIn: ids)
        .orderBy(orderField, descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs
            .map((d) {
              try { return UserStats.fromJson(d.data()); } catch (_) { return null; }
            })
            .whereType<UserStats>()
            .toList());
  }

  Stream<List<UserStats>> _buildStream(
    String orderField, {
    required String scope,
    required String? userCountry,
    required String? userCity,
    int limit = 100,
  }) {
    if (scope == 'My League') {
      return _leagueStream(orderField, limit: limit);
    }
    final query = _scopedQuery(
      orderField,
      scope: scope,
      userCountry: userCountry,
      userCity: userCity,
      limit: limit,
    )!;
    return query.snapshots().map((s) => s.docs
        .map((d) {
          try { return UserStats.fromJson(d.data()); } catch (_) { return null; }
        })
        .whereType<UserStats>()
        .toList());
  }

  Stream<List<UserStats>> getWorkoutCountLeaderboard({
    int limit = 100,
    String scope = 'Global',
    String? userCountry,
    String? userCity,
  }) => _buildStream('workoutCount',
      scope: scope, userCountry: userCountry, userCity: userCity, limit: limit);

  Stream<List<UserStats>> getTotalWeightLeaderboard({
    int limit = 100,
    String scope = 'Global',
    String? userCountry,
    String? userCity,
  }) => _buildStream('totalWeightLifted',
      scope: scope, userCountry: userCountry, userCity: userCity, limit: limit);

  Stream<List<UserStats>> getStreakLeaderboard({
    int limit = 100,
    String scope = 'Global',
    String? userCountry,
    String? userCity,
  }) => _buildStream('currentStreak',
      scope: scope, userCountry: userCountry, userCity: userCity, limit: limit);

  Stream<List<UserStats>> getExerciseRecordLeaderboard({
    required String exerciseId,
    int limit = 100,
    String scope = 'Global',
    String? userCountry,
    String? userCity,
  }) {
    if (scope == 'My League') {
      return _leagueStream('workoutCount', limit: limit * 2).map((users) {
        final filtered = users
            .where((u) => (u.exerciseRecords[exerciseId] ?? 0) > 0)
            .toList()
          ..sort((a, b) {
            final aR = a.exerciseRecords[exerciseId] ?? 0.0;
            final bR = b.exerciseRecords[exerciseId] ?? 0.0;
            return bR.compareTo(aR);
          });
        return filtered.take(limit).toList();
      });
    }

    var q = _db
        .collection('user_stats')
        .where('exerciseRecords.$exerciseId', isGreaterThan: 0);
    if (scope == 'Country' && userCountry != null) {
      q = q.where('country', isEqualTo: userCountry);
    } else if (scope == 'City' && userCity != null) {
      q = q.where('city', isEqualTo: userCity);
    }

    return q.limit(limit * 2).snapshots().map((snapshot) {
      final users = snapshot.docs
          .map((doc) {
            try { return UserStats.fromJson(doc.data()); } catch (_) { return null; }
          })
          .whereType<UserStats>()
          .where((u) => !u.isProfileHidden)
          .toList()
        ..sort((a, b) {
          final aR = a.exerciseRecords[exerciseId] ?? 0.0;
          final bR = b.exerciseRecords[exerciseId] ?? 0.0;
          return bR.compareTo(aR);
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

  Future<UserStats?> getUserStats(String userId) async {
    try {
      final doc = await _db.collection('user_stats').doc(userId).get();
      if (doc.exists) {
        final stats = UserStats.fromJson(doc.data()!);
        if (stats.isProfileHidden) {
          debugPrint('[LEADERBOARD] User profile is hidden: $userId');
          return null;
        }
        return stats;
      }
    } catch (e) {
      debugPrint('[LEADERBOARD] Error fetching user stats: $e');
    }
    return null;
  }

  Stream<List<UserStats>> getProgressLeaderboard({
    int limit = 100,
    String scope = 'Global',
    String? userCountry,
    String? userCity,
  }) {
    if (scope == 'My League') {
      return _leagueStream('weeklyProgressPercentage', limit: limit);
    }
    var q = _db
        .collection('user_stats')
        .where('weeklyProgressPercentage', isGreaterThan: 0);
    if (scope == 'Country' && userCountry != null) {
      q = q.where('country', isEqualTo: userCountry);
    } else if (scope == 'City' && userCity != null) {
      q = q.where('city', isEqualTo: userCity);
    }
    return q
        .orderBy('weeklyProgressPercentage', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs
            .map((d) {
              try { return UserStats.fromJson(d.data()); } catch (_) { return null; }
            })
            .whereType<UserStats>()
            .where((u) => !u.isProfileHidden)
            .toList());
  }

  double _calculateWeeklyProgress(
      List<WorkoutHistory> workoutHistory, double userBodyWeight) {
    if (workoutHistory.isEmpty) return 0.0;

    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    double currentWeekWeight = 0;
    for (var history in workoutHistory) {
      if (history.date.isAfter(oneWeekAgo)) {
        for (var exerciseResult in history.session.exerciseResults) {
          for (var setResult in exerciseResult.setResults) {
            final effectiveWeight =
                setResult.weight > 0 ? setResult.weight : userBodyWeight;
            currentWeekWeight += effectiveWeight * setResult.actualReps;
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
            final effectiveWeight =
                setResult.weight > 0 ? setResult.weight : userBodyWeight;
            previousWeekWeight += effectiveWeight * setResult.actualReps;
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
