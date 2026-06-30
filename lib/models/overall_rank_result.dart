import 'strength_rank.dart';

enum RankDataSource { historical, heuristic, aiEstimated }

extension RankDataSourceExt on RankDataSource {
  static RankDataSource fromName(String? name) {
    return RankDataSource.values.firstWhere(
      (e) => e.name == name,
      orElse: () => RankDataSource.heuristic,
    );
  }
}

class OverallRankResult {
  final StrengthRank rank;
  final double score; 
  final double percentile; 
  final RankDataSource dataSource;
  final double confidence; 
  final String reason; 
  final DateTime computedAt;

  const OverallRankResult({
    required this.rank,
    required this.score,
    required this.percentile,
    required this.dataSource,
    required this.confidence,
    required this.reason,
    required this.computedAt,
  });

  double get topPercent => (100 - percentile).clamp(1.0, 99.0);

  Map<String, dynamic> toJson() => {
        'rank': rank.name,
        'score': score,
        'percentile': percentile,
        'dataSource': dataSource.name,
        'confidence': confidence,
        'reason': reason,
        'computedAt': computedAt.toIso8601String(),
      };

  factory OverallRankResult.fromJson(Map<String, dynamic> json) {
    return OverallRankResult(
      rank: StrengthRank.values.firstWhere(
        (r) => r.name == json['rank'],
        orElse: () => StrengthRank.wooden,
      ),
      score: (json['score'] as num).toDouble(),
      percentile: (json['percentile'] as num).toDouble(),
      dataSource: RankDataSourceExt.fromName(json['dataSource'] as String?),
      confidence: (json['confidence'] as num).toDouble(),
      reason: json['reason'] as String? ?? '',
      computedAt: DateTime.parse(json['computedAt'] as String),
    );
  }
}
