import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nutrition_profile.dart';
import '../services/nutrition_service.dart';
import '../services/theme_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class NutritionGoalScreen extends StatefulWidget {
  const NutritionGoalScreen({super.key});

  @override
  State<NutritionGoalScreen> createState() => _NutritionGoalScreenState();
}

class _NutritionGoalScreenState extends State<NutritionGoalScreen> {
  NutritionGoal? _selected;

  @override
  void initState() {
    super.initState();
    final nutrition = context.read<NutritionService>();
    _selected = nutrition.profile.goal;
  }

  static const _goalMeta = {
    NutritionGoal.aggressiveFatLoss: (
      icon: Icons.local_fire_department,
      color: Color(0xFFF44336),
      tag: '-500 kcal',
    ),
    NutritionGoal.fatLoss: (
      icon: Icons.trending_down,
      color: Color(0xFFFF9800),
      tag: '-300 kcal',
    ),
    NutritionGoal.maintain: (
      icon: Icons.balance,
      color: Color(0xFF4CAF50),
      tag: '0 kcal',
    ),
    NutritionGoal.leanBulk: (
      icon: Icons.trending_up,
      color: Color(0xFF2196F3),
      tag: '+250 kcal',
    ),
    NutritionGoal.bulk: (
      icon: Icons.fitness_center,
      color: Color(0xFF9C27B0),
      tag: '+500 kcal',
    ),
  };

  Future<void> _confirm() async {
    if (_selected == null) return;
    final nutrition = context.read<NutritionService>();
    await nutrition.setGoal(_selected!);
    if (mounted) Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppColor>(
      builder: (context, appColor, _) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: appColor.color,
          foregroundColor: AppColors.textOnPrimary,
          title: Text(
            'Nutrition Goal',
            style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'What is your nutrition goal?',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This determines your daily calorie target and macro split.',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...NutritionGoal.values.map((goal) {
                    final meta = _goalMeta[goal]!;
                    final isSelected = _selected == goal;
                    return _GoalCard(
                      goal: goal,
                      icon: meta.icon,
                      accentColor: meta.color,
                      tag: meta.tag,
                      isSelected: isSelected,
                      primaryColor: appColor.color,
                      onTap: () => setState(() => _selected = goal),
                    );
                  }),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selected != null ? _confirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor.color,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Confirm Goal', style: AppTextStyles.button),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final NutritionGoal goal;
  final IconData icon;
  final Color accentColor;
  final String tag;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.icon,
    required this.accentColor,
    required this.tag,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(goal.displayName, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.caption.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.description,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? primaryColor : AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
