import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../models/user.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';

class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({super.key});

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  final _focusController = TextEditingController();
  final List<String> _focusList = [];
  static const List<String> _suggestedFocus = [
    'legs',
    'upper body',
    'core',
    'glutes',
    'back',
    'chest',
    'shoulders',
    'arms',
    'cardio',
  ];
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
    _focusList.addAll(profile.trainingFocus);
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
            Text(AppStrings.training, style: AppTextStyles.h3),
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
            Text('Training Focus', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _focusList
                  .map((f) => Chip(
                        label: Text(f),
                        onDeleted: () => setState(() => _focusList.remove(f)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                final input = textEditingValue.text.toLowerCase();
                if (input.isEmpty) return const Iterable<String>.empty();
                return _suggestedFocus.where((s) =>
                    s.toLowerCase().contains(input) && !_focusList.contains(s));
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                controller.text = _focusController.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'e.g. legs, upper body, core',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final val = controller.text.trim();
                        if (val.isNotEmpty && !_focusList.contains(val)) {
                          setState(() {
                            _focusList.add(val);
                            controller.clear();
                          });
                        }
                      },
                    ),
                  ),
                  onSubmitted: (v) {
                    final val = v.trim();
                    if (val.isNotEmpty && !_focusList.contains(val)) {
                      setState(() {
                        _focusList.add(val);
                        controller.clear();
                      });
                    }
                  },
                );
              },
              onSelected: (selection) {
                if (!_focusList.contains(selection)) {
                  setState(() => _focusList.add(selection));
                }
              },
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(AppStrings.save),
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

    if (selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorFieldRequired)),
      );
      return;
    }

    await profile.setGoals(selectedGoals);
    await profile.setExperienceLevel(_experience?.name);
    await profile.setTrainingFocus(_focusList);
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
