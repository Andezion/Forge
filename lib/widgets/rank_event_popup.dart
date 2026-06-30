import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/overall_rank_result.dart';
import '../models/rank_popup_event.dart';
import 'rank_badge_widget.dart';

class RankEventPopup extends StatelessWidget {
  final RankPopupEvent event;
  final OverallRankResult? rankResult;

  const RankEventPopup({super.key, required this.event, this.rankResult});

  static Future<void> show(
    BuildContext context,
    RankPopupEvent event,
    OverallRankResult? rankResult,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => RankEventPopup(event: event, rankResult: rankResult),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (event.badgeRank != null)
              Center(child: RankBadgeWidget(rank: event.badgeRank!, size: 96)),
            const SizedBox(height: 16),
            Text(
              event.title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              event.message,
              style: AppTextStyles.body1,
              textAlign: TextAlign.center,
            ),
            if (rankResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Top ${rankResult!.topPercent.toStringAsFixed(0)}% of athletes',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (rankResult!.reason.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  rankResult!.reason,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Nice!'),
            ),
          ],
        ),
      ),
    );
  }
}
