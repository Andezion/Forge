import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nutrition_profile.dart';
import '../models/user.dart';
import '../services/nutrition_service.dart';
import '../services/profile_service.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'nutrition_goal_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _recalculate() async {
    final profile = context.read<ProfileService>();
    final nutrition = context.read<NutritionService>();

    final w = profile.weightKg;
    final h = profile.heightCm;
    final a = profile.age;
    final g = profile.gender;
    final d = profile.trainingDaysPerWeek;

    if (w == null || h == null || a == null || g == null) {
      _showSnack(
          'Please complete your profile first (weight, height, age, gender).');
      return;
    }

    final gender = Gender.values.firstWhere(
      (e) => e.name == g,
      orElse: () => Gender.other,
    );

    await nutrition.recalculate(
      weightKg: w,
      heightCm: h,
      age: a,
      gender: gender,
      trainingDaysPerWeek: d ?? 3,
    );

    if (nutrition.error != null && mounted) {
      _showSnack('AI unavailable, using algorithm only.');
    }
  }

  Future<void> _toggleNotifications(
      bool value, List<MealSlot> meals, int waterInterval) async {
    final ns = NotificationService();
    await ns.init();
    final granted = await ns.requestPermission();
    if (!granted) {
      _showSnack('Notification permission denied.');
      return;
    }
    setState(() => _notificationsEnabled = value);
    if (value) {
      await ns.scheduleMealReminders(meals);
      await ns.scheduleWaterReminders(waterInterval);
      _showSnack('Reminders scheduled!');
    } else {
      await ns.cancelAll();
      _showSnack('All reminders cancelled.');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppColor, NutritionService>(
      builder: (context, appColor, nutrition, _) {
        final prof = nutrition.profile;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: appColor.color,
            foregroundColor: AppColors.textOnPrimary,
            title: Text(
              'Nutrition',
              style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Recalculate',
                onPressed: nutrition.isCalculating ? null : _recalculate,
              ),
            ],
            bottom: TabBar(
              controller: _tabs,
              indicatorColor: AppColors.textOnPrimary,
              labelColor: AppColors.textOnPrimary,
              unselectedLabelColor:
                  AppColors.textOnPrimary.withValues(alpha: 0.6),
              tabs: const [
                Tab(text: 'Targets'),
                Tab(text: 'Meals'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
          body: nutrition.isCalculating
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _TargetsTab(profile: prof, appColor: appColor.color),
                    _MealsTab(profile: prof, appColor: appColor.color),
                    _SettingsTab(
                      profile: prof,
                      appColor: appColor.color,
                      notificationsEnabled: _notificationsEnabled,
                      onToggleNotifications: (v) => _toggleNotifications(
                        v,
                        prof.mealSchedule,
                        prof.waterReminderIntervalMinutes,
                      ),
                      onGoalTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NutritionGoalScreen(),
                          ),
                        );
                        if (mounted) _recalculate();
                      },
                      onWaterIntervalChanged: (v) async {
                        await nutrition.setWaterReminderInterval(v);
                        if (_notificationsEnabled) {
                          await NotificationService().scheduleWaterReminders(v);
                        }
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _TargetsTab extends StatelessWidget {
  final NutritionProfile profile;
  final Color appColor;

  const _TargetsTab({required this.profile, required this.appColor});

  @override
  Widget build(BuildContext context) {
    final algo = profile.algorithmTargets;
    final ai = profile.aiTargets;

    if (algo == null && ai == null) {
      return _EmptyState(
        message: profile.goal == null
            ? 'Set a nutrition goal to get started.'
            : 'Tap the refresh button to calculate your targets.',
        appColor: appColor,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (profile.goal != null)
          _GoalBadge(goal: profile.goal!, appColor: appColor),
        const SizedBox(height: 16),
        if (algo != null) ...[
          _SectionHeader(
              title: 'Algorithm', subtitle: 'Mifflin-St Jeor formula'),
          _MacroCard(targets: algo, color: appColor),
          const SizedBox(height: 16),
        ],
        if (ai != null) ...[
          _SectionHeader(
              title: 'AI Recommendation', subtitle: 'Groq · Llama 3.3 70B'),
          _MacroCard(targets: ai, color: const Color(0xFF9C27B0)),
          if (profile.aiReasoning != null &&
              profile.aiReasoning!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ReasoningCard(text: profile.aiReasoning!),
          ],
          const SizedBox(height: 16),
        ],
        if (profile.lastCalculated != null)
          Center(
            child: Text(
              'Last updated: ${_formatDate(profile.lastCalculated!)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}'
        '  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _MealsTab extends StatelessWidget {
  final NutritionProfile profile;
  final Color appColor;

  const _MealsTab({required this.profile, required this.appColor});

  @override
  Widget build(BuildContext context) {
    if (profile.mealSchedule.isEmpty) {
      return _EmptyState(
        message: 'Set a goal and calculate targets to see your meal schedule.',
        appColor: appColor,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(
          title: 'Meal Schedule',
          subtitle: '${profile.mealSchedule.length} meals per day',
        ),
        const SizedBox(height: 8),
        ...profile.mealSchedule
            .map((meal) => _MealCard(meal: meal, appColor: appColor)),
        const SizedBox(height: 16),
        _WaterCard(
          waterMl: profile.algorithmTargets?.waterMl ??
              profile.aiTargets?.waterMl ??
              2000,
          appColor: appColor,
        ),
      ],
    );
  }
}

class _SettingsTab extends StatelessWidget {
  final NutritionProfile profile;
  final Color appColor;
  final bool notificationsEnabled;
  final ValueChanged<bool> onToggleNotifications;
  final VoidCallback onGoalTap;
  final ValueChanged<int> onWaterIntervalChanged;

  const _SettingsTab({
    required this.profile,
    required this.appColor,
    required this.notificationsEnabled,
    required this.onToggleNotifications,
    required this.onGoalTap,
    required this.onWaterIntervalChanged,
  });

  @override
  Widget build(BuildContext context) {
    final intervals = [60, 90, 120];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.flag, color: appColor),
            title: Text('Nutrition Goal', style: AppTextStyles.body1),
            subtitle: Text(
              profile.goal?.displayName ?? 'Not set',
              style:
                  AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: onGoalTap,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SwitchListTile(
            secondary: Icon(Icons.notifications, color: appColor),
            title: Text('Meal & Water Reminders', style: AppTextStyles.body1),
            subtitle: Text(
              notificationsEnabled ? 'Active' : 'Inactive',
              style:
                  AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
            value: notificationsEnabled,
            activeColor: appColor,
            onChanged:
                profile.mealSchedule.isNotEmpty ? onToggleNotifications : null,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop, color: appColor),
                    const SizedBox(width: 12),
                    Text('Water Reminder Interval', style: AppTextStyles.body1),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: intervals.map((min) {
                    final selected =
                        profile.waterReminderIntervalMinutes == min;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: selected
                                ? appColor.withValues(alpha: 0.1)
                                : null,
                            side: BorderSide(
                              color: selected ? appColor : AppColors.divider,
                              width: selected ? 2 : 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => onWaterIntervalChanged(min),
                          child: Text(
                            '${min}m',
                            style: AppTextStyles.body2.copyWith(
                              color:
                                  selected ? appColor : AppColors.textSecondary,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final Color appColor;

  const _EmptyState({required this.message, required this.appColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu,
                size: 64, color: appColor.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.h4)),
          Text(subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              )),
        ],
      ),
    );
  }
}

class _GoalBadge extends StatelessWidget {
  final NutritionGoal goal;
  final Color appColor;

  const _GoalBadge({required this.goal, required this.appColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: appColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, color: appColor, size: 18),
          const SizedBox(width: 8),
          Text(
            'Goal: ${goal.displayName}',
            style: AppTextStyles.body1.copyWith(
              color: appColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final MacroTargets targets;
  final Color color;

  const _MacroCard({required this.targets, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    targets.calories.toStringAsFixed(0),
                    style: AppTextStyles.h2.copyWith(color: color),
                  ),
                  Text(
                    'kcal / day',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _MacroTile(
                  label: 'Protein',
                  value: targets.proteinG,
                  unit: 'g',
                  color: const Color(0xFF2196F3),
                ),
                _MacroTile(
                  label: 'Carbs',
                  value: targets.carbsG,
                  unit: 'g',
                  color: const Color(0xFFFF9800),
                ),
                _MacroTile(
                  label: 'Fat',
                  value: targets.fatG,
                  unit: 'g',
                  color: const Color(0xFFF44336),
                ),
                _MacroTile(
                  label: 'Water',
                  value: targets.waterMl / 1000,
                  unit: 'L',
                  color: const Color(0xFF00BCD4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _MacroTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: AppTextStyles.body1.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ReasoningCard extends StatelessWidget {
  final String text;

  const _ReasoningCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF9C27B0).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF9C27B0).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF9C27B0)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealSlot meal;
  final Color appColor;

  const _MealCard({required this.meal, required this.appColor});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${meal.hour.toString().padLeft(2, '0')}:${meal.minute.toString().padLeft(2, '0')}';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: appColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, color: appColor, size: 20),
                  Text(
                    timeStr,
                    style: AppTextStyles.caption.copyWith(
                      color: appColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.name,
                      style: AppTextStyles.body1
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 10,
                    children: [
                      _Chip('${meal.calories.toStringAsFixed(0)} kcal',
                          Colors.grey),
                      _Chip('P: ${meal.proteinG.toStringAsFixed(0)}g',
                          const Color(0xFF2196F3)),
                      _Chip('C: ${meal.carbsG.toStringAsFixed(0)}g',
                          const Color(0xFFFF9800)),
                      _Chip('F: ${meal.fatG.toStringAsFixed(0)}g',
                          const Color(0xFFF44336)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  final double waterMl;
  final Color appColor;

  const _WaterCard({required this.waterMl, required this.appColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.water_drop,
                  color: Color(0xFF00BCD4), size: 26),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Water',
                    style: AppTextStyles.body1
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '${(waterMl / 1000).toStringAsFixed(1)} L  (${waterMl.toStringAsFixed(0)} ml)',
                  style: AppTextStyles.body2.copyWith(
                    color: const Color(0xFF00BCD4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
