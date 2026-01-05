import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              color: color.withValues(alpha: 0.1),
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
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                itemCount: programs.length,
                controller: PageController(viewportFraction: 0.85),
                itemBuilder: (context, index) {
                  final program = programs[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Open program: $program'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.play_arrow, color: color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(program, style: AppTextStyles.body1),
                                    const SizedBox(height: 6),
                                    Text(title, style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
