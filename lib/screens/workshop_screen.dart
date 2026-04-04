import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../services/data_manager.dart';
import '../services/workout_recommendation_service.dart';
import '../utils/muscle_group_utils.dart';
import '../widgets/workout_ai_evaluation.dart';
import 'create_workout_screen.dart';
import 'workout_execution_screen.dart';

class _MuscleStats {
  final int exerciseCount;
  final int setsCount;
  final double loadScore;

  const _MuscleStats({
    required this.exerciseCount,
    required this.setsCount,
    required this.loadScore,
  });
}

class WorkshopScreen extends StatefulWidget {
  const WorkshopScreen({super.key});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  final _dataManager = DataManager();
  final _expandedWorkouts = <String>{};

  void _navigateToCreateWorkout() async {
    debugPrint('[WORKSHOP_SCREEN] Navigating to CreateWorkoutScreen...');
    final result = await Navigator.of(context).push<Workout>(
      MaterialPageRoute(
        builder: (context) => const CreateWorkoutScreen(),
      ),
    );

    debugPrint('[WORKSHOP_SCREEN] Returned from CreateWorkoutScreen with: '
        '${result != null ? result.name : 'null'}');
    if (result != null) {
      setState(() {
        debugPrint('[WORKSHOP_SCREEN] Calling addWorkout for: ${result.name}');
        _dataManager.addWorkout(result);
        debugPrint('[WORKSHOP_SCREEN] Workouts after add: '
            '${_dataManager.workouts.map((w) => w.name).toList()}');
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
        '[WORKSHOP_SCREEN] Navigating to edit workout: ${workout.name} (index: $index)');
    final result = await Navigator.of(context).push<Workout>(
      MaterialPageRoute(
        builder: (context) => CreateWorkoutScreen(existingWorkout: workout),
      ),
    );

    debugPrint(
        '[WORKSHOP_SCREEN] Returned from edit with: ${result != null ? result.name : 'null'}');
    if (result != null) {
      setState(() {
        debugPrint(
            '[WORKSHOP_SCREEN] Calling updateWorkout for: ${result.name}');
        _dataManager.updateWorkout(index, result);
        debugPrint('[WORKSHOP_SCREEN] Workouts after update: '
            '${_dataManager.workouts.map((w) => w.name).toList()}');
      });
    }
  }

  void _deleteWorkout(int index) {
    debugPrint(
        '[WORKSHOP_SCREEN] Request to delete workout at index $index: ${_dataManager.workouts[index].name}');
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteWorkout),
        content:
            Text(l10n.deleteWorkoutConfirm(_dataManager.workouts[index].name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                debugPrint(
                    '[WORKSHOP_SCREEN] Calling removeWorkout for: ${_dataManager.workouts[index].name}');
                _dataManager.removeWorkout(index);
                debugPrint('[WORKSHOP_SCREEN] Workouts after remove: '
                    '${_dataManager.workouts.map((w) => w.name).toList()}');
              });
              Navigator.of(context).pop();
            },
            child: Text(l10n.delete,
                style: const TextStyle(color: AppColors.error)),
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
    final adjustedWorkout =
        await recommendationService.getAdjustedWorkout(workout);

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
          AppStrings.workshop,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
      ),
      body: ListView(
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
                      child: Icon(
                        Icons.add,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.createNewWorkout,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
          else
            ..._dataManager.workouts.asMap().entries.map((entry) {
              final index = entry.key;
              final workout = entry.value;
              return _buildWorkoutCard(workout, index);
            }),
        ],
      ),
    );
  }

  Map<MuscleGroup, _MuscleStats> _calculateMuscleData(Workout workout) {
    final result = <MuscleGroup, _MuscleStats>{};
    for (final we in workout.exercises) {
      for (final tag in we.exercise.muscleGroups) {
        final existing = result[tag.group];
        result[tag.group] = _MuscleStats(
          exerciseCount: (existing?.exerciseCount ?? 0) + 1,
          setsCount: (existing?.setsCount ?? 0) + we.sets,
          loadScore: (existing?.loadScore ?? 0.0) + tag.score * we.sets,
        );
      }
    }
    return result;
  }

  int _getIntensityLevel(double score) {
    if (score <= 3) return 1;
    if (score <= 8) return 2;
    if (score <= 15) return 3;
    if (score <= 24) return 4;
    return 5;
  }

  Color _getIntensityColor(int level) {
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

  Widget _buildMusclePanel(Map<MuscleGroup, _MuscleStats> muscleData) {
    if (muscleData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Text(
          'No muscle data available',
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      );
    }

    final sorted = muscleData.entries.toList()
      ..sort((a, b) => b.value.loadScore.compareTo(a.value.loadScore));

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Muscle Load',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...sorted.map((entry) {
            final stats = entry.value;
            final level = _getIntensityLevel(stats.loadScore);
            final color = _getIntensityColor(level);
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
                            )),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${stats.setsCount} sets',
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout, int index) {
    final isExpanded = _expandedWorkouts.contains(workout.id);
    final muscleData = _calculateMuscleData(workout);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                    child: Icon(Icons.fitness_center,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: AppTextStyles.body1
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!
                              .exercisesCount(workout.exercises.length),
                          style: AppTextStyles.caption.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
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
                            Text(AppStrings.start),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(
                              Duration.zero, () => _startWorkout(workout));
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(AppStrings.edit),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(Duration.zero,
                              () => _navigateToEditWorkout(workout, index));
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.delete,
                                size: 20, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(AppStrings.delete,
                                style: const TextStyle(color: AppColors.error)),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(
                              Duration.zero, () => _deleteWorkout(index));
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
                _buildMusclePanel(muscleData),
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
