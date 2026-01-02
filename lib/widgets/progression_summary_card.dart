import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/progression_service.dart';
import '../services/data_manager.dart';

class ProgressionSummaryCard extends StatefulWidget {
  const ProgressionSummaryCard({super.key});

  @override
  State<ProgressionSummaryCard> createState() => _ProgressionSummaryCardState();
}

class _ProgressionSummaryCardState extends State<ProgressionSummaryCard> {
  final _progressionService = ProgressionService();
  bool _isLoading = true;
  bool _needsDeload = false;
  int _improvingExercises = 0;
  int _decliningExercises = 0;
  int _stableExercises = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProgressionData();
  }

  Future<void> _loadProgressionData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dataManager = DataManager();
      await dataManager.initialize();

      final histories = dataManager.workoutHistory;

      if (histories.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Недостаточно данных';
        });
        return;
      }

      final needsDeload = _progressionService.shouldDeload(histories);

      int improving = 0;
      int declining = 0;
      int stable = 0;

      final allExercises = <String>{};
      for (var h in histories) {
        for (var er in h.session.exerciseResults) {
          allExercises.add(er.exercise.id);
        }
      }

      for (var exerciseId in allExercises) {
        final metrics = _progressionService.analyzeExerciseHistory(
          exerciseId,
          histories,
          lookback: 5,
        );

        if (metrics.sessionsCount >= 3) {
          if (metrics.performanceTrend > 2.0) {
            improving++;
          } else if (metrics.performanceTrend < -2.0) {
            declining++;
          } else {
            stable++;
          }
        }
      }

      setState(() {
        _needsDeload = needsDeload;
        _improvingExercises = improving;
        _decliningExercises = declining;
        _stableExercises = stable;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка загрузки: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Выберите тренировку для просмотра детальной аналитики'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insights,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Прогресс тренировок',
                    style: AppTextStyles.h2,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_needsDeload) _buildDeloadWarning(),
              if (_needsDeload) const SizedBox(height: 12),
              _buildProgressStats(),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => _loadProgressionData(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Обновить'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeloadWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Рекомендуется разгрузочная неделя',
              style: AppTextStyles.body2.copyWith(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStats() {
    final total = _improvingExercises + _decliningExercises + _stableExercises;

    if (total == 0) {
      return Text(
        'Выполните больше тренировок для анализа',
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    return Column(
      children: [
        _buildStatRow(
          icon: Icons.trending_up,
          label: 'Улучшается',
          value: _improvingExercises,
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        _buildStatRow(
          icon: Icons.trending_flat,
          label: 'Стабильно',
          value: _stableExercises,
          color: Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildStatRow(
          icon: Icons.trending_down,
          label: 'Снижается',
          value: _decliningExercises,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.toString(),
            style: AppTextStyles.body2.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
