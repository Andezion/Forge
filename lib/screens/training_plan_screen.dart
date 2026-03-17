import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/training_plan.dart';
import '../services/data_manager.dart';
import 'plan_editor_screen.dart';
import 'workout_execution_screen.dart';

class TrainingPlanScreen extends StatelessWidget {
  const TrainingPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataManager>(
      builder: (context, dataManager, _) {
        final plans = dataManager.trainingPlans;
        final activePlan = dataManager.activePlan;

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.trainingPlan),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: AppStrings.createPlan,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PlanEditorScreen()),
                ),
              ),
            ],
          ),
          body: plans.isEmpty
              ? _EmptyState(
                  onCreateTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlanEditorScreen()),
                  ),
                )
              : Column(
                  children: [
                    if (activePlan != null) _TodayCard(plan: activePlan),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: plans.length,
                        itemBuilder: (ctx, i) => _PlanCard(
                          plan: plans[i],
                          isActive: plans[i].isActive,
                          onActivate: () =>
                              dataManager.setActivePlan(plans[i].id),
                          onDeactivate: () => dataManager.setActivePlan(null),
                          onEdit: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PlanEditorScreen(existingPlan: plans[i]),
                            ),
                          ),
                          onDelete: () =>
                              _confirmDelete(context, dataManager, plans[i]),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, DataManager dataManager, TrainingPlan plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete plan?'),
        content: Text('Delete "${plan.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              dataManager.removeTrainingPlan(plan.id);
              Navigator.of(ctx).pop();
            },
            child: Text(AppStrings.delete,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;

  const _EmptyState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            AppStrings.noPlansYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a weekly training plan\nto follow a structured schedule.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.createPlan),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final TrainingPlan plan;

  const _TodayCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayWorkouts = plan.workoutsForDate(today);
    final dataManager = Provider.of<DataManager>(context, listen: false);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today, color: AppColors.textOnPrimary, size: 18),
              const SizedBox(width: 6),
              Text(
                AppStrings.todayFromPlan,
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                plan.name,
                style: TextStyle(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (todayWorkouts.isEmpty)
            Text(
              AppStrings.noWorkoutToday,
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          else ...[
            if (todayWorkouts.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Choose a workout:',
                  style: TextStyle(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                    fontSize: 13,
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
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: AppColors.textOnPrimary
                                      .withValues(alpha: 0.3),
                                  height: 1)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textOnPrimary
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(
                                  color: AppColors.textOnPrimary
                                      .withValues(alpha: 0.3),
                                  height: 1)),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sw.workoutName,
                                style: TextStyle(
                                  color: AppColors.textOnPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (workout != null)
                                Text(
                                  '${workout.exercises.length} exercises',
                                  style: TextStyle(
                                    color: AppColors.textOnPrimary
                                        .withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (workout != null)
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    WorkoutExecutionScreen(workout: workout),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textOnPrimary,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              AppStrings.startWorkout,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final TrainingPlan plan;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlanCard({
    required this.plan,
    required this.isActive,
    required this.onActivate,
    required this.onDeactivate,
    required this.onEdit,
    required this.onDelete,
  });

  static const _dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final activeDays = <int>{};
    for (final sw in plan.schedule) {
      activeDays.addAll(sw.daysOfWeek);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                Expanded(
                  child: Row(
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
                            'ACTIVE',
                            style: TextStyle(
                              color: AppColors.textOnPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Flexible(
                        child: Text(
                          plan.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'activate') onActivate();
                    if (v == 'deactivate') onDeactivate();
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    if (!isActive)
                      const PopupMenuItem(
                        value: 'activate',
                        child: Text(AppStrings.activatePlan),
                      ),
                    if (isActive)
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Text(AppStrings.deactivatePlan),
                      ),
                    const PopupMenuItem(
                        value: 'edit', child: Text(AppStrings.edit)),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          AppStrings.delete,
                          style: TextStyle(color: AppColors.error),
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(7, (i) {
                final day = i + 1;
                final hasWorkout = activeDays.contains(day);
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: hasWorkout ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _dayNames[i],
                      style: TextStyle(
                        color: hasWorkout
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
              const SizedBox(height: 10),
              Text(
                plan.schedule.map((sw) => sw.workoutName).join(' · '),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
