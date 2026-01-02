import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import 'package:provider/provider.dart';
import '../services/data_manager.dart';
import '../models/workout.dart';
import '../widgets/compact_calendar.dart';
import 'workout_execution_screen.dart';
import 'full_calendar_screen.dart';
import 'progress_charts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  DataManager get _dataManager =>
      Provider.of<DataManager>(context, listen: false);

  void _showWorkoutSelectionDialog() {
    if (_dataManager.workouts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No workouts available. Create one in Workshop!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Select Workout',
                    style: AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_dataManager.getTodayWorkout() != null) ...[
                    Text(
                      'Recommended for Today',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildWorkoutTile(
                      _dataManager.getTodayWorkout()!,
                      isRecommended: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'All Workouts',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._dataManager.workouts
                      .map((workout) => _buildWorkoutTile(workout)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutTile(Workout workout, {bool isRecommended = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isRecommended
          ? AppColors.primary.withOpacity(0.1)
          : AppColors.surface,
      child: ListTile(
        leading: Icon(
          Icons.fitness_center,
          color: isRecommended ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          workout.name,
          style: AppTextStyles.body1.copyWith(
            fontWeight: isRecommended ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('${workout.exercises.length} exercises'),
        trailing: const Icon(Icons.play_arrow),
        onTap: () {
          Navigator.of(context).pop();
          _startWorkout(workout);
        },
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
    final dataManager = Provider.of<DataManager>(context);
    final workoutsThisMonth = dataManager.workoutsThisMonth();
    final currentStreak = dataManager.currentStreak();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          AppStrings.home,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
        elevation: 0,
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
                  Text(
                    'Today\'s Workout',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),
                  _buildWorkoutCard(),
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
                          const Icon(Icons.play_arrow),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.startWorkout,
                            style: AppTextStyles.button,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Statistics',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Workouts this month',
                          workoutsThisMonth.toString(),
                          Icons.fitness_center,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Day streak',
                          currentStreak.toString(),
                          Icons.local_fire_department,
                          AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProgressChartsScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      icon: const Icon(Icons.analytics),
                      label: const Text('Просмотр Графиков Прогресса'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard() {
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
                    color: AppColors.primary.withOpacity(0.1),
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
                        'Strength Training A',
                        style: AppTextStyles.h4,
                      ),
                      Text(
                        'Powerlifting',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Exercises:',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildExerciseItem('Squats', '4x8'),
            _buildExerciseItem('Bench Press', '4x8'),
            _buildExerciseItem('Deadlift', '3x5'),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(String name, String sets) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(name, style: AppTextStyles.body2),
          const Spacer(),
          Text(sets, style: AppTextStyles.caption),
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
}
