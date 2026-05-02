import '../models/strength_rank.dart';

class RankService {
  static StrengthRank calculateRank(double userBest, double worldRecord) {
    if (worldRecord <= 0) return StrengthRank.wooden;
    final percent = (userBest / worldRecord * 100).clamp(0.0, 105.0);
    for (final rank in StrengthRank.values.reversed) {
      if (percent >= rank.minPercent) return rank;
    }
    return StrengthRank.wooden;
  }

  static double progressWithinRank(double userBest, double worldRecord) {
    if (worldRecord <= 0) return 0.0;
    final percent = (userBest / worldRecord * 100).clamp(0.0, 105.0);
    final rank = calculateRank(userBest, worldRecord);
    final rangeSize = rank.maxPercent - rank.minPercent;
    if (rangeSize <= 0) return 1.0;
    return ((percent - rank.minPercent) / rangeSize).clamp(0.0, 1.0);
  }

  // Сколько кг нужно добавить для следующего ранга (null = уже максимум)
  static double? kgToNextRank(double userBest, double worldRecord) {
    if (worldRecord <= 0) return null;
    final rank = calculateRank(userBest, worldRecord);
    final nextRank = rank.next;
    if (nextRank == null) return null;
    final targetWeight = worldRecord * nextRank.minPercent / 100;
    final diff = targetWeight - userBest;
    return diff > 0 ? diff : null;
  }

  static double percentOfWorldRecord(double userBest, double worldRecord) {
    if (worldRecord <= 0) return 0.0;
    return (userBest / worldRecord * 100).clamp(0.0, 105.0);
  }
}
