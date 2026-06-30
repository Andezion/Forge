import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/overall_rank_result.dart';
import '../models/rank_signals.dart';
import '../models/strength_rank.dart';
import '../models/workout_history.dart';
import '../utils/achievement_progress.dart';
import 'challenge_service.dart';
import 'data_manager.dart';
import 'friends_service.dart';
import 'groq_service.dart';
import 'leaderboard_service.dart';
import 'profile_service.dart';
import 'rank_service.dart';
import 'settings_service.dart';
import 'world_records_service.dart';

enum RankChangeSignificance { minor, majorImprovement, rankUp }

class RankingAlgorithm {
  static const int minWorkoutsForHistorical = 3;

  static const double majorImprovementThreshold = 8.0;

  static bool hasSufficientData(RankSignals s) =>
      s.workoutCount >= minWorkoutsForHistorical;

  static OverallRankResult computeOverallRank(RankSignals s, {DateTime? now}) {
    if (!hasSufficientData(s)) {
      return deterministicFallback(s, now: now);
    }
    final score = _compositeScore(s);
    final rank = rankForScore(score);
    return OverallRankResult(
      rank: rank,
      score: score,
      percentile: percentileForScore(score),
      dataSource: RankDataSource.historical,
      confidence: _confidenceFor(s),
      reason: _buildReason(s),
      computedAt: now ?? DateTime.now(),
    );
  }

  static double _strengthSubScore(RankSignals s) {
    if (s.perExerciseRankPositions.isEmpty) return 0.0;
    final avgPosition = s.perExerciseRankPositions.reduce((a, b) => a + b) /
        s.perExerciseRankPositions.length;
    return (avgPosition / (StrengthRank.values.length - 1) * 100)
        .clamp(0.0, 100.0);
  }

  static double _consistencySubScore(RankSignals s) {
    final workoutPart = (math.min(s.workoutCount, 200) / 200) * 60;
    final streakPart = (math.min(s.currentStreak, 30) / 30) * 40;
    return (workoutPart + streakPart).clamp(0.0, 100.0);
  }

  static double _achievementSubScore(RankSignals s) {
    if (s.totalAchievementCount <= 0) return 0.0;
    return (s.unlockedAchievementCount / s.totalAchievementCount * 100)
        .clamp(0.0, 100.0);
  }

  static double _momentumSubScore(RankSignals s) {
    final weekly = (50 + s.weeklyProgressPercentage.clamp(-50.0, 50.0))
        .clamp(0.0, 100.0);
    final trend = s.avgPerformanceTrend;
    if (trend == null) return weekly;
    final trendPart =
        (50 + (trend * 10).clamp(-50.0, 50.0)).clamp(0.0, 100.0);
    return (weekly * 0.7 + trendPart * 0.3).clamp(0.0, 100.0);
  }

  static const double _strengthWeight = 0.45;
  static const double _consistencyWeight = 0.20;
  static const double _achievementWeight = 0.15;
  static const double _momentumWeight = 0.20;

  static double _compositeScore(RankSignals s) {
    final consistency = _consistencySubScore(s);
    final achievements = _achievementSubScore(s);
    final momentum = _momentumSubScore(s);

    final double linear;
    if (s.perExerciseRankPositions.isEmpty) {
      
      final remaining =
          _consistencyWeight + _achievementWeight + _momentumWeight;
      linear = (_consistencyWeight / remaining) * consistency +
          (_achievementWeight / remaining) * achievements +
          (_momentumWeight / remaining) * momentum;
    } else {
      final strength = _strengthSubScore(s);
      linear = _strengthWeight * strength +
          _consistencyWeight * consistency +
          _achievementWeight * achievements +
          _momentumWeight * momentum;
    }

    return 100 * math.pow((linear / 100).clamp(0.0, 1.0), 1.35).toDouble();
  }

  static StrengthRank rankForScore(double score) {
    for (final rank in StrengthRank.values.reversed) {
      if (score >= rank.minPercent) return rank;
    }
    return StrengthRank.wooden;
  }

  static double percentileForScore(double score) {
    final normalized = (score / 100).clamp(0.0, 1.0);
    return (100 * (1 - math.pow(1 - normalized, 1.8)))
        .clamp(1.0, 99.0)
        .toDouble();
  }

