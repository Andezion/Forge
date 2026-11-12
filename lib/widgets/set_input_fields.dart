import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../utils/units.dart';

class SetEntry {
  final TextEditingController reps;
  final TextEditingController weight;
  final TextEditingController minutes;
  final TextEditingController calories;

  bool withCalories;

  SetEntry({
    String repsText = '',
    String weightText = '',
    String minutesText = '',
    String caloriesText = '',
    this.withCalories = false,
  }) : reps = TextEditingController(text: repsText),
       weight = TextEditingController(text: weightText),
       minutes = TextEditingController(text: minutesText),
       calories = TextEditingController(text: caloriesText);

  void dispose() {
    reps.dispose();
    weight.dispose();
    minutes.dispose();
    calories.dispose();
  }
}

class SetEntryValues {
  final int reps;
  final double weight;
  final int? minutes;
  final double? calories;

  const SetEntryValues({
    required this.reps,
    required this.weight,
    this.minutes,
    this.calories,
  });

  ExerciseSetResult toSetResult({
    required int setNumber,
    required int durationSeconds,
  }) {
    return ExerciseSetResult(
      setNumber: setNumber,
      actualReps: reps,
      weight: weight,
      timestamp: DateTime.now(),
      durationSeconds: durationSeconds,
      durationMinutes: minutes,
      calories: calories,
    );
  }
}

({SetEntryValues? values, String? error}) readSetEntry(
  SetEntry entry,
  ExerciseType type, {
  required AppLocalizations l10n,
  required Units units,
  double originalKg = 0,
  double fallbackWeightKg = 0,
}) {
  switch (type) {
    case ExerciseType.cardio:
      final minutes = int.tryParse(entry.minutes.text.trim()) ?? 0;
      if (minutes <= 0) return (values: null, error: l10n.pleaseEnterMinutes);
      double? calories;
      if (entry.withCalories) {
        calories = double.tryParse(
          entry.calories.text.trim().replaceAll(',', '.'),
        );
        if (calories == null || calories <= 0) {
          return (values: null, error: l10n.pleaseEnterCalories);
        }
      }
      return (
        values: SetEntryValues(
          reps: 0,
          weight: 0,
          minutes: minutes,
          calories: calories,
        ),
        error: null,
      );
    case ExerciseType.repsOnly:
      final reps = int.tryParse(entry.reps.text.trim()) ?? 0;
      if (reps <= 0) return (values: null, error: l10n.pleaseEnterReps);
      return (values: SetEntryValues(reps: reps, weight: 0), error: null);
    case ExerciseType.weightAndReps:
      final reps = int.tryParse(entry.reps.text.trim()) ?? 0;
      if (reps <= 0) return (values: null, error: l10n.pleaseEnterReps);
      final weight =
          (units.parseWeight(
                    entry.weight.text,
                    originalKg: originalKg > 0 ? originalKg : null,
                  ) ??
                  fallbackWeightKg)
              .clamp(0.0, double.infinity)
              .toDouble();
      return (values: SetEntryValues(reps: reps, weight: weight), error: null);
  }
}

class SetInputFields extends StatefulWidget {
  final SetEntry entry;
  final ExerciseType type;
  final bool enabled;
  final String? repsHint;
  final String? weightHint;
  final String? minutesHint;
  final double fieldHeight;
  final bool autofocus;

  const SetInputFields({
    super.key,
    required this.entry,
    required this.type,
    this.enabled = true,
    this.repsHint,
    this.weightHint,
    this.minutesHint,
    this.fieldHeight = 42,
    this.autofocus = false,
  });

  @override
  State<SetInputFields> createState() => _SetInputFieldsState();
}

class _SetInputFieldsState extends State<SetInputFields> {
  InputDecoration _decoration(String label, String? hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      isDense: true,
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool decimal = false,
    bool autofocus = false,
    Widget? suffix,
  }) {
    return SizedBox(
      height: widget.fieldHeight,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        enabled: widget.enabled,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        inputFormatters: decimal
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
            : [FilteringTextInputFormatter.digitsOnly],
        decoration: _decoration(label, hint, suffix: suffix),
        style: AppTextStyles.body2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final units = Units.of(context);
    final entry = widget.entry;

    switch (widget.type) {
      case ExerciseType.weightAndReps:
        return Row(
          children: [
            Expanded(
              child: _field(
                controller: entry.reps,
                label: l10n.reps,
                hint: widget.repsHint,
                autofocus: widget.autofocus,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _field(
                controller: entry.weight,
                label: units.weightLabel,
                hint: widget.weightHint ?? '0',
                decimal: true,
              ),
            ),
          ],
        );
      case ExerciseType.repsOnly:
        return _field(
          controller: entry.reps,
          label: l10n.reps,
          hint: widget.repsHint,
          autofocus: widget.autofocus,
        );
      case ExerciseType.cardio:
        return Row(
          children: [
            Expanded(
              child: _field(
                controller: entry.minutes,
                label: l10n.minutesLabel,
                hint: widget.minutesHint,
                autofocus: widget.autofocus,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: entry.withCalories
                  ? _field(
                      controller: entry.calories,
                      label: l10n.kcalLabel,
                      decimal: true,
                      suffix: widget.enabled
                          ? IconButton(
                              tooltip: l10n.removeCalories,
                              icon: const Icon(Icons.close, size: 16),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              onPressed: () => setState(() {
                                entry.withCalories = false;
                                entry.calories.clear();
                              }),
                            )
                          : null,
                    )
                  : widget.enabled
                  ? SizedBox(
                      height: widget.fieldHeight,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => entry.withCalories = true),
                        icon: const Icon(Icons.local_fire_department, size: 16),
                        label: Text(l10n.addCaloriesButton),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side: BorderSide(
                            color: AppColors.warning.withValues(alpha: 0.6),
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
    }
  }
}
