import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_text_styles.dart';
import '../models/strength_rank.dart';
import '../services/leaderboard_service.dart';
import '../services/ranking_service.dart';
import 'rank_badge_widget.dart';

class FriendRankBadge extends StatelessWidget {
  final String userId;
  final double size;

  const FriendRankBadge({super.key, required this.userId, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final rankingService = Provider.of<RankingService>(context, listen: false);
    final leaderboardService =
        Provider.of<LeaderboardService>(context, listen: false);

    return FutureBuilder(
      future: rankingService.getOtherUserRank(userId, leaderboardService),
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result == null) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RankBadgeWidget(rank: result.rank, size: size),
            const SizedBox(width: 4),
            Text(result.rank.displayName, style: AppTextStyles.caption),
          ],
        );
      },
    );
  }
}