  static double _confidenceFor(RankSignals s) {
    final liftSignal = s.perExerciseRankPositions.length * 0.1;
    final historySignal = (s.workoutCount / 10).clamp(0.0, 5.0) * 0.05;
    return (0.5 + liftSignal + historySignal).clamp(0.5, 0.95);
  }

  static String _buildReason(RankSignals s) {
    final liftsPart = s.perExerciseRankPositions.isEmpty
        ? 'your training consistency and achievements'
        : '${s.perExerciseRankPositions.length} tracked lift(s) measured against world-record benchmarks';
    return 'Based on $liftsPart, ${s.workoutCount} logged workouts and a '
        '${s.currentStreak}-day streak.';
  }

  static OverallRankResult deterministicFallback(RankSignals s, {DateTime? now}) {
    final consistency = _consistencySubScore(s);
    final achievements = _achievementSubScore(s);
    final dampedScore = (0.5 * consistency + 0.5 * achievements) * 0.4;
    final rank = rankForScore(dampedScore);
    return OverallRankResult(
      rank: rank,
      score: dampedScore,
      percentile: percentileForScore(dampedScore),
      dataSource: RankDataSource.heuristic,
      confidence: 0.25,
      reason:
          'Not enough workout history yet — rank will refine as you log more sessions.',
      computedAt: now ?? DateTime.now(),
    );
  }

  static RankChangeSignificance compareSignificance(
      OverallRankResult previous, OverallRankResult fresh) {
    if (fresh.rank.index != previous.rank.index) {
      return RankChangeSignificance.rankUp;
    }
    if (fresh.score - previous.score >= majorImprovementThreshold) {
      return RankChangeSignificance.majorImprovement;
    }
    return RankChangeSignificance.minor;
  }
}

class RankingService extends ChangeNotifier {
  static const _cacheKey = 'overall_rank_result_cache';
  static const _cacheTtl = Duration(hours: 6);

  OverallRankResult? _cached;
  OverallRankResult? get current => _cached;

  Future<OverallRankResult> getOrComputeOverallRank({
    required DataManager dataManager,
    required ProfileService profileService,
    required SettingsService settingsService,
    required LeaderboardService leaderboardService,
    required FriendsService friendsService,
    required ChallengeService challengeService,
    bool forceRecompute = false,
  }) async {
    if (!forceRecompute && _cached != null && _isFresh(_cached!)) {
      return _cached!;
    }

    if (!forceRecompute) {
      final cachedFromPrefs = await _loadFromPrefs();
      if (cachedFromPrefs != null && _isFresh(cachedFromPrefs)) {
        _cached = cachedFromPrefs;
        notifyListeners();
        return cachedFromPrefs;
      }
    }

    final signals = await _gatherSignals(
      dataManager: dataManager,
      profileService: profileService,
      settingsService: settingsService,
      leaderboardService: leaderboardService,
      friendsService: friendsService,
      challengeService: challengeService,
    );

    final result = RankingAlgorithm.hasSufficientData(signals)
        ? RankingAlgorithm.computeOverallRank(signals)
        : await _estimateSparseRank(
            signals,
            profileService: profileService,
            settingsService: settingsService,
          );

    _cached = result;
    await _saveToPrefs(result);
    notifyListeners();
    return result;
  }

  RankChangeSignificance compareSignificance(
          OverallRankResult previous, OverallRankResult fresh) =>
      RankingAlgorithm.compareSignificance(previous, fresh);

