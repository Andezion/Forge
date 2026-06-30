import 'strength_rank.dart';

enum RankPopupEventType { newRecord, firstTime, rankUp, majorImprovement }

class RankPopupEvent {
  final RankPopupEventType type;
  final String dedupeKey;
  final String title;
  final String message;
  final StrengthRank? badgeRank;

  const RankPopupEvent({
    required this.type,
    required this.dedupeKey,
    required this.title,
    required this.message,
    this.badgeRank,
  });
}
