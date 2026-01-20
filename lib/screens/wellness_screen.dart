import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/wellness_service.dart';
import '../services/workout_recommendation_service.dart';
import '../models/wellness_entry.dart';
import '../models/workout_recommendation.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_colors.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  late Map<String, int> _values;
  WorkoutRecommendation? _recommendation;
  bool _isLoadingRecommendation = false;

  @override
  void initState() {
    super.initState();
    _values = {
      'energy': 3,
      'mood': 3,
      'tiredness': 3,
      'stress': 3,
      'muscleSoreness': 3,
    };
    _loadRecommendation();
  }

  Future<void> _loadRecommendation() async {
    setState(() => _isLoadingRecommendation = true);
    try {
      final recommendationService = Provider.of<WorkoutRecommendationService>(
        context,
        listen: false,
      );
      final rec = await recommendationService.generateTodaysRecommendation();
      if (mounted) {
        setState(() {
          _recommendation = rec;
          _isLoadingRecommendation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRecommendation = false);
      }
    }
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return '${h}h ${m}m';
    }
    final m = d.inMinutes;
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final _questionKeys = [
      'energy',
      'mood',
      'tiredness',
      'stress',
      'muscleSoreness',
    ];
    final _questionLabels = {
      'energy': l10n.energy,
      'mood': l10n.mood,
      'tiredness': l10n.tiredness,
      'stress': l10n.stress,
      'muscleSoreness': l10n.muscleSoreness,
    };
    final service = Provider.of<WellnessService>(context);
    final canSubmit = service.canSubmit();
    final timeUntil = service.timeUntilNext();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wellness),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoadingRecommendation)
              Card(
                color: AppColors.primary.withValues(alpha: 0.1),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (_recommendation != null)
              _buildRecommendationCard(_recommendation!, l10n)
            else
              Card(
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Complete wellness check to get workout recommendation',
                        style: AppTextStyles.body1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(l10n.howDoYouFeel,
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  for (var key in _questionKeys) ...[
                    Text(_questionLabels[key]!,
                        style: AppTextStyles.body1.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        )),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _values[key]!.toDouble(),
                            min: 0,
                            max: 5,
                            divisions: 5,
                            label: _values[key].toString(),
                            activeColor: AppColors.primary,
                            onChanged: (v) {
                              setState(() {
                                _values[key] = v.round();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 36,
                          child: Center(
                            child: Text(
                              _values[key]!.toString(),
                              style: AppTextStyles.h4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: canSubmit
                        ? () async {
                            final entry = WellnessEntry(
                              timestamp: DateTime.now(),
                              answers: Map.from(_values),
                            );
                            await service.addEntry(entry);

                            await _loadRecommendation();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.saved)),
                              );
                              setState(() {});
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(canSubmit ? l10n.submit : l10n.submitLocked,
                        style: AppTextStyles.button),
                  ),
                  if (!canSubmit) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.nextEntryIn(_formatDuration(timeUntil)),
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(l10n.recentEntries,
                      style: AppTextStyles.h4.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      )),
                  const SizedBox(height: 8),
                  for (var e in service.entries.take(7))
                    Card(
                      child: ListTile(
                        title: Text(
                            e.timestamp.toLocal().toString().split('.')[0]),
                        subtitle: Text(
                            'Avg: ${e.averageScore.toStringAsFixed(1)} — ${e.answers.values.join(', ')}'),
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

  Widget _buildRecommendationCard(
      WorkoutRecommendation rec, AppLocalizations l10n) {
    Color levelColor;
    IconData levelIcon;
    String levelText;

    switch (rec.level) {
      case RecommendationLevel.rest:
        levelColor = Colors.blue;
        levelIcon = Icons.hotel;
        levelText = 'Rest Day';
        break;
      case RecommendationLevel.light:
        levelColor = Colors.green;
        levelIcon = Icons.brightness_low;
        levelText = 'Light';
        break;
      case RecommendationLevel.moderate:
        levelColor = Colors.orange;
        levelIcon = Icons.brightness_medium;
        levelText = 'Moderate';
        break;
      case RecommendationLevel.intense:
        levelColor = Colors.red;
        levelIcon = Icons.brightness_high;
        levelText = 'Intense';
        break;
    }

    return Card(
      color: levelColor.withValues(alpha: 0.1),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(levelIcon, color: levelColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Recommendation',
                        style: AppTextStyles.h4.copyWith(
                          color: levelColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$levelText - ${rec.workoutName}',
                        style: AppTextStyles.h3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              rec.overallReason,
              style: AppTextStyles.body2.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            if (rec.level != RecommendationLevel.rest) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Exercises (${rec.exercises.length})',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...rec.exercises.map((exercise) {
                final we = exercise.exercise;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                we.exercise.name,
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(exercise.confidenceScore * 100).toStringAsFixed(0)}%',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatChip(
                              icon: Icons.fitness_center,
                              label: we.weight > 0
                                  ? '${we.weight} kg'
                                  : 'Bodyweight',
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip(
                              icon: Icons.repeat,
                              label: '${we.sets} sets × ${we.targetReps} reps',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.reason,
                          style: AppTextStyles.caption.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Overall Confidence: ${(rec.overallConfidence * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loadRecommendation,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
