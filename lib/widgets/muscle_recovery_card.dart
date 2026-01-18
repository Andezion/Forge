import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/muscle_recovery_tracker.dart';

/// Виджет для отображения состояния восстановления групп мышц
class MuscleRecoveryCard extends StatelessWidget {
  final Map<MuscleGroup, int> daysSinceTraining;
  final Map<MuscleGroup, double> recoveryPriorities;

  const MuscleRecoveryCard({
    super.key,
    required this.daysSinceTraining,
    required this.recoveryPriorities,
  });

  @override
  Widget build(BuildContext context) {
    final tracker = MuscleRecoveryTracker();
    final musclesToTrain = tracker.getMusclesToTrain(recoveryPriorities);
    final musclesToRest = tracker.getMusclesToRest(recoveryPriorities);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Восстановление мышц',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Мышцы, готовые к тренировке
            if (musclesToTrain.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                '✅ Готовы к тренировке',
                Colors.green,
              ),
              const SizedBox(height: 8),
              ...musclesToTrain.take(5).map((muscle) => _buildMuscleRow(
                    context,
                    muscle,
                    daysSinceTraining[muscle] ?? 0,
                    recoveryPriorities[muscle] ?? 0.5,
                  )),
              const SizedBox(height: 16),
            ],

            // Мышцы в процессе восстановления
            _buildSectionHeader(
              context,
              '⏳ В процессе восстановления',
              Colors.orange,
            ),
            const SizedBox(height: 8),
            ..._getRecoveringMuscles().take(3).map((muscle) => _buildMuscleRow(
                  context,
                  muscle,
                  daysSinceTraining[muscle] ?? 0,
                  recoveryPriorities[muscle] ?? 0.5,
                )),

            // Мышцы, требующие отдыха
            if (musclesToRest.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionHeader(
                context,
                '😴 Требуют отдыха',
                Colors.red,
              ),
              const SizedBox(height: 8),
              ...musclesToRest.take(3).map((muscle) => _buildMuscleRow(
                    context,
                    muscle,
                    daysSinceTraining[muscle] ?? 0,
                    recoveryPriorities[muscle] ?? 0.5,
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildMuscleRow(
    BuildContext context,
    MuscleGroup muscle,
    int days,
    double priority,
  ) {
    final displayName = MuscleRecoveryTracker.getMuscleGroupDisplayName(muscle);
    final color = _getPriorityColor(priority);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Индикатор приоритета
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Название группы мышц
          Expanded(
            child: Text(
              displayName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          // Количество дней
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                color.red,
                color.green,
                color.blue,
                0.2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              days >= 999 ? 'Не тренировали' : '$days ${_getDaysWord(days)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          const SizedBox(width: 8),

          // Прогресс-бар
          SizedBox(
            width: 60,
            child: LinearProgressIndicator(
              value: priority.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(double priority) {
    if (priority >= 0.7) {
      return Colors.green;
    } else if (priority >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getDaysWord(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    } else if ([2, 3, 4].contains(days % 10) &&
        ![12, 13, 14].contains(days % 100)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }

  List<MuscleGroup> _getRecoveringMuscles() {
    return recoveryPriorities.entries
        .where((e) => e.value >= 0.3 && e.value < 0.7)
        .map((e) => e.key)
        .toList()
      ..sort(
          (a, b) => recoveryPriorities[b]!.compareTo(recoveryPriorities[a]!));
  }
}

/// Компактная версия виджета для главного экрана
class MuscleRecoveryCompact extends StatelessWidget {
  final Map<MuscleGroup, int> daysSinceTraining;
  final Map<MuscleGroup, double> recoveryPriorities;

  const MuscleRecoveryCompact({
    super.key,
    required this.daysSinceTraining,
    required this.recoveryPriorities,
  });

  @override
  Widget build(BuildContext context) {
    final tracker = MuscleRecoveryTracker();
    final musclesToTrain = tracker.getMusclesToTrain(recoveryPriorities);

    if (musclesToTrain.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Готовы к тренировке:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: musclesToTrain.take(4).map((muscle) {
                final displayName =
                    MuscleRecoveryTracker.getMuscleGroupDisplayName(muscle);
                final days = daysSinceTraining[muscle] ?? 0;
                return Chip(
                  avatar: const Icon(Icons.check_circle,
                      size: 16, color: Colors.green),
                  label: Text('$displayName ($days д.)'),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
