import 'package:flutter/material.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';

import '../constants/app_text_styles.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../utils/muscle_group_utils.dart';

class _MuscleStats {
  final int setsCount;
  final double loadScore;

  const _MuscleStats({required this.setsCount, required this.loadScore});
}

class MuscleLoadPanel extends StatelessWidget {
  final Workout workout;
  final bool showTopBorder;

  const MuscleLoadPanel({
    super.key,
    required this.workout,
    this.showTopBorder = true,
  });

  static Map<MuscleGroup, _MuscleStats> _calculate(Workout workout) {
    final result = <MuscleGroup, _MuscleStats>{};
    for (final we in workout.exercises) {
      for (final tag in we.exercise.muscleGroups) {
        final existing = result[tag.group];
        result[tag.group] = _MuscleStats(
          setsCount: (existing?.setsCount ?? 0) + we.sets,
          loadScore: (existing?.loadScore ?? 0.0) + tag.score * we.sets,
        );
      }
    }
    return result;
  }

  static int _intensityLevel(double score) {
    if (score <= 3) return 1;
    if (score <= 8) return 2;
    if (score <= 15) return 3;
    if (score <= 24) return 4;
    return 5;
  }

  static Color _intensityColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFF4CAF50);
      case 2:
        return const Color(0xFFFFEB3B);
      case 3:
        return const Color(0xFFFF9800);
      case 4:
        return const Color(0xFFF44336);
      case 5:
        return const Color(0xFF212121);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muscleData = _calculate(workout);
    final secondaryColor = Theme.of(context).textTheme.bodySmall?.color;

    if (muscleData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Text(
          l10n.noMuscleDataAvailable,
          style: AppTextStyles.caption.copyWith(color: secondaryColor),
        ),
      );
    }

    final sorted = muscleData.entries.toList()
      ..sort((a, b) => b.value.loadScore.compareTo(a.value.loadScore));

    return Container(
      decoration: showTopBorder
          ? BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            )
          : null,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.muscleLoad,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: secondaryColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...sorted.map((entry) {
            final stats = entry.value;
            final level = _intensityLevel(stats.loadScore);
            final color = _intensityColor(level);
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 88,
                    child: Text(
                      MuscleGroupUtils.getLabel(entry.key),
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => Container(
                        width: 18,
                        height: 9,
                        margin: const EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                          color: i < level
                              ? color
                              : Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.setsCount(stats.setsCount),
                    style: AppTextStyles.caption.copyWith(color: secondaryColor),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
