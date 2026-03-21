import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/groq_service.dart';

class AiDirectionScreen extends StatelessWidget {
  const AiDirectionScreen({super.key});

  static const _aiColor = Color(0xFF6C63FF);

  static final _options = [
    (TrainingDirection.fullBody, 'Full Body', Icons.fitness_center, 'Balanced development of all muscle groups'),
    (TrainingDirection.powerlifting, 'Powerlifting', Icons.sports_martial_arts, 'Max strength: squat, bench, deadlift'),
    (TrainingDirection.armWrestling, 'Arm Wrestling', Icons.back_hand, 'Forearms, wrists, grip & pulling strength'),
    (TrainingDirection.streetlifting, 'Streetlifting', Icons.sports_gymnastics, 'Weighted calisthenics & bodyweight skills'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          'Choose Training Direction',
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _aiColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _aiColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _aiColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, color: _aiColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Program Generation', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('AI will tailor the program to your goals and workout history', style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Select direction', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          ..._options.map(
            (opt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DirectionCard(
                direction: opt.$1,
                title: opt.$2,
                icon: opt.$3,
                description: opt.$4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionCard extends StatelessWidget {
  final TrainingDirection direction;
  final String title;
  final IconData icon;
  final String description;

  static const _aiColor = Color(0xFF6C63FF);

  const _DirectionCard({
    required this.direction,
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _aiColor.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).pop(direction),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _aiColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _aiColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(description, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _aiColor),
            ],
          ),
        ),
      ),
    );
  }
}
