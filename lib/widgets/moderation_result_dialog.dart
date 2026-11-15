import 'package:flutter/material.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/public_program.dart';

class ModerationResultDialog extends StatelessWidget {
  final PublicProgram program;

  const ModerationResultDialog({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final approved = program.status == PublicProgramStatus.approved;
    final color = approved ? AppColors.success : AppColors.error;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          approved ? Icons.celebration : Icons.sentiment_dissatisfied,
          color: color,
          size: 36,
        ),
      ),
      title: Text(
        approved ? l10n.moderationApprovedTitle : l10n.moderationRejectedTitle,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            approved
                ? l10n.moderationApprovedBody(program.name)
                : l10n.moderationRejectedBody(program.name),
            textAlign: TextAlign.center,
          ),
          if (!approved && program.rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l10n.rejectionReasonLabel(program.rejectionReason!),
                style: AppTextStyles.body2,
              ),
            ),
          ],
          if (!approved) ...[
            const SizedBox(height: 12),
            Text(
              l10n.moderationRejectedHint,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.gotIt),
          ),
        ),
      ],
    );
  }
}
