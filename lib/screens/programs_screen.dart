import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          AppStrings.programs,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Select a training program',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),
          _buildProgramCategory(
            context,
            AppStrings.streetlifting,
            'Bodyweight training',
            Icons.sports_gymnastics,
            AppColors.streetlifting,
            [
              'Beginner basic program',
              'Advanced program',
              'Program for strength exit',
            ],
          ),
          const SizedBox(height: 16),
          _buildProgramCategory(
            context,
            AppStrings.armwrestling,
            'Specialized training',
            Icons.back_hand,
            AppColors.armwrestling,
            [
              'Basic armwrestling program',
              'Grip and forearm training',
              'Competition program',
            ],
          ),
          const SizedBox(height: 16),
          _buildProgramCategory(
            context,
            AppStrings.powerlifting,
            'Programs for maximum strength',
            Icons.fitness_center,
            AppColors.powerlifting,
            [
              'Beginner 5x5 program',
              'Intermediate program',
              'Pre-competition preparation program',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCategory(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    List<String> programs,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          title: Text(
            title,
            style: AppTextStyles.h4.copyWith(color: color),
          ),
          subtitle: Text(
            description,
            style: AppTextStyles.caption,
          ),
          children: programs.map((program) {
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              leading: Icon(Icons.play_arrow, color: color, size: 20),
              title: Text(program, style: AppTextStyles.body2),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                // TODO: Navigate to program details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Открыть программу: $program'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
