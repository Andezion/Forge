import 'package:flutter/material.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/public_program.dart';
import '../models/workout.dart';
import '../services/data_manager.dart';
import '../services/public_program_service.dart';
import '../services/workout_recommendation_service.dart';
import '../utils/program_category_ui.dart';
import '../widgets/muscle_load_panel.dart';
import '../widgets/publish_program_sheet.dart';
import '../widgets/workout_ai_evaluation.dart';
import 'create_workout_screen.dart';
import 'exercise_library_screen.dart';
import 'workout_execution_screen.dart';

enum _WorkshopView { workouts, exercises }

enum _StoreAction { publish, resubmit, update, remove }

class WorkshopScreen extends StatefulWidget {
  const WorkshopScreen({super.key});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  final _dataManager = DataManager();
  final _expandedWorkouts = <String>{};
  final _searchController = TextEditingController();
  _WorkshopView _view = _WorkshopView.workouts;
  final _storeService = PublicProgramService();

  Map<String, PublicProgram> _publications = {};

  @override
  void initState() {
    super.initState();
    _loadPublications();
  }

  Future<void> _loadPublications() async {
    final mine = await _storeService.fetchMyPublications();
    if (!mounted) return;
    setState(() {
      _publications = {for (final p in mine) p.sourceWorkoutId: p};
    });
  }

  List<_StoreAction> _storeActionsFor(Workout workout) {
    if (_dataManager.isBuiltInWorkout(workout) ||
        workout.sourcePublicId != null) {
      return const [];
    }
    switch (_publications[workout.id]?.status) {
      case null:
        return const [_StoreAction.publish];
      case PublicProgramStatus.pending:
        return const [_StoreAction.remove];
      case PublicProgramStatus.rejected:
        return const [_StoreAction.resubmit, _StoreAction.remove];
      case PublicProgramStatus.approved:
        return const [_StoreAction.update, _StoreAction.remove];
    }
  }

  Future<void> _onStoreAction(_StoreAction action, Workout workout) async {
    final l10n = AppLocalizations.of(context)!;
    final existing = _publications[workout.id];

    if (action == _StoreAction.remove) {
      if (existing != null) await _removeFromStore(existing);
      return;
    }

    if (workout.exercises.isEmpty) {
      _showSnack(l10n.publishEmptyWorkout, AppColors.error);
      return;
    }
    if (workout.exercises.length > PublicProgram.maxExercises) {
      _showSnack(l10n.publishTooManyExercises(PublicProgram.maxExercises),
          AppColors.error);
      return;
    }

    final sent = await PublishProgramSheet.show(
      context,
      workout: workout,
      existing: existing,
    );
    if (!sent || !mounted) return;
    _showSnack(l10n.publishSubmitted, AppColors.success);
    _loadPublications();
  }

  Future<void> _removeFromStore(PublicProgram program) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(program.status == PublicProgramStatus.pending
            ? l10n.withdrawSubmission
            : l10n.removeFromStore),
        content: Text(l10n.unpublishConfirm(program.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _storeService.remove(program.id);
      if (!mounted) return;
      setState(() => _publications.remove(program.sourceWorkoutId));
      _showSnack(l10n.unpublished, AppColors.success);
    } on StoreOfflineException {
      if (mounted) _showSnack(l10n.noInternetAction, AppColors.error);
    } catch (e) {
      debugPrint('[WORKSHOP_SCREEN] remove from store failed: $e');
      if (mounted) _showSnack(l10n.publishFailed, AppColors.error);
    }
  }

  void _showSnack(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }

