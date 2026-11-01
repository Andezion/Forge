import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/units.dart';
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
    _dataManager.addListener(_onDataChanged);
    _loadSuggestions();
  }

  @override
  void dispose() {
    _dataManager.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    debugPrint('[PROGRESSION_INSIGHTS] Data changed, reloading suggestions...');
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await _dataManager.initialize();
      final histories = _dataManager.workoutHistory;

      final result = await _progressionService.suggestNextWorkout(
        widget.workout,
        histories,
      );

      final metrics = <String, ProgressMetrics>{};
      for (var exercise in widget.workout.exercises) {
        metrics[exercise.exercise.id] =
            _progressionService.analyzeExerciseHistory(
          exercise.exercise.id,
          histories,
        );
      }

      if (mounted) {
        setState(() {
          _suggestedWorkout = result['workout'] as Workout;
          _reasons = result['reasons'] as Map<String, String>;
          _needsDeload = result['needsDeload'] as bool;
          _exerciseMetrics = metrics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorLoadingData('$e'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Units.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.progressionRecommendationsTitle),
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
      return Center(
        child: Text(AppLocalizations.of(context)!.notEnoughData),
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
                    AppLocalizations.of(context)!.recommendedDeloadWeek,
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.recommendedDeloadDesc,
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
            Text(AppLocalizations.of(context)!.workoutComparison, style: AppTextStyles.h2),
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
                    _buildTableHeader(AppLocalizations.of(context)!.exerciseLabel),
                    _buildTableHeader(AppLocalizations.of(context)!.current),
                    _buildTableHeader(AppLocalizations.of(context)!.suggested),
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
                Text(Units.of(context).weight(original.weight),
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
                  Units.of(context).weight(suggested.weight),
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
        Text(AppLocalizations.of(context)!.detailedAnalysis, style: AppTextStyles.h2),
        const SizedBox(height: 16),
        ...widget.workout.exercises.map((exercise) {
          final metrics = _exerciseMetrics![exercise.exercise.id];
          final reason = _reasons![exercise.exercise.id] ?? AppLocalizations.of(context)!.noData;
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
            _buildMetricRow(AppLocalizations.of(context)!.reasonForChange, reason),
            if (metrics.sessionsCount > 0) ...[
              const Divider(height: 24),
              _buildMetricRow(
                AppLocalizations.of(context)!.completedInRecentWorkouts,
                '${(metrics.completionRate * 100).toStringAsFixed(0)}%',
              ),
              _buildMetricRow(
                AppLocalizations.of(context)!.averageWeightColon,
                Units.of(context).weight(metrics.avgWeight),
              ),
              _buildMetricRow(
                AppLocalizations.of(context)!.averageRepsColon,
                metrics.avgRepsPerSet.toStringAsFixed(1),
              ),
              if (metrics.estimated1RM > 0)
                _buildMetricRow(
                  AppLocalizations.of(context)!.estimated1RMColon,
                  Units.of(context).weight(metrics.estimated1RM),
                ),
              _buildMetricRow(
                AppLocalizations.of(context)!.weightTrendColon,
                metrics.weightTrend > 0
                    ? AppLocalizations.of(context)!.trendRising(
                        Units.of(context).weightDelta(metrics.weightTrend))
                    : metrics.weightTrend < 0
                        ? AppLocalizations.of(context)!.trendFalling(
                            Units.of(context).weightDelta(metrics.weightTrend))
                        : AppLocalizations.of(context)!.trendStable,
                color: metrics.weightTrend > 0
                    ? Colors.green
                    : metrics.weightTrend < 0
                        ? Colors.red
                        : null,
              ),
              _buildMetricRow(
                AppLocalizations.of(context)!.daysSinceLastSession,
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
