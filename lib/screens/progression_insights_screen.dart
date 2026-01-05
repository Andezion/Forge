import 'package:flutter/material.dart';
import '../services/progression_service.dart';
import '../services/data_manager.dart';
import '../models/workout.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ProgressionInsightsScreen extends StatefulWidget {
  final Workout workout;

  const ProgressionInsightsScreen({
    super.key,
    required this.workout,
  });

  @override
  State<ProgressionInsightsScreen> createState() =>
      _ProgressionInsightsScreenState();
}

class _ProgressionInsightsScreenState extends State<ProgressionInsightsScreen> {
  final _progressionService = ProgressionService();
  final _dataManager = DataManager();

  bool _isLoading = true;
  Workout? _suggestedWorkout;
  Map<String, String>? _reasons;
  bool _needsDeload = false;
  Map<String, ProgressMetrics>? _exerciseMetrics;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoading = true);

    try {
      await _dataManager.initialize();
      final histories = _dataManager.workoutHistory;

      final result = await _progressionService.suggestNextWorkout(
        widget.workout,
        histories,
        lookback: 5,
      );

      final metrics = <String, ProgressMetrics>{};
      for (var exercise in widget.workout.exercises) {
        metrics[exercise.exercise.id] =
            _progressionService.analyzeExerciseHistory(
          exercise.exercise.id,
          histories,
          lookback: 5,
        );
      }

      setState(() {
        _suggestedWorkout = result['workout'] as Workout;
        _reasons = result['reasons'] as Map<String, String>;
        _needsDeload = result['needsDeload'] as bool;
        _exerciseMetrics = metrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Progression Recommendations'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_suggestedWorkout == null) {
      return const Center(
        child: Text('Not enough data for recommendations'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (_needsDeload) _buildDeloadWarning(),
        const SizedBox(height: 16),
        _buildWorkoutComparison(),
        const SizedBox(height: 24),
        _buildExerciseDetails(),
      ],
    );
  }

  Widget _buildDeloadWarning() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Deload Week!',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recent workouts have been hard. Reduce the load for recovery.',
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutComparison() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Workout Comparison', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  children: [
                    _buildTableHeader('Exercise'),
                    _buildTableHeader('Current'),
                    _buildTableHeader('Suggested'),
                  ],
                ),
                ...widget.workout.exercises.map((original) {
                  final suggested = _suggestedWorkout!.exercises.firstWhere(
                    (e) => e.exercise.id == original.exercise.id,
                  );
                  return _buildComparisonRow(original, suggested);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  TableRow _buildComparisonRow(
      WorkoutExercise original, WorkoutExercise suggested) {
    final weightChanged = original.weight != suggested.weight;
    final repsChanged = original.targetReps != suggested.targetReps;
    final setsChanged = original.sets != suggested.sets;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            original.exercise.name,
            style: AppTextStyles.body2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (original.weight > 0)
                Text('${original.weight.toStringAsFixed(1)} kg',
                    style: AppTextStyles.body2),
              Text('${original.sets}x${original.targetReps}',
                  style: AppTextStyles.body2),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (suggested.weight > 0)
                Text(
                  '${suggested.weight.toStringAsFixed(1)} kg',
                  style: AppTextStyles.body2.copyWith(
                    color: weightChanged ? Colors.green : null,
                    fontWeight: weightChanged ? FontWeight.bold : null,
                  ),
                ),
              Text(
                '${suggested.sets}x${suggested.targetReps}',
                style: AppTextStyles.body2.copyWith(
                  color: (repsChanged || setsChanged) ? Colors.green : null,
                  fontWeight:
                      (repsChanged || setsChanged) ? FontWeight.bold : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detailed analysis', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        ...widget.workout.exercises.map((exercise) {
          final metrics = _exerciseMetrics![exercise.exercise.id];
          final reason = _reasons![exercise.exercise.id] ?? 'No data';
          return _buildExerciseCard(exercise, metrics!, reason);
        }),
      ],
    );
  }

  Widget _buildExerciseCard(
    WorkoutExercise exercise,
    ProgressMetrics metrics,
    String reason,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.exercise.name,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 12),
            _buildMetricRow('Reason for change:', reason),
            if (metrics.sessionsCount > 0) ...[
              const Divider(height: 24),
              _buildMetricRow(
                'Completed in recent workouts:',
                '${(metrics.completionRate * 100).toStringAsFixed(0)}%',
              ),
              _buildMetricRow(
                'Average weight:',
                '${metrics.avgWeight.toStringAsFixed(1)} kg',
              ),
              _buildMetricRow(
                'Average reps:',
                metrics.avgRepsPerSet.toStringAsFixed(1),
              ),
              if (metrics.estimated1RM > 0)
                _buildMetricRow(
                  'Estimated 1RM:',
                  '${metrics.estimated1RM.toStringAsFixed(1)} kg',
                ),
              _buildMetricRow(
                'Weight trend:',
                metrics.weightTrend > 0
                    ? '↑ Rising (+${metrics.weightTrend.toStringAsFixed(1)} kg)'
                    : metrics.weightTrend < 0
                        ? '↓ Falling (${metrics.weightTrend.toStringAsFixed(1)} kg)'
                        : '→ Stable',
                color: metrics.weightTrend > 0
                    ? Colors.green
                    : metrics.weightTrend < 0
                        ? Colors.red
                        : null,
              ),
              _buildMetricRow(
                'Days since last session:',
                metrics.daysSinceLastSession.toString(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