  PopupMenuItem<void> _storeMenuItem(_StoreAction action, Workout workout) {
    final l10n = AppLocalizations.of(context)!;
    final (IconData icon, String label, Color? color) = switch (action) {
      _StoreAction.publish => (Icons.cloud_upload_outlined, l10n.publishToStore, null),
      _StoreAction.resubmit => (Icons.replay, l10n.resubmitProgram, null),
      _StoreAction.update => (Icons.update, l10n.submitUpdate, null),
      _StoreAction.remove => (
          Icons.cloud_off,
          _publications[workout.id]?.status == PublicProgramStatus.pending
              ? l10n.withdrawSubmission
              : l10n.removeFromStore,
          AppColors.error,
        ),
    };
    return PopupMenuItem(
      onTap: () => Future.delayed(
        Duration.zero,
        () => _onStoreAction(action, workout),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Workout> get _filteredWorkouts {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _dataManager.workouts;
    return _dataManager.workouts
        .where((w) => w.name.toLowerCase().contains(query))
        .toList();
  }

  void _navigateToCreateWorkout() async {
    debugPrint('[WORKSHOP_SCREEN] Navigating to CreateWorkoutScreen...');
    final result = await Navigator.of(context).push<Workout>(
      MaterialPageRoute(builder: (context) => const CreateWorkoutScreen()),
    );

    debugPrint(
      '[WORKSHOP_SCREEN] Returned from CreateWorkoutScreen with: '
      '${result != null ? result.name : 'null'}',
    );
    if (result != null) {
      setState(() {
        debugPrint('[WORKSHOP_SCREEN] Calling addWorkout for: ${result.name}');
        _dataManager.addWorkout(result);
        debugPrint(
          '[WORKSHOP_SCREEN] Workouts after add: '
          '${_dataManager.workouts.map((w) => w.name).toList()}',
        );
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.workoutSaved(result.name)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _navigateToEditWorkout(Workout workout, int index) async {
    debugPrint(
      '[WORKSHOP_SCREEN] Navigating to edit workout: ${workout.name} (index: $index)',
    );
    final result = await Navigator.of(context).push<Workout>(
      MaterialPageRoute(
        builder: (context) => CreateWorkoutScreen(existingWorkout: workout),
      ),
    );

    debugPrint(
      '[WORKSHOP_SCREEN] Returned from edit with: ${result != null ? result.name : 'null'}',
    );
    if (result != null) {
      setState(() {
        debugPrint(
          '[WORKSHOP_SCREEN] Calling updateWorkout for: ${result.name}',
        );
        _dataManager.updateWorkout(index, result);
        debugPrint(
          '[WORKSHOP_SCREEN] Workouts after update: '
          '${_dataManager.workouts.map((w) => w.name).toList()}',
        );
      });
    }
  }

  void _deleteWorkout(int index) {
    debugPrint(
      '[WORKSHOP_SCREEN] Request to delete workout at index $index: ${_dataManager.workouts[index].name}',
    );
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteWorkout),
        content: Text(
          l10n.deleteWorkoutConfirm(_dataManager.workouts[index].name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                debugPrint(
                  '[WORKSHOP_SCREEN] Calling removeWorkout for: ${_dataManager.workouts[index].name}',
                );
                _dataManager.removeWorkout(index);
                debugPrint(
                  '[WORKSHOP_SCREEN] Workouts after remove: '
                  '${_dataManager.workouts.map((w) => w.name).toList()}',
                );
              });
              Navigator.of(context).pop();
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _startWorkout(Workout workout) async {
    final recommendationService = Provider.of<WorkoutRecommendationService>(
      context,
      listen: false,
    );
    final adjustedWorkout = await recommendationService.getAdjustedWorkout(
      workout,
    );

    if (!mounted) return;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutExecutionScreen(workout: adjustedWorkout),
      ),
    );

    if (result != null) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutCompleted),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          l10n.workshop,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<_WorkshopView>(
                segments: [
                  ButtonSegment(
                    value: _WorkshopView.workouts,
                    icon: const Icon(Icons.fitness_center),
                    label: Text(l10n.workshopViewWorkouts),
                  ),
                  ButtonSegment(
                    value: _WorkshopView.exercises,
                    icon: const Icon(Icons.list_alt),
                    label: Text(l10n.workshopViewExercises),
                  ),
                ],
                selected: {_view},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  FocusScope.of(context).unfocus();
                  setState(() => _view = selection.first);
                },
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _view.index,
              children: [
                _buildWorkoutsView(l10n),
                const ExerciseLibraryScreen(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsView(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.createYourWorkout,
          style: AppTextStyles.h3.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.customizeTrainingProgram,
          style: AppTextStyles.body2.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _navigateToCreateWorkout,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.createNewWorkout,
                    style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchWorkouts,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.myWorkouts,
          style: AppTextStyles.h4.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        if (_dataManager.workouts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n.noWorkoutsYet,
                style: AppTextStyles.body2.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (_filteredWorkouts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                AppLocalizations.of(context)!.noWorkoutsFound,
                style: AppTextStyles.body2.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ..._filteredWorkouts.map((workout) {
            final index = _dataManager.workouts.indexOf(workout);
            return _buildWorkoutCard(workout, index);
          }),
      ],
    );
  }

  Widget _buildWorkoutCard(Workout workout, int index) {
    final isExpanded = _expandedWorkouts.contains(workout.id);
    final publication = _publications[workout.id];
    final storeActions = _storeActionsFor(workout);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedWorkouts.remove(workout.id);
              } else {
                _expandedWorkouts.add(workout.id);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.exercisesCount(workout.exercises.length),
                          style: AppTextStyles.caption.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        if (publication != null) ...[
                          const SizedBox(height: 6),
                          StoreChip(
                            label: publication.status
                                .label(AppLocalizations.of(context)!),
                            icon: publication.status.icon,
                            color: publication.status.color,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.play_arrow, size: 20),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.start),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(
                            Duration.zero,
                            () => _startWorkout(workout),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.edit),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(
                            Duration.zero,
                            () => _navigateToEditWorkout(workout, index),
                          );
                        },
                      ),
                      for (final action in storeActions)
                        _storeMenuItem(action, workout),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              size: 20,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.delete,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(
                            Duration.zero,
                            () => _deleteWorkout(index),
                          );
                        },
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (publication?.status == PublicProgramStatus.rejected &&
                    publication?.rejectionReason != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Text(
                      AppLocalizations.of(context)!
                          .rejectionReasonLabel(publication!.rejectionReason!),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                MuscleLoadPanel(workout: workout),
                WorkoutAiEvaluation(workout: workout),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}
