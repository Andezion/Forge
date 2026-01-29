import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../services/data_manager.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);

    final armwrestlingWorkouts = dataManager.workouts
        .where((w) => w.id.startsWith('armwrestling_'))
        .toList();
    final streetliftingWorkouts = dataManager.workouts
        .where((w) => w.id.startsWith('streetlifting_'))
        .toList();
    final powerliftingWorkouts = dataManager.workouts
        .where((w) => w.id.startsWith('powerlifting_'))
        .toList();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          AppStrings.programs,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Select a training program',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),
          _buildProgramCategory(
            context,
            AppStrings.streetlifting,
            'Bodyweight training',
            Icons.sports_gymnastics,
            AppColors.streetlifting,
            streetliftingWorkouts,
          ),
          const SizedBox(height: 16),
          _buildProgramCategory(
            context,
            AppStrings.armwrestling,
            'Specialized training',
            Icons.back_hand,
            AppColors.armwrestling,
            armwrestlingWorkouts,
          ),
          const SizedBox(height: 16),
          _buildProgramCategory(
            context,
            AppStrings.powerlifting,
            'Programs for maximum strength',
            Icons.fitness_center,
            AppColors.powerlifting,
            powerliftingWorkouts,
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCategory(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    List<Workout> workouts,
  ) {
    if (workouts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          title: Text(
            title,
            style: AppTextStyles.h4.copyWith(color: color),
          ),
          subtitle: Text(
            description,
            style: AppTextStyles.caption,
          ),
          children: [
            SizedBox(
              height: 200,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        _showWorkoutDetails(context, workout, color);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.fitness_center, color: color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      workout.name,
                                      style: AppTextStyles.body1.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${workout.exercises.length} exercises',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  WorkoutSession? _findLastSessionForWorkout(
      DataManager dataManager, String workoutId) {
    final history = dataManager.workoutHistory;
    for (var i = history.length - 1; i >= 0; i--) {
      if (history[i].session.workoutId == workoutId) {
        return history[i].session;
      }
    }
    return null;
  }

  void _showWorkoutDetails(BuildContext context, Workout workout, Color color) {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final lastSession = _findLastSessionForWorkout(dataManager, workout.id);
    final completedExerciseIds = lastSession != null
        ? lastSession.exerciseResults.map((r) => r.exercise.id).toSet()
        : <String>{};
    final hasHistory = lastSession != null;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  workout.name,
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exercises:',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...workout.exercises.map((we) {
                          final wasCompleted = !hasHistory ||
                              completedExerciseIds.contains(we.exercise.id);
                          final exerciseColor =
                              wasCompleted ? color : AppColors.error;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: exerciseColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    wasCompleted ? Icons.check : Icons.close,
                                    color: exerciseColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        we.exercise.name,
                                        style: AppTextStyles.body2.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: wasCompleted
                                              ? null
                                              : AppColors.error,
                                        ),
                                      ),
                                      Text(
                                        '${we.sets} sets × ${we.targetReps} reps${we.weight > 0 ? ' @ ${we.weight}kg' : ''}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: wasCompleted
                                              ? null
                                              : AppColors.error
                                                  .withValues(alpha: 0.7),
                                        ),
                                      ),
                                      if (!wasCompleted)
                                        Text(
                                          'Not completed last time',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.error,
                                            fontStyle: FontStyle.italic,
                                            fontSize: 10,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Program "${workout.name}" selected'),
                              backgroundColor: color,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Select Program'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
