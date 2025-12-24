import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../models/user.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({super.key});

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  final _focusController = TextEditingController();
  final Map<TrainingGoal, bool> _selectedGoals = {};
  ExperienceLevel? _experience;
  TrainingIntensity? _intensity;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileService>(context, listen: false);

    for (var g in TrainingGoal.values) {
      _selectedGoals[g] = profile.goals.contains(g.name);
    }
    _experience = profile.experienceLevel != null
        ? ExperienceLevel.values.firstWhere(
            (e) => e.name == profile.experienceLevel,
            orElse: () => ExperienceLevel.intermediate)
        : ExperienceLevel.intermediate;
    _intensity = profile.preferredIntensity != null
        ? TrainingIntensity.values.firstWhere(
            (e) => e.name == profile.preferredIntensity,
            orElse: () => TrainingIntensity.moderate)
        : TrainingIntensity.moderate;
    _focusController.text = profile.trainingFocus.join(', ');
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Me'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Goals', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TrainingGoal.values.map((g) {
                final selected = _selectedGoals[g] ?? false;
                return FilterChip(
                  label: Text(g.name.replaceAll('_', ' ')),
                  selected: selected,
                  onSelected: (v) => setState(() => _selectedGoals[g] = v),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Experience Level', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            DropdownButton<ExperienceLevel>(
              value: _experience,
              items: ExperienceLevel.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name.capitalize()),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _experience = v),
            ),
            const SizedBox(height: 16),
            Text('Training Focus (comma separated)', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            TextField(
              controller: _focusController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g. legs, upper body, core',
              ),
            ),
            const SizedBox(height: 16),
            Text('Preferred Intensity', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Row(
              children: TrainingIntensity.values.map((i) {
                return Expanded(
                  child: RadioListTile<TrainingIntensity>(
                    title: Text(i.name.capitalize()),
                    value: i,
                    groupValue: _intensity,
                    onChanged: (v) => setState(() => _intensity = v),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    final profile = Provider.of<ProfileService>(context, listen: false);
    final selectedGoals = _selectedGoals.entries
        .where((e) => e.value)
        .map((e) => e.key.name)
        .toList();
    final focus = _focusController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    await profile.setGoals(selectedGoals);
    await profile.setExperienceLevel(_experience?.name);
    await profile.setTrainingFocus(focus);
    await profile.setPreferredIntensity(_intensity?.name);

    if (mounted) Navigator.of(context).pop();
  }
}

extension _StringExt on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
