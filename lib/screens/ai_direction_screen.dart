import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/groq_service.dart';

class AiDirectionScreen extends StatelessWidget {
  const AiDirectionScreen({super.key});

  static const _aiColor = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      (TrainingDirection.fullBody, l10n.directionFullBody, Icons.fitness_center, l10n.directionFullBodyDesc),
      (TrainingDirection.powerlifting, l10n.powerlifting, Icons.sports_martial_arts, l10n.directionPowerliftingDesc),
      (TrainingDirection.armWrestling, l10n.armwrestling, Icons.back_hand, l10n.directionArmWrestlingDesc),
      (TrainingDirection.streetlifting, l10n.streetlifting, Icons.sports_gymnastics, l10n.directionStreetliftingDesc),
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          l10n.chooseTrainingDirection,
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
                      Text(l10n.aiProgramGeneration, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(l10n.aiProgramGenerationDesc, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.selectDirection, style: AppTextStyles.h3),
          const SizedBox(height: 12),
          ...options.map(
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
