import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../models/workout.dart';
import '../services/data_manager.dart';
import 'create_workout_screen.dart';
import 'workout_execution_screen.dart';

class WorkshopScreen extends StatefulWidget {
  const WorkshopScreen({super.key});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  final _dataManager = DataManager();

  void _navigateToCreateWorkout() async {
    final result = await Navigator.of(context).push<Workout>(
      MaterialPageRoute(
        builder: (context) => const CreateWorkoutScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _dataManager.addWorkout(result);
      });
    }
  }

  void _navigateToEditWorkout(Workout workout, int index) async {
    final result = await Navigator.of(context).push<Workout>(
      MaterialPageRoute(
        builder: (context) => CreateWorkoutScreen(existingWorkout: workout),
      ),
    );

    if (result != null) {
      setState(() {
        _dataManager.updateWorkout(index, result);
      });
    }
  }

  void _deleteWorkout(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text(
            'Are you sure you want to delete "${_dataManager.workouts[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _dataManager.removeWorkout(index);
              });
              Navigator.of(context).pop();
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _startWorkout(Workout workout) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutExecutionScreen(workout: workout),
      ),
    );

    if (result != null) {
      // TODO: Handle completed workout session
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout completed!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            'Create Your Workout',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your training program',
            style: AppTextStyles.body2,
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
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create New Workout',
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
            'My Workouts',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 12),
          if (_dataManager.workouts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No workouts yet. Create your first workout!',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
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

  Widget _buildWorkoutCard(Workout workout, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.fitness_center,
              color: AppColors.primary, size: 28),
        ),
        title: Text(
          workout.name,
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${workout.exercises.length} exercises',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        trailing: PopupMenuButton(
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
                Future.delayed(Duration.zero, () => _startWorkout(workout));
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
                  const Icon(Icons.delete, size: 20, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text(AppStrings.delete,
                      style: const TextStyle(color: AppColors.error)),
                ],
              ),
              onTap: () {
                Future.delayed(Duration.zero, () => _deleteWorkout(index));
              },
            ),
          ],
        ),
        onTap: () => _startWorkout(workout),
      ),
    );
  }
}
