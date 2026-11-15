import 'package:flutter/material.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/exercise.dart';
import '../models/public_program.dart';
import '../models/workout.dart';
import '../services/data_manager.dart';
import '../services/public_program_service.dart';
import '../utils/program_category_ui.dart';
import '../utils/units.dart';
import '../utils/workout_format.dart';
import '../utils/workout_import.dart';
import '../widgets/muscle_load_panel.dart';

class PublicProgramScreen extends StatefulWidget {
  final PublicProgram program;

  const PublicProgramScreen({super.key, required this.program});

  @override
  State<PublicProgramScreen> createState() => _PublicProgramScreenState();
}

class _PublicProgramScreenState extends State<PublicProgramScreen> {
  final _service = PublicProgramService();
  bool _copying = false;

  PublicProgram get _program => widget.program;

  Future<void> _copy() async {
    final l10n = AppLocalizations.of(context)!;
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final plan =
        dataManager.planPublicWorkoutImport(_program.workout, _program.id);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _CopyConfirmDialog(program: _program, plan: plan),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _copying = true);
    dataManager.applyWorkoutImport(plan);
    await _service.recordDownload(_program.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.programCopied(_program.name)),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context)
        .pop(_program.copyWith(downloadCount: _program.downloadCount + 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dataManager = Provider.of<DataManager>(context);
    final isOwn = _program.authorId == _service.currentUserId;
    final isImported = dataManager.hasImportedPublicProgram(_program.id);
    final color = _program.category.color;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          _program.name,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_program.category.icon, color: color, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_program.name, style: AppTextStyles.h4),
                    const SizedBox(height: 4),
                    Text(
                      l10n.byAuthor(_program.authorNickname),
                      style: AppTextStyles.body2.copyWith(color: secondary),
                    ),
                    if (_program.reviewedAt ?? _program.createdAt case final date?)
                      Text(
                        DateFormat.yMMMd(
                                Localizations.localeOf(context).toString())
                            .format(date),
                        style: AppTextStyles.caption.copyWith(color: secondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              StoreChip(label: _program.category.label(l10n), color: color),
              StoreChip(
                label: l10n.exercisesCount(_program.exerciseCount),
                icon: Icons.list_alt,
                color: Colors.blueGrey,
              ),
              StoreChip(
                label: l10n.downloadsCount(_program.downloadCount),
                icon: Icons.download,
                color: Colors.blueGrey,
              ),
            ],
          ),
          if (_program.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(_program.description, style: AppTextStyles.body2),
          ],
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: MuscleLoadPanel(
              workout: _program.workout,
              showTopBorder: false,
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.exercisesColonLabel,
              style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._program.workout.exercises.asMap().entries.map(
                (e) => _ExerciseTile(index: e.key + 1, item: e.value, color: color),
              ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: ElevatedButton.icon(
          onPressed: (isOwn || isImported || _copying) ? null : _copy,
          icon: _copying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(isImported ? Icons.check_circle : Icons.download,
                  color: Colors.white),
          label: Text(isOwn
              ? l10n.yourProgramBadge
              : isImported
                  ? l10n.alreadyInYourWorkouts
                  : l10n.copyToMyWorkouts),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

String _prescription(BuildContext context, WorkoutExercise we) {
  final l10n = AppLocalizations.of(context)!;
  if (we.exercise.exerciseType == ExerciseType.cardio &&
      we.targetDurationMinutes != null) {
    return '${l10n.setsCount(we.sets)} × ${l10n.minutesShort(we.targetDurationMinutes!)}';
  }
  return formatSetsRepsWeight(l10n, Units.of(context),
      sets: we.sets, reps: we.targetReps, weightKg: 0);
}

class _ExerciseTile extends StatelessWidget {
  final int index;
  final WorkoutExercise item;
  final Color color;

  const _ExerciseTile({
    required this.index,
    required this.item,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$index',
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.exercise.name,
                    style: AppTextStyles.body2
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(_prescription(context, item),
                    style: AppTextStyles.caption),
                if (item.alternativeExercises.isNotEmpty)
                  Text(
                    l10n.alternativesLabel(item.alternativeExercises
                        .map((a) => a.name)
                        .join(', ')),
                    style: AppTextStyles.caption.copyWith(
                        color: secondary, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyConfirmDialog extends StatelessWidget {
  final PublicProgram program;
  final WorkoutImportPlan plan;

  const _CopyConfirmDialog({required this.program, required this.plan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;

    Widget section(String title, List<Exercise> items, IconData icon, Color c) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: c),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(e.name, style: AppTextStyles.caption)),
                    ],
                  ),
                )),
          ],
        ),
      );
    }

    return AlertDialog(
      title: Text(l10n.copyProgramTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.copyProgramIntro(program.name)),
            if (plan.newExercises.isNotEmpty)
              section(
                l10n.newExercisesWillBeAdded(plan.newExercises.length),
                plan.newExercises,
                Icons.add_circle_outline,
                AppColors.success,
              ),
            if (plan.matchedExercises.isNotEmpty)
              section(
                l10n.existingExercisesReused(plan.matchedExercises.length),
                plan.matchedExercises,
                Icons.check,
                secondary ?? Colors.grey,
              ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(l10n.weightsResetNote,
                      style: AppTextStyles.caption),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.copyAction),
        ),
      ],
    );
  }
}
