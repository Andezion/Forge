import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/overall_rank_result.dart';
import '../models/rank_popup_event.dart';
import '../models/strength_rank.dart';
import '../models/workout_history.dart';
import '../models/workout_session.dart';
import 'ranking_service.dart';

class AchievementPopupService {
  static const double _recordBucketKg = 5.0;

  Future<List<RankPopupEvent>> collectPopupEvents({
    required OverallRankResult? previousRank,
    required OverallRankResult freshRank,
    required WorkoutSession completedSession,
    required List<WorkoutHistory> workoutHistory,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final events = <RankPopupEvent>[];

    if (previousRank != null) {
      final significance =
          RankingAlgorithm.compareSignificance(previousRank, freshRank);

      if (significance == RankChangeSignificance.rankUp &&
          freshRank.rank.index > previousRank.rank.index) {
        final key = 'popup_shown_rankup_${freshRank.rank.name}';
        if (prefs.getBool(key) != true) {
          events.add(RankPopupEvent(
            type: RankPopupEventType.rankUp,
            dedupeKey: key,
            title: 'Rank Up!',
            message: 'You\'ve reached ${freshRank.rank.displayName} rank.',
            badgeRank: freshRank.rank,
          ));
        }
      } else if (significance == RankChangeSignificance.majorImprovement) {
        events.add(RankPopupEvent(
          type: RankPopupEventType.majorImprovement,
          dedupeKey: '',
          title: 'Great Progress!',
          message: 'Your overall rank score is climbing fast.',
          badgeRank: freshRank.rank,
        ));
      }
    }

    for (final er in completedSession.exerciseResults) {
      if (er.setResults.isEmpty) continue;
      final maxWeightThisSession =
          er.setResults.map((s) => s.weight).reduce(math.max);
      if (maxWeightThisSession <= 0) continue;

      final priorBest =
          _priorBestExcludingLatest(workoutHistory, er.exercise.id);
      if (maxWeightThisSession <= priorBest) continue;

      final bucket =
          (maxWeightThisSession / _recordBucketKg).floor() * _recordBucketKg;
      final key = 'popup_shown_record_${er.exercise.id}_${bucket.toInt()}';
      if (prefs.getBool(key) == true) continue;

      events.add(RankPopupEvent(
        type: RankPopupEventType.newRecord,
        dedupeKey: key,
        title: 'New Personal Record!',
        message:
            '${er.exercise.name}: ${maxWeightThisSession.toStringAsFixed(1)} kg',
        badgeRank: freshRank.rank,
      ));
    }

    if (workoutHistory.length == 1) {
      const key = 'popup_shown_firsttime_first_workout';
      if (prefs.getBool(key) != true) {
        events.add(RankPopupEvent(
          type: RankPopupEventType.firstTime,
          dedupeKey: key,
          title: 'First Workout Complete!',
          message: 'Welcome to your strength journey.',
          badgeRank: freshRank.rank,
        ));
      }
    }

    return events;
  }

  Future<void> markShown(RankPopupEvent event) async {
    if (event.dedupeKey.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(event.dedupeKey, true);
  }

  double _priorBestExcludingLatest(
      List<WorkoutHistory> workoutHistory, String exerciseId) {
    if (workoutHistory.isEmpty) return 0.0;
    final priorHistory = workoutHistory.sublist(0, workoutHistory.length - 1);
    double best = 0.0;
    for (final h in priorHistory) {
      for (final er in h.session.exerciseResults) {
        if (er.exercise.id != exerciseId) continue;
        for (final set in er.setResults) {
          if (set.weight > best) best = set.weight;
        }
      }
    }
    return best;
  }
}
