import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/workout.dart';
import '../models/workout_recommendation.dart';
import '../services/workout_recommendation_service.dart';
import '../models/exercise.dart';

class WorkoutSelectionScreen extends StatefulWidget {
  final void Function(Workout) onWorkoutSelected;

  const WorkoutSelectionScreen({
    super.key,
    required this.onWorkoutSelected,
  });

  @override
  State<WorkoutSelectionScreen> createState() => _WorkoutSelectionScreenState();
}

class _WorkoutSelectionScreenState extends State<WorkoutSelectionScreen> {
  List<(Workout, double)>? _scoredWorkouts;
  WorkoutRecommendation? _recommendation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final service = Provider.of<WorkoutRecommendationService>(
      context,
      listen: false,
    );
    final scored = await service.scoreAllWorkoutsForToday();
    final rec = await service.generateTodaysRecommendation();
    if (mounted) {
      setState(() {
        _scoredWorkouts = scored;
        _recommendation = rec;
        _isLoading = false;
      });
    }
  }

  Color _matchColor(double percent) {
    if (percent < 20) return const Color(0xFFF44336);
    if (percent < 40) return const Color(0xFFFF9800);
    if (percent < 60) return const Color(0xFFFFEB3B);
    if (percent < 80) return const Color(0xFF8BC34A);
    return const Color(0xFF4CAF50);
  }

  String _matchLabel(double percent) {
    if (percent < 20) return 'Poor match';
    if (percent < 40) return 'Fair match';
    if (percent < 60) return 'Moderate match';
    if (percent < 80) return 'Good match';
    return 'Great match';
  }

  Set<String> _getMuscleGroupNames(Workout workout) {
    final groups = <String>{};
    for (final ex in workout.exercises) {
      for (final mg in ex.exercise.muscleGroups) {
        if (mg.intensity == MuscleGroupIntensity.primary) {
          groups.add(_muscleGroupDisplayName(mg.group));
        }
      }
    }
    return groups;
  }

  static String _muscleGroupDisplayName(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.legs:
        return 'Legs';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.wrists:
        return 'Wrists';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.cardio:
        return 'Cardio';
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
          'Select Workout',
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final scored = _scoredWorkouts ?? [];
    if (scored.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'No workouts available',
              style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a workout in Workshop first',
              style: AppTextStyles.body2,
            ),
          ],
        ),
      );
    }

    final recommendedId = _recommendation?.workoutId;
    final recommended =
        recommendedId != null ? scored.where((s) => s.$1.id == recommendedId).firstOrNull : null;
    final others = scored.where((s) => s.$1.id != recommendedId).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (recommended != null) ...[
          _buildSectionHeader('Recommended for Today', AppColors.primary),
          const SizedBox(height: 8),
          _buildWorkoutCard(recommended.$1, recommended.$2, isRecommended: true),
          if (_recommendation?.overallReason.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16, left: 4, right: 4),
              child: Text(
                _recommendation!.overallReason,
                style: AppTextStyles.caption.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            const SizedBox(height: 16),
          _buildSectionHeader('All Workouts', AppColors.textSecondary),
          const SizedBox(height: 8),
        ],
        ...others.map((entry) => _buildWorkoutCard(entry.$1, entry.$2)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: AppTextStyles.body1.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout, double matchPercent,
      {bool isRecommended = false}) {
    final color = _matchColor(matchPercent);
    final muscles = _getMuscleGroupNames(workout);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRecommended ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isRecommended
            ? BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pop();
          widget.onWorkoutSelected(workout);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isRecommended
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: isRecommended
                          ? AppColors.primary
                          : AppColors.textSecondary,
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
                        const SizedBox(height: 2),
                        Text(
                          '${workout.exercises.length} exercises',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  _buildMatchBadge(matchPercent, color),
                ],
              ),
              if (muscles.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: muscles.take(5).map((m) => _buildMuscleChip(m)).toList(),
                ),
              ],
              const SizedBox(height: 12),
              _buildMatchBar(matchPercent, color),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _matchLabel(matchPercent),
                    style: AppTextStyles.caption.copyWith(color: color),
                  ),
                  Row(
                    children: [
                      Text(
                        'Start',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.play_arrow,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchBadge(double percent, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '${percent.round()}%',
        style: AppTextStyles.body2.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildMatchBar(double percent, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: percent / 100,
        backgroundColor: color.withValues(alpha: 0.15),
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 6,
      ),
    );
  }

  Widget _buildMuscleChip(String muscle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        muscle,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
