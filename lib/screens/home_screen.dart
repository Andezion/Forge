import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import 'package:provider/provider.dart';
import '../services/data_manager.dart';
import '../services/workout_recommendation_service.dart';
import '../models/workout.dart';
import '../models/workout_recommendation.dart';
import '../widgets/compact_calendar.dart';
import '../widgets/muscle_recovery_card.dart';
import 'workout_execution_screen.dart';
import 'full_calendar_screen.dart';

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
    if (_dataManager.workouts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No workouts available. Create one in Workshop!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    Workout? recommendedWorkout;
    if (_todayRecommendation != null) {
      recommendedWorkout = _dataManager.workouts.firstWhere(
        (w) => w.id == _todayRecommendation!.workoutId,
        orElse: () => _dataManager.workouts.first,
      );
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
                  if (recommendedWorkout != null) ...[
                    Text(
                      'Recommended for Today',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_todayRecommendation!.overallReason.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _todayRecommendation!.overallReason,
                          style: AppTextStyles.caption.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    _buildWorkoutTile(
                      recommendedWorkout,
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
                      .where((w) => w.id != recommendedWorkout?.id)
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
          ? AppColors.primary.withValues(alpha: 0.1)
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
                ],
              ),
            ),
          ),
        ],
      ),
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
                'No recommendation available',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create workouts in Workshop to get personalized recommendations',
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

    switch (_todayRecommendation!.level) {
      case RecommendationLevel.rest:
        levelIcon = Icons.hotel;
        levelColor = AppColors.textSecondary;
        levelText = 'Rest Day';
        break;
      case RecommendationLevel.light:
        levelIcon = Icons.wb_sunny_outlined;
        levelColor = AppColors.success;
        levelText = 'Light';
        break;
      case RecommendationLevel.moderate:
        levelIcon = Icons.fitness_center;
        levelColor = AppColors.warning;
        levelText = 'Moderate';
        break;
      case RecommendationLevel.intense:
        levelIcon = Icons.local_fire_department;
        levelColor = AppColors.error;
        levelText = 'Intense';
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
              'Exercises:',
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
                    ? ' @ ${exerciseRec.exercise.weight}kg'
                    : '',
              );
            }),
            if (_todayRecommendation!.exercises.length > 4)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+ ${_todayRecommendation!.exercises.length - 4} more exercises',
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
