import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants/app_colors.dart';
import '../models/exercise.dart';
import '../services/muscle_recovery_tracker.dart';
import '../utils/muscle_group_utils.dart';
import 'body_map/body_map.dart';
import 'body_map/body_map_data.dart';

class MuscleRecoveryMap extends StatefulWidget {
  final Map<MuscleGroup, int> daysSinceTraining;
  final Map<MuscleGroup, double> recoveryPriorities;

  const MuscleRecoveryMap({
    super.key,
    required this.daysSinceTraining,
    required this.recoveryPriorities,
  });

  @override
  State<MuscleRecoveryMap> createState() => _MuscleRecoveryMapState();
}

class _MuscleRecoveryMapState extends State<MuscleRecoveryMap> {
  MuscleGroup? _selected;

  static Color _statusColor(double priority) {
    if (priority >= 0.7) return AppColors.success;
    if (priority >= 0.3) return AppColors.warning;
    return AppColors.error;
  }

  void _toggle(MuscleGroup group) {
    setState(() => _selected = _selected == group ? null : group);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fills = {
      for (final group in BodyMapData.drawnGroups)
        if (widget.recoveryPriorities[group] != null)
          group: _statusColor(widget.recoveryPriorities[group]!)
              .withValues(alpha: 0.75),
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.muscleRecovery,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final side in BodyMapSide.values)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: BodyMap(
                          side: side,
                          fills: fills,
                          selected: _selected,
                          onMuscleTap: _toggle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _selected == null
                ? _buildLegend(l10n)
                : _buildDetails(context, l10n, _selected!),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(AppLocalizations l10n) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(AppColors.success, l10n.readyToTrain),
        _legendItem(AppColors.warning, l10n.inRecovery),
        _legendItem(AppColors.error, l10n.requireRest),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildDetails(
      BuildContext context, AppLocalizations l10n, MuscleGroup group) {
    final days = widget.daysSinceTraining[group] ?? 0;
    final priority = widget.recoveryPriorities[group] ?? 0.5;
    final recommendation = MuscleRecoveryTracker()
        .getRecoveryRecommendations({group: days})[group];

    return Row(
      children: [
        Container(
          width: 4,
          height: 36,
          decoration: BoxDecoration(
            color: _statusColor(priority),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${MuscleGroupUtils.getLabel(group)} · '
                '${days >= 10 ? '10+' : days} ${l10n.days}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (recommendation != null)
                Text(
                  recommendation,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 18),
          visualDensity: VisualDensity.compact,
          onPressed: () => setState(() => _selected = null),
        ),
      ],
    );
  }
}
