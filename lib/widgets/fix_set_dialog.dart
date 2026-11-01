import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/units.dart';

Future<(int, double)?> showFixSetDialog(
  BuildContext context, {
  required int setNumber,
  required int reps,
  required double weight,
}) {
  return showDialog<(int, double)>(
    context: context,
    builder: (_) => _FixSetDialog(
      setNumber: setNumber,
      reps: reps,
      weight: weight,
    ),
  );
}

class _FixSetDialog extends StatefulWidget {
  final int setNumber;
  final int reps;
  final double weight;

  const _FixSetDialog({
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  @override
  State<_FixSetDialog> createState() => _FixSetDialogState();
}

class _FixSetDialogState extends State<_FixSetDialog> {
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(text: widget.reps.toString());
    _weightController = TextEditingController(
      text: widget.weight > 0
          ? Units.of(context, listen: false).weightValue(widget.weight)
          : '',
    );
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _save() {
    final reps = int.tryParse(_repsController.text) ?? 0;
    if (reps <= 0) {
      setState(() => _error = AppLocalizations.of(context)!.pleaseEnterReps);
      return;
    }
    final weight = (Units.of(context, listen: false)
                .parseWeight(_weightController.text, originalKg: widget.weight) ??
            0.0)
        .clamp(0.0, double.infinity);
    Navigator.of(context).pop((reps, weight));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final units = Units.of(context);
    return AlertDialog(
      title: Text(l10n.fixSetTitle(widget.setNumber)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${l10n.recordedReps(widget.reps)}'
            '${widget.weight > 0 ? " × ${units.weight(widget.weight)}" : ""}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.reps,
                    errorText: _error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: units.weightLabel,
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
