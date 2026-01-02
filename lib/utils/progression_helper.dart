import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/workout_history.dart';
import '../services/progression_service.dart';
import '../services/data_manager.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ProgressionHelper {
  static final _progressionService = ProgressionService();

  static Future<Workout?> suggestOptimizedWorkout(
    BuildContext context,
    Workout originalWorkout,
    DataManager dataManager,
  ) async {
    try {
      final histories = dataManager.workoutHistory;

      if (histories.length < 2) {
        return originalWorkout;
      }

      final result = await _progressionService.suggestNextWorkout(
        originalWorkout,
        histories,
      );

      final optimizedWorkout = result['workout'] as Workout;
      final reasons = result['reasons'] as Map<String, String>;
      final needsDeload = result['needsDeload'] as bool;

      bool hasChanges = false;
      for (int i = 0; i < originalWorkout.exercises.length; i++) {
        final original = originalWorkout.exercises[i];
        final optimized = optimizedWorkout.exercises[i];

        if (original.weight != optimized.weight ||
            original.targetReps != optimized.targetReps ||
            original.sets != optimized.sets) {
          hasChanges = true;
          break;
        }
      }

      if (!hasChanges && !needsDeload) {
        return originalWorkout;
      }

      final shouldUseOptimized = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _OptimizationDialog(
          originalWorkout: originalWorkout,
          optimizedWorkout: optimizedWorkout,
          reasons: reasons,
          needsDeload: needsDeload,
        ),
      );

      return shouldUseOptimized == true ? optimizedWorkout : originalWorkout;
    } catch (e) {
      debugPrint('Error in suggestOptimizedWorkout: $e');
      return originalWorkout;
    }
  }

  static Future<void> showExerciseProgressTip(
    BuildContext context,
    String exerciseId,
    List<WorkoutHistory> histories,
  ) async {
    final metrics = _progressionService.analyzeExerciseHistory(
      exerciseId,
      histories,
      lookback: 5,
    );

    if (metrics.sessionsCount == 0) return;

    String message = '';
    IconData icon = Icons.info;
    Color color = Colors.blue;

    if (metrics.performanceTrend > 5.0) {
      message = 'Отличный прогресс! Производительность растёт 📈';
      icon = Icons.trending_up;
      color = Colors.green;
    } else if (metrics.performanceTrend < -5.0) {
      message = 'Производительность снижается. Возможно, нужен отдых 😔';
      icon = Icons.trending_down;
      color = Colors.orange;
    } else if (metrics.completionRate >= 0.95) {
      message =
          'Отличное выполнение! ${(metrics.completionRate * 100).toStringAsFixed(0)}% 💪';
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (metrics.completionRate < 0.75) {
      message = 'Сложновато. Может, снизить вес? 🤔';
      icon = Icons.warning;
      color = Colors.orange;
    }

    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static double getWeightChange(
      WorkoutExercise original, WorkoutExercise optimized) {
    if (original.weight == 0) return 0;
    return ((optimized.weight - original.weight) / original.weight) * 100;
  }
}

class _OptimizationDialog extends StatelessWidget {
  final Workout originalWorkout;
  final Workout optimizedWorkout;
  final Map<String, String> reasons;
  final bool needsDeload;

  const _OptimizationDialog({
    required this.originalWorkout,
    required this.optimizedWorkout,
    required this.reasons,
    required this.needsDeload,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            needsDeload ? Icons.warning_amber : Icons.auto_awesome,
            color: needsDeload ? Colors.orange : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              needsDeload ? 'Разгрузочная неделя' : 'Оптимизация тренировки',
              style: AppTextStyles.heading2,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (needsDeload) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Последние тренировки были тяжёлыми. Рекомендуем снизить нагрузку для восстановления.',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'На основе ваших предыдущих тренировок, мы рекомендуем:',
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: 16),
            ...originalWorkout.exercises.map((original) {
              final optimized = optimizedWorkout.exercises.firstWhere(
                (e) => e.exercise.id == original.exercise.id,
              );
              return _buildExerciseComparison(original, optimized);
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Использовать оригинал'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Применить рекомендации'),
        ),
      ],
    );
  }

  Widget _buildExerciseComparison(
    WorkoutExercise original,
    WorkoutExercise optimized,
  ) {
    final weightChanged = original.weight != optimized.weight;
    final repsChanged = original.targetReps != optimized.targetReps;
    final setsChanged = original.sets != optimized.sets;
    final hasChanges = weightChanged || repsChanged || setsChanged;

    if (!hasChanges) return const SizedBox.shrink();

    final weightChange = ProgressionHelper.getWeightChange(original, optimized);
    final reason = reasons[original.exercise.id] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            original.exercise.name,
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Было:', style: AppTextStyles.caption),
                    Text(
                      _formatExercise(original),
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Станет:', style: AppTextStyles.caption),
                    Text(
                      _formatExercise(optimized),
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (weightChanged && weightChange.abs() > 0.1) ...[
            const SizedBox(height: 4),
            Text(
              '${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)}%',
              style: AppTextStyles.caption.copyWith(
                color: weightChange > 0 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              reason,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatExercise(WorkoutExercise e) {
    final weight = e.weight > 0 ? '${e.weight.toStringAsFixed(1)}kg ' : '';
    return '$weight${e.sets}×${e.targetReps}';
  }
}