  Future<RankSignals> _gatherSignals({
    required DataManager dataManager,
    required ProfileService profileService,
    required SettingsService settingsService,
    required LeaderboardService leaderboardService,
    required FriendsService friendsService,
    required ChallengeService challengeService,
  }) async {
    final workoutHistory = dataManager.workoutHistory;

    final stats = await leaderboardService.getCurrentUserStats();
    final currentStreak = stats?.currentStreak ?? 0;
    final weeklyProgressPercentage = stats?.weeklyProgressPercentage ?? 0.0;

    final perExerciseRankPositions = await _computePerExerciseRankPositions(
      workoutHistory,
      profileService,
      settingsService,
    );

    final challengeStats = await challengeService.getCurrentUserChallengeStats();

    final achievements = AchievementProgress.calculateAll(
      AchievementProgressInput(
        workoutHistory: workoutHistory,
        friendsCount: friendsService.friends.length,
        bodyWeightKg: profileService.weightKg ?? 0.0,
        isMale: profileService.gender != 'female',
        challengeWinCount: challengeStats.wins,
        completedChallengeCount: challengeStats.completed,
      ),
    );
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return RankSignals(
      perExerciseRankPositions: perExerciseRankPositions,
      workoutCount: workoutHistory.length,
      currentStreak: currentStreak,
      totalWeightLifted: stats?.totalWeightLifted ?? 0.0,
      unlockedAchievementCount: unlockedCount,
      totalAchievementCount: achievements.length,
      weeklyProgressPercentage: weeklyProgressPercentage,
    );
  }

  Future<List<double>> _computePerExerciseRankPositions(
    List<WorkoutHistory> workoutHistory,
    ProfileService profileService,
    SettingsService settingsService,
  ) async {
    final bestByExercise = <String, ({double weight, String name})>{};
    for (final h in workoutHistory) {
      for (final er in h.session.exerciseResults) {
        for (final set in er.setResults) {
          if (set.weight <= 0) continue;
          final existing = bestByExercise[er.exercise.id];
          if (existing == null || set.weight > existing.weight) {
            bestByExercise[er.exercise.id] =
                (weight: set.weight, name: er.exercise.name);
          }
        }
      }
    }
    if (bestByExercise.isEmpty) return [];

    final gender = profileService.gender ?? 'male';
    final weightClass = WorldRecordsService()
        .getWeightClass(profileService.weightKg ?? 75.0, gender);
    final groq = GroqService(apiKey: settingsService.groqApiKey);

    final positions = <double>[];
    for (final entry in bestByExercise.entries) {
      final match =
          await groq.matchExerciseToRecord(entry.key, entry.value.name);
      if (match == null) continue;
      final wr = await WorldRecordsService().getRecord(
        exercise: match,
        weightClass: weightClass,
        gender: gender,
        equipped: false,
      );
      if (wr == null || wr.weight <= 0) continue;
      final rank = RankService.calculateRank(entry.value.weight, wr.weight);
      final progress =
          RankService.progressWithinRank(entry.value.weight, wr.weight);
      positions.add(rank.index + progress);
    }
    return positions;
  }

  Future<OverallRankResult> _estimateSparseRank(
    RankSignals s, {
    required ProfileService profileService,
    required SettingsService settingsService,
  }) async {
    try {
      final groq = GroqService(apiKey: settingsService.groqApiKey);
      final aiResult = await groq.estimateRankFromPartialProfile(
        bodyWeightKg: profileService.weightKg,
        gender: profileService.gender,
        experienceLevel: profileService.experienceLevel,
        workoutCount: s.workoutCount,
        knownLifts: const {},
      );
      if (aiResult != null) return aiResult;
    } catch (e) {
      debugPrint('[RANKING] Groq sparse estimate failed: $e');
    }
    return RankingAlgorithm.deterministicFallback(s);
  }

  Future<OverallRankResult?> getOtherUserRank(
    String userId,
    LeaderboardService leaderboardService,
  ) async {
    final stats = await leaderboardService.getUserStats(userId);
    if (stats == null || stats.overallRank == null) return null;
    final rank = StrengthRank.values.firstWhere(
      (r) => r.name == stats.overallRank,
      orElse: () => StrengthRank.wooden,
    );
    final score = stats.overallRankScore ?? rank.minPercent;
    return OverallRankResult(
      rank: rank,
      score: score,
      percentile: RankingAlgorithm.percentileForScore(score),
      dataSource: RankDataSource.historical,
      confidence: 0.7,
      reason: '',
      computedAt: stats.updatedAt,
    );
  }

  bool _isFresh(OverallRankResult r) =>
      DateTime.now().difference(r.computedAt) < _cacheTtl;

  Future<OverallRankResult?> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_cacheKey);
      if (json == null) return null;
      return OverallRankResult.fromJson(
          jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToPrefs(OverallRankResult r) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(r.toJson()));
    } catch (_) {}
  }
}
