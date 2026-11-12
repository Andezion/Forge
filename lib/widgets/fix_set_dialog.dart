import 'package:flutter/material.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../utils/units.dart';
import '../utils/workout_format.dart';
import 'set_input_fields.dart';

Future<SetEntryValues?> showFixSetDialog(
  BuildContext context, {
  required ExerciseSetResult set,
  required ExerciseType type,
}) {
  return showDialog<SetEntryValues>(
    context: context,
    builder: (_) => _FixSetDialog(set: set, type: type),
  );
}

class _FixSetDialog extends StatefulWidget {
  final ExerciseSetResult set;
  final ExerciseType type;

  const _FixSetDialog({required this.set, required this.type});

  @override
  State<_FixSetDialog> createState() => _FixSetDialogState();
}

class _FixSetDialogState extends State<_FixSetDialog> {
  late final SetEntry _entry;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = widget.set;
    final units = Units.of(context, listen: false);
    _entry = SetEntry(
      repsText: s.actualReps > 0 ? s.actualReps.toString() : '',
      weightText: s.weight > 0 ? units.weightValue(s.weight) : '',
      minutesText: s.durationMinutes?.toString() ?? '',
      caloriesText: s.calories != null ? s.calories!.round().toString() : '',
      withCalories: s.calories != null && s.calories! > 0,
    );
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  void _save() {
    final result = readSetEntry(
      _entry,
      widget.type,
      l10n: AppLocalizations.of(context)!,
      units: Units.of(context, listen: false),
      originalKg: widget.set.weight,
    );
    if (result.values == null) {
      setState(() => _error = result.error);
      return;
    }
    Navigator.of(context).pop(result.values);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final units = Units.of(context);
    return AlertDialog(
      title: Text(l10n.fixSetTitle(widget.set.setNumber)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.recordedValue(
              formatSetResult(l10n, units, widget.set, widget.type),
            ),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SetInputFields(
            entry: _entry,
            type: widget.type,
            fieldHeight: 48,
            autofocus: true,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
          ),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class FixSetButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const FixSetButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: 90,
      child: OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.settings, size: 14),
        label: Text(AppLocalizations.of(context)!.fix),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.warning,
          iconColor: AppColors.warning,
          backgroundColor: enabled ? AppColors.surface : null,
          side: BorderSide(
            color: enabled ? AppColors.warning : AppColors.divider,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
