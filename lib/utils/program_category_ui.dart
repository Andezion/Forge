import 'package:flutter/material.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';

import '../constants/app_colors.dart';
import '../models/public_program.dart';

extension ProgramCategoryUi on ProgramCategory {
  String label(AppLocalizations l10n) {
    switch (this) {
      case ProgramCategory.fullBody:
        return l10n.directionFullBody;
      case ProgramCategory.powerlifting:
        return l10n.powerlifting;
      case ProgramCategory.armWrestling:
        return l10n.armwrestling;
      case ProgramCategory.streetlifting:
        return l10n.streetlifting;
      case ProgramCategory.other:
        return l10n.categoryOther;
    }
  }

  IconData get icon {
    switch (this) {
      case ProgramCategory.fullBody:
        return Icons.accessibility_new;
      case ProgramCategory.powerlifting:
        return Icons.fitness_center;
      case ProgramCategory.armWrestling:
        return Icons.back_hand;
      case ProgramCategory.streetlifting:
        return Icons.sports_gymnastics;
      case ProgramCategory.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case ProgramCategory.fullBody:
        return AppColors.primary;
      case ProgramCategory.powerlifting:
        return AppColors.powerlifting;
      case ProgramCategory.armWrestling:
        return AppColors.armwrestling;
      case ProgramCategory.streetlifting:
        return AppColors.streetlifting;
      case ProgramCategory.other:
        return Colors.blueGrey;
    }
  }
}

extension PublicProgramStatusUi on PublicProgramStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case PublicProgramStatus.pending:
        return l10n.statusPending;
      case PublicProgramStatus.approved:
        return l10n.statusApproved;
      case PublicProgramStatus.rejected:
        return l10n.statusRejected;
    }
  }

  IconData get icon {
    switch (this) {
      case PublicProgramStatus.pending:
        return Icons.hourglass_top;
      case PublicProgramStatus.approved:
        return Icons.storefront;
      case PublicProgramStatus.rejected:
        return Icons.block;
    }
  }

  Color get color {
    switch (this) {
      case PublicProgramStatus.pending:
        return Colors.orange;
      case PublicProgramStatus.approved:
        return AppColors.success;
      case PublicProgramStatus.rejected:
        return AppColors.error;
    }
  }
}

class StoreChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const StoreChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
