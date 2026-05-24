import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../services/data_manager.dart';
import '../services/workout_recommendation_service.dart';
import '../models/workout.dart';
import '../models/workout_recommendation.dart';
import '../models/training_plan.dart';
import '../services/tour_service.dart';
import '../widgets/compact_calendar.dart';
import '../widgets/muscle_recovery_card.dart';
import 'workout_execution_screen.dart';
import 'full_calendar_screen.dart';
import 'plan_editor_screen.dart';
import 'workout_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  WorkoutRecommendation? _todayRecommendation;
  bool _isLoadingRecommendation = false;

  DataManager get _dataManager =>
      Provider.of<DataManager>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _loadTodayRecommendation();
  }

  Future<void> _loadTodayRecommendation() async {
    setState(() {
      _isLoadingRecommendation = true;
    });

    try {
      final recommendationService = Provider.of<WorkoutRecommendationService>(
        context,
        listen: false,
      );
      final recommendation =
          await recommendationService.generateTodaysRecommendation();

      if (mounted) {
        setState(() {
          _todayRecommendation = recommendation;
          _isLoadingRecommendation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendation = false;
        });
      }
    }
  }

  void _showWorkoutSelectionDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutSelectionScreen(
          onWorkoutSelected: _startWorkout,
        ),
      ),
    );
  }

  void _startWorkout(Workout workout) async {
    if (workout.exercises.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noExercisesInWorkout),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final recommendationService = Provider.of<WorkoutRecommendationService>(
      context,
      listen: false,
    );
    final adjustedWorkout = await recommendationService.getAdjustedWorkout(workout);

    if (!mounted) return;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutExecutionScreen(workout: adjustedWorkout),
      ),
    );

    if (result != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.workoutCompleted),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final workoutsThisMonth = dataManager.workoutsThisMonth();
    final currentStreak = dataManager.currentStreak();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          AppLocalizations.of(context)!.home,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<TourService>(context, listen: false).startTour();
            },
            icon: const Icon(Icons.explore_outlined),
            color: AppColors.textOnPrimary,
            tooltip: AppLocalizations.of(context)!.tourRestartTooltip,
          ),
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FullCalendarScreen(),
                ),
              );
            },
            child: CompactCalendar(
              focusedDay: _selectedDate,
              onDaySelected: (selectedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActivePlanBanner(dataManager),
                  Text(
                    AppLocalizations.of(context)!.todaysWorkout,
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),
                  _buildWorkoutCard(),
                  const SizedBox(height: 8),
                  _buildMuscleRecoveryCompact(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showWorkoutSelectionDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.startWorkout,
                            style: AppTextStyles.button,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.statistics,
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          AppLocalizations.of(context)!.workoutsThisMonth,
                          workoutsThisMonth.toString(),
                          Icons.fitness_center,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          AppLocalizations.of(context)!.dayStreak,
                          currentStreak.toString(),
                          Icons.local_fire_department,
                          AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTrainingPlansSection(dataManager),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlanBanner(DataManager dataManager) {
    final activePlan = dataManager.activePlan;
    if (activePlan == null) return const SizedBox.shrink();

    final today = DateTime.now();
    final todayWorkouts = activePlan.workoutsForDate(today);

    if (todayWorkouts.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.event_available, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              '${activePlan.name}: ${AppLocalizations.of(context)!.restDayToday}',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_note, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.of(context)!.todayFromPlan,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '· ${activePlan.name}',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (todayWorkouts.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              AppLocalizations.of(context)!.chooseOne,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ...List.generate(todayWorkouts.length, (idx) {
          final sw = todayWorkouts[idx];
          final workout = dataManager.workouts
              .where((w) => w.id == sw.workoutId)
              .firstOrNull;
          return Column(
            children: [
              if (idx > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                          child: Divider(color: AppColors.divider, height: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          AppLocalizations.of(context)!.or,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Divider(color: AppColors.divider, height: 1)),
                    ],
                  ),
                ),
              Card(
                margin: const EdgeInsets.only(bottom: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                ),
                child: ListTile(
                  leading:
                      Icon(Icons.fitness_center, color: AppColors.primary),
                  title: Text(sw.workoutName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: workout != null
                      ? Text(AppLocalizations.of(context)!.exercisesCount(workout.exercises.length))
                      : null,
                  trailing: workout != null
                      ? ElevatedButton(
                          onPressed: () => _startWorkout(workout),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(AppLocalizations.of(context)!.startWorkout,
                              style: const TextStyle(fontSize: 12)),
                        )
                      : null,
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildWorkoutCard() {
    if (_isLoadingRecommendation) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(48),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_todayRecommendation == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.fitness_center,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.noRecommendationAvailable,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.createWorkoutsForRecommendations,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final workout = _dataManager.workouts.firstWhere(
      (w) => w.id == _todayRecommendation!.workoutId,
      orElse: () => _dataManager.workouts.first,
    );

    IconData levelIcon;
    Color levelColor;
    String levelText;

    final l10n = AppLocalizations.of(context)!;
    switch (_todayRecommendation!.level) {
      case RecommendationLevel.rest:
        levelIcon = Icons.hotel;
        levelColor = AppColors.textSecondary;
        levelText = l10n.restDayLevel;
        break;
      case RecommendationLevel.light:
        levelIcon = Icons.wb_sunny_outlined;
        levelColor = AppColors.success;
        levelText = l10n.lightLevel;
        break;
      case RecommendationLevel.moderate:
        levelIcon = Icons.fitness_center;
        levelColor = AppColors.warning;
        levelText = l10n.moderateLevel;
        break;
      case RecommendationLevel.intense:
        levelIcon = Icons.local_fire_department;
        levelColor = AppColors.error;
        levelText = l10n.intenseLevel;
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: AppTextStyles.h4,
                      ),
                      Row(
                        children: [
                          Icon(
                            levelIcon,
                            size: 14,
                            color: levelColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            levelText,
                            style: AppTextStyles.caption.copyWith(
                              color: levelColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(_todayRecommendation!.overallConfidence * 100).toInt()}% confidence',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_todayRecommendation!.overallReason.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _todayRecommendation!.overallReason,
                        style: AppTextStyles.caption.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              l10n.exercisesColonLabel,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ..._todayRecommendation!.exercises.take(4).map((exerciseRec) {
              return _buildExerciseItem(
                exerciseRec.exercise.exercise.name,
                '${exerciseRec.exercise.sets}x${exerciseRec.exercise.targetReps}',
                exerciseRec.exercise.weight > 0
                    ? ' with ${exerciseRec.exercise.weight} kg'
                    : '',
              );
            }),
            if (_todayRecommendation!.exercises.length > 4)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.moreExercises(_todayRecommendation!.exercises.length - 4),
                  style: AppTextStyles.caption.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(String name, String sets, [String weight = '']) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.body2,
            ),
          ),
          Text(
            '$sets$weight',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.h2.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingPlansSection(DataManager dataManager) {
    final plans = dataManager.trainingPlans;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)!.trainingPlans, style: AppTextStyles.h4),
            const Spacer(),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PlanEditorScreen()),
              ),
              icon: Icon(Icons.add, size: 18, color: AppColors.primary),
              label: Text(AppLocalizations.of(context)!.createPlan),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (plans.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 40, color: AppColors.textSecondary),
                const SizedBox(height: 10),
                Text(AppLocalizations.of(context)!.noPlansYet,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.createPlanDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PlanEditorScreen()),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(AppLocalizations.of(context)!.createPlan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          )
        else
          ...plans.map((plan) => _buildHomePlanCard(dataManager, plan)),
      ],
    );
  }

  Widget _buildHomePlanCard(DataManager dataManager, TrainingPlan plan) {
    final isActive = plan.isActive;
    final activeDays = <int>{};
    for (final sw in plan.schedule) {
      activeDays.addAll(sw.daysOfWeek);
    }
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.activeLabel,
                      style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'activate') dataManager.setActivePlan(plan.id);
                    if (v == 'deactivate') dataManager.setActivePlan(null);
                    if (v == 'edit') {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              PlanEditorScreen(existingPlan: plan)));
                    }
                    if (v == 'delete') {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          final dl = AppLocalizations.of(ctx)!;
                          return AlertDialog(
                            title: Text(dl.deletePlan),
                            content: Text(dl.deletePlanConfirm(plan.name)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text(dl.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  dataManager.removeTrainingPlan(plan.id);
                                  Navigator.of(ctx).pop();
                                },
                                child: Text(dl.delete,
                                    style: const TextStyle(color: AppColors.error)),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  itemBuilder: (_) {
                    final pm = AppLocalizations.of(context)!;
                    return [
                      if (!isActive)
                        PopupMenuItem(
                            value: 'activate',
                            child: Text(pm.activatePlan)),
                      if (isActive)
                        PopupMenuItem(
                            value: 'deactivate',
                            child: Text(pm.deactivatePlan)),
                      PopupMenuItem(
                          value: 'edit', child: Text(pm.edit)),
                      PopupMenuItem(
                          value: 'delete',
                          child: Text(pm.delete,
                              style: const TextStyle(color: AppColors.error))),
                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(7, (i) {
                final day = i + 1;
                final has = activeDays.contains(day);
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: has ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayNames[i],
                      style: TextStyle(
                        color: has
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (plan.schedule.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                plan.schedule.map((sw) => sw.workoutName).join(' · '),
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleRecoveryCompact() {
    try {
      final recommendationService = Provider.of<WorkoutRecommendationService>(
        context,
        listen: false,
      );

      final daysSinceTraining =
          recommendationService.getDaysSinceLastTraining();
      final recoveryPriorities =
          recommendationService.getMuscleRecoveryPriorities();

      return MuscleRecoveryCompact(
        daysSinceTraining: daysSinceTraining,
        recoveryPriorities: recoveryPriorities,
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}
