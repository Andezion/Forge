import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:dyplom/models/overall_rank_result.dart';
import 'package:dyplom/models/rank_signals.dart';
import 'package:dyplom/models/strength_rank.dart';
import 'package:dyplom/services/ranking_service.dart';

void main() {
  group('RankingAlgorithm', () {
    test('insufficient data falls back deterministically to a low rank', () {
      const signals = RankSignals(
        perExerciseRankPositions: [],
        workoutCount: 1,
        currentStreak: 0,
        totalWeightLifted: 0,
        unlockedAchievementCount: 0,
        totalAchievementCount: 21,
        weeklyProgressPercentage: 0,
      );

      expect(RankingAlgorithm.hasSufficientData(signals), isFalse);

      final result = RankingAlgorithm.computeOverallRank(signals);
      expect(result.dataSource, RankDataSource.heuristic);
      expect(result.rank, anyOf(StrengthRank.wooden, StrengthRank.stone));
      expect(result.confidence, lessThan(0.5));
    });

    test('zero-data brand new user lands at Wooden with low confidence', () {
      const signals = RankSignals(
        perExerciseRankPositions: [],
        workoutCount: 0,
        currentStreak: 0,
        totalWeightLifted: 0,
        unlockedAchievementCount: 0,
        totalAchievementCount: 21,
        weeklyProgressPercentage: 0,
      );

      final result = RankingAlgorithm.computeOverallRank(signals);
      expect(result.rank, StrengthRank.wooden);
      expect(result.confidence, 0.25);
    });

    test('strong historical signals produce a high rank', () {
      const signals = RankSignals(
        perExerciseRankPositions: [6.0, 6.0, 5.8],
        workoutCount: 150,
        currentStreak: 25,
        totalWeightLifted: 500000,
        unlockedAchievementCount: 18,
        totalAchievementCount: 21,
        weeklyProgressPercentage: 10,
      );

      expect(RankingAlgorithm.hasSufficientData(signals), isTrue);
      final result = RankingAlgorithm.computeOverallRank(signals);
      expect(result.dataSource, RankDataSource.historical);
      expect(result.rank, anyOf(StrengthRank.gold, StrengthRank.diamond));
    });

    test('rankForScore is monotonic and covers all 7 bands', () {
      final scores = [0.0, 10.0, 20.0, 35.0, 50.0, 65.0, 80.0, 92.0, 100.0];
      StrengthRank? previous;
      for (final score in scores) {
        final rank = RankingAlgorithm.rankForScore(score);
        if (previous != null) {
          expect(rank.index, greaterThanOrEqualTo(previous.index));
        }
        previous = rank;
      }
      expect(RankingAlgorithm.rankForScore(100.0), StrengthRank.diamond);
      expect(RankingAlgorithm.rankForScore(0.0), StrengthRank.wooden);
    });

    test('percentileForScore is monotonic in [1, 99]', () {
      double last = 0;
      for (var score = 0.0; score <= 100.0; score += 5.0) {
        final p = RankingAlgorithm.percentileForScore(score);
        expect(p, greaterThanOrEqualTo(last));
        expect(p, inInclusiveRange(1.0, 99.0));
        last = p;
      }
    });

    test('compareSignificance detects tier crossings and major jumps', () {
      final now = DateTime.now();
      OverallRankResult resultOf(StrengthRank rank, double score) {
        return OverallRankResult(
          rank: rank,
          score: score,
          percentile: RankingAlgorithm.percentileForScore(score),
          dataSource: RankDataSource.historical,
          confidence: 0.8,
          reason: '',
          computedAt: now,
        );
      }

      final bronze = resultOf(StrengthRank.bronze, 55.0);
      final silver = resultOf(StrengthRank.silver, 66.0);
      final bronzeBigJump = resultOf(StrengthRank.bronze, 63.0);
      final bronzeTinyBump = resultOf(StrengthRank.bronze, 56.0);

      expect(RankingAlgorithm.compareSignificance(bronze, silver),
          RankChangeSignificance.rankUp);
      expect(RankingAlgorithm.compareSignificance(bronze, bronzeBigJump),
          RankChangeSignificance.majorImprovement);
      expect(RankingAlgorithm.compareSignificance(bronze, bronzeTinyBump),
          RankChangeSignificance.minor);
    });

    test(
        'synthetic population produces a non-uniform, non-degenerate distribution',
        () {
      final rng = Random(42);
      final counts = <StrengthRank, int>{
        for (final r in StrengthRank.values) r: 0,
      };

      const sampleSize = 1000;
      for (var i = 0; i < sampleSize; i++) {
        final dedication = pow(rng.nextDouble(), 1.5).toDouble();
        final liftCount = 1 + rng.nextInt(3);
        final positions = List.generate(
          liftCount,
          (_) => dedication * 6.0 * (0.8 + rng.nextDouble() * 0.2),
        );

        final signals = RankSignals(
          perExerciseRankPositions: positions,
          workoutCount: 3 + (dedication * 250).round(),
          currentStreak: (dedication * 35).round(),
          totalWeightLifted: dedication * 200000,
          unlockedAchievementCount: (dedication * 21).round(),
          totalAchievementCount: 21,
          weeklyProgressPercentage: (rng.nextDouble() - 0.3) * 40,
        );

        final result = RankingAlgorithm.computeOverallRank(signals);
        counts[result.rank] = counts[result.rank]! + 1;
      }

      for (final entry in counts.entries) {
        expect(entry.value, lessThan(sampleSize * 0.5),
            reason: '${entry.key} holds more than half the population');
      }
      final populatedRanks = counts.values.where((c) => c > 0).length;
      expect(populatedRanks, greaterThanOrEqualTo(4));
    });
  });
}
