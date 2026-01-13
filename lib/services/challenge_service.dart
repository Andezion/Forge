import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import '../models/challenge.dart';

class ChallengeService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;
  String? get _currentUserName => _auth.currentUser?.displayName ?? 'Unknown';

  Stream<List<Challenge>> getActiveChallengesStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('challenges')
        .where('participantIds', arrayContains: _currentUserId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return Challenge.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              debugPrint('Error parsing challenge: $e');
              return null;
            }
          })
          .whereType<Challenge>()
          .toList();
    });
  }

  Stream<List<Challenge>> getCompletedChallengesStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('challenges')
        .where('participantIds', arrayContains: _currentUserId)
        .where('status', isEqualTo: 'completed')
        .orderBy('endDate', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return Challenge.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              debugPrint('Error parsing challenge: $e');
              return null;
            }
          })
          .whereType<Challenge>()
          .toList();
    });
  }

  Stream<List<Challenge>> getPendingChallengesStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('challenges')
        .where('participantIds', arrayContains: _currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return Challenge.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              debugPrint('Error parsing challenge: $e');
              return null;
            }
          })
          .whereType<Challenge>()
          .toList();
    });
  }

  Future<String> createChallenge({
    required ChallengeType type,
    required String title,
    required String description,
    required List<String> participantIds,
    required List<String> participantNames,
    required DateTime startDate,
    required DateTime endDate,
    String? exerciseId,
    String? exerciseName,
  }) async {
    if (_currentUserId == null) {
      return 'You must be logged in';
    }

    try {
      final challengeData = {
        'creatorId': _currentUserId,
        'creatorName': _currentUserName,
        'participantIds': participantIds,
        'participantNames': participantNames,
        'type': type.name,
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': startDate.isAfter(DateTime.now())
            ? ChallengeStatus.pending.name
            : ChallengeStatus.active.name,
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'scores': {
          for (var id in participantIds) id: 0.0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('challenges').add(challengeData);

      return 'success';
    } catch (e) {
      debugPrint('Error creating challenge: $e');
      return 'Failed to create challenge. Please try again.';
    }
  }

  Future<void> updateChallengeScores(
      String challengeId, String userId, double score) async {
    try {
      await _db.collection('challenges').doc(challengeId).update({
        'scores.$userId': score,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating challenge scores: $e');
    }
  }

  Future<void> updateChallengeStatus(String challengeId, ChallengeStatus status,
      {String? winnerId}) async {
    try {
      final updateData = {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (winnerId != null) {
        updateData['winnerId'] = winnerId;
      }

      await _db.collection('challenges').doc(challengeId).update(updateData);
    } catch (e) {
      debugPrint('Error updating challenge status: $e');
    }
  }

  Future<void> recalculateChallengeScores(String userId) async {
    try {
      final challengesSnapshot = await _db
          .collection('challenges')
          .where('participantIds', arrayContains: userId)
          .where('status', isEqualTo: 'active')
          .get();

      for (var doc in challengesSnapshot.docs) {
        final challenge = Challenge.fromJson({...doc.data(), 'id': doc.id});

        double newScore = 0.0;

        switch (challenge.type) {
          case ChallengeType.workouts:
            newScore = await _calculateWorkoutsScore(
                userId, challenge.startDate, challenge.endDate);
            break;
          case ChallengeType.totalWeight:
            newScore = await _calculateTotalWeightScore(
                userId, challenge.startDate, challenge.endDate);
            break;
          case ChallengeType.specificExercise:
            if (challenge.exerciseId != null) {
              newScore = await _calculateExerciseScore(
                  userId,
                  challenge.exerciseId!,
                  challenge.startDate,
                  challenge.endDate);
            }
            break;
          case ChallengeType.streak:
            newScore = await _calculateStreakScore(
                userId, challenge.startDate, challenge.endDate);
            break;
          case ChallengeType.consistency:
            newScore = await _calculateConsistencyScore(
                userId, challenge.startDate, challenge.endDate);
            break;
        }

        await updateChallengeScores(challenge.id, userId, newScore);
      }
    } catch (e) {
      debugPrint('Error recalculating challenge scores: $e');
    }
  }

  Future<double> _calculateWorkoutsScore(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final workoutsSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      return workoutsSnapshot.docs.length.toDouble();
    } catch (e) {
      debugPrint('Error calculating workouts score: $e');
      return 0.0;
    }
  }

  Future<double> _calculateTotalWeightScore(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final workoutsSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      double totalWeight = 0.0;
      for (var workout in workoutsSnapshot.docs) {
        final exercises = workout.data()['exercises'] as List<dynamic>?;
        if (exercises != null) {
          for (var exercise in exercises) {
            final sets = exercise['sets'] as List<dynamic>?;
            if (sets != null) {
              for (var set in sets) {
                final weight = (set['weight'] as num?)?.toDouble() ?? 0.0;
                final reps = (set['reps'] as num?)?.toInt() ?? 0;
                totalWeight += weight * reps;
              }
            }
          }
        }
      }

      return totalWeight;
    } catch (e) {
      debugPrint('Error calculating total weight score: $e');
      return 0.0;
    }
  }

  Future<double> _calculateExerciseScore(String userId, String exerciseId,
      DateTime startDate, DateTime endDate) async {
    try {
      final workoutsSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      double maxWeight = 0.0;
      for (var workout in workoutsSnapshot.docs) {
        final exercises = workout.data()['exercises'] as List<dynamic>?;
        if (exercises != null) {
          for (var exercise in exercises) {
            if (exercise['id'] == exerciseId) {
              final sets = exercise['sets'] as List<dynamic>?;
              if (sets != null) {
                for (var set in sets) {
                  final weight = (set['weight'] as num?)?.toDouble() ?? 0.0;
                  if (weight > maxWeight) {
                    maxWeight = weight;
                  }
                }
              }
            }
          }
        }
      }

      return maxWeight;
    } catch (e) {
      debugPrint('Error calculating exercise score: $e');
      return 0.0;
    }
  }

  Future<double> _calculateStreakScore(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final workoutsSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .orderBy('date', descending: true)
          .get();

      if (workoutsSnapshot.docs.isEmpty) return 0.0;

      int streak = 0;
      DateTime? lastWorkoutDate;

      for (var doc in workoutsSnapshot.docs) {
        final dateStr = doc.data()['date'] as String?;
        if (dateStr == null) continue;

        final workoutDate = DateTime.parse(dateStr);
        if (workoutDate.isBefore(startDate) || workoutDate.isAfter(endDate)) {
          continue;
        }

        if (lastWorkoutDate == null) {
          streak = 1;
          lastWorkoutDate = workoutDate;
        } else {
          final daysDifference = lastWorkoutDate.difference(workoutDate).inDays;
          if (daysDifference == 1) {
            streak++;
            lastWorkoutDate = workoutDate;
          } else {
            break;
          }
        }
      }

      return streak.toDouble();
    } catch (e) {
      debugPrint('Error calculating streak score: $e');
      return 0.0;
    }
  }

  Future<double> _calculateConsistencyScore(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final workoutsSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      final uniqueDays = <String>{};
      for (var doc in workoutsSnapshot.docs) {
        final dateStr = doc.data()['date'] as String?;
        if (dateStr != null) {
          final date = DateTime.parse(dateStr);
          uniqueDays.add('${date.year}-${date.month}-${date.day}');
        }
      }

      return uniqueDays.length.toDouble();
    } catch (e) {
      debugPrint('Error calculating consistency score: $e');
      return 0.0;
    }
  }

  Future<String> acceptChallenge(String challengeId) async {
    try {
      await _db.collection('challenges').doc(challengeId).update({
        'status': ChallengeStatus.active.name,
        'startDate': DateTime.now().toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return 'success';
    } catch (e) {
      debugPrint('Error accepting challenge: $e');
      return 'Failed to accept challenge';
    }
  }

  Future<String> declineChallenge(String challengeId) async {
    try {
      await _db.collection('challenges').doc(challengeId).update({
        'status': ChallengeStatus.expired.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return 'success';
    } catch (e) {
      debugPrint('Error declining challenge: $e');
      return 'Failed to decline challenge';
    }
  }
}
