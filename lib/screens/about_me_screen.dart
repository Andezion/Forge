import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  final _injuryController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _yearsTrainingController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  final List<String> _focusList = [];
  final List<String> _injuryList = [];

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

  static const List<String> _suggestedInjuries = [
    'knee',
    'lower back',
    'shoulder',
    'wrist',
    'elbow',
    'ankle',
    'hip',
    'neck',
    'hamstring',
    'groin',
  ];

  final Map<TrainingGoal, bool> _selectedGoals = {};
  ExperienceLevel? _experience;
  TrainingIntensity? _intensity;
  Gender? _gender;
  int _trainingDaysPerWeek = 3;
  SessionDuration? _sessionDuration;

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
    _injuryList.addAll(profile.injuries);

    _gender = profile.gender != null
        ? Gender.values.firstWhere((e) => e.name == profile.gender,
            orElse: () => Gender.other)
        : null;
    _trainingDaysPerWeek = profile.trainingDaysPerWeek ?? 3;
    _sessionDuration = profile.sessionDuration != null
        ? SessionDuration.values.firstWhere(
            (e) => e.name == profile.sessionDuration,
            orElse: () => SessionDuration.sixtyMin)
        : SessionDuration.sixtyMin;

    if (profile.age != null) {
      _ageController.text = profile.age.toString();
    }
    if (profile.heightCm != null) {
      _heightController.text = profile.heightCm!.toStringAsFixed(0);
    }
    if (profile.weightKg != null) {
      _weightController.text = profile.weightKg!.toStringAsFixed(1);
    }
    if (profile.yearsTraining != null) {
      _yearsTrainingController.text = profile.yearsTraining!.toStringAsFixed(1);
    }
    if (profile.country != null) _countryController.text = profile.country!;
    if (profile.city != null) _cityController.text = profile.city!;
  }

  @override
  void dispose() {
    _focusController.dispose();
    _injuryController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _yearsTrainingController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.aboutMe),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: l10n.basicInformation,
              icon: Icons.person,
              children: [
                _buildTextField(
                  controller: _ageController,
                  label: l10n.age,
                  hint: l10n.hintAge,
                  keyboardType: TextInputType.number,
                  suffixText: l10n.years,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _heightController,
                  label: l10n.heightLabel,
                  hint: l10n.hintHeight,
                  keyboardType: TextInputType.number,
                  suffixText: 'cm',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _weightController,
                  label: l10n.weight,
                  hint: l10n.hintWeight,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  suffixText: 'kg',
                ),
                const SizedBox(height: 16),
                Text(l10n.gender, style: AppTextStyles.body1),
                const SizedBox(height: 8),
                _buildGenderSelector(l10n),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: l10n.location,
              icon: Icons.location_on,
              children: [
                Text(
                  l10n.locationDesc,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _countryController,
                  label: l10n.country,
                  hint: l10n.hintCountry,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _cityController,
                  label: l10n.city,
                  hint: l10n.hintCity,
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: l10n.trainingGoals,
              icon: Icons.flag,
              children: [
                Text(
                  l10n.trainingGoalsDesc,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: TrainingGoal.values.map((g) {
                    final selected = _selectedGoals[g] ?? false;
                    return FilterChip(
                      label: Text(_goalLabel(g, l10n)),
                      selected: selected,
                      onSelected: (v) => setState(() => _selectedGoals[g] = v),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: l10n.trainingSchedule,
              icon: Icons.calendar_month,
              children: [
                Text(l10n.trainingExperience, style: AppTextStyles.body1),
                const SizedBox(height: 4),
                _buildTextField(
                  controller: _yearsTrainingController,
                  label: '',
                  hint: l10n.hintYearsTraining,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  suffixText: l10n.years,
                ),
                const SizedBox(height: 16),
                Text(l10n.daysPerWeek, style: AppTextStyles.body1),
                const SizedBox(height: 4),
                Text(
                  l10n.daysPerWeekDesc,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                _buildDaysPicker(),
                const SizedBox(height: 16),
                Text(l10n.sessionDurationLabel, style: AppTextStyles.body1),
                const SizedBox(height: 4),
                Text(
                  l10n.sessionDurationDesc,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                _buildSessionDurationSelector(),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: l10n.trainingPreferences,
              icon: Icons.fitness_center,
              children: [
                Text(l10n.experienceLevel, style: AppTextStyles.body1),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.textSecondary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<ExperienceLevel>(
                    value: _experience,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: ExperienceLevel.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name.capitalize()),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _experience = v),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.preferredIntensity, style: AppTextStyles.body1),
                const SizedBox(height: 8),
                ...TrainingIntensity.values.map((i) {
                  return RadioListTile<TrainingIntensity>(
                    title: Text(i.name.capitalize()),
                    subtitle: Text(_getIntensityDescription(i, l10n)),
                    value: i,
                    groupValue: _intensity,
                    onChanged: (v) => setState(() => _intensity = v),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: l10n.trainingFocus,
              icon: Icons.track_changes,
              children: [
                Text(
                  l10n.trainingFocusDesc,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                if (_focusList.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _focusList
                        .map((f) => Chip(
                              label: Text(f),
                              onDeleted: () =>
                                  setState(() => _focusList.remove(f)),
                              deleteIconColor: AppColors.textSecondary,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 8),
                _buildAutocompleteChipInput(
                  controller: _focusController,
                  suggestions: _suggestedFocus,
                  currentList: _focusList,
                  hint: l10n.hintFocus,
                  onAdd: (val) => setState(() => _focusList.add(val)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: l10n.injuriesLimitations,
              icon: Icons.healing,
              children: [
                Text(
                  l10n.injuriesDesc,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                if (_injuryList.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _injuryList
                        .map((f) => Chip(
                              label: Text(f),
                              backgroundColor:
                                  Colors.red.withValues(alpha: 0.1),
                              side: BorderSide(
                                  color: Colors.red.withValues(alpha: 0.4)),
                              onDeleted: () =>
                                  setState(() => _injuryList.remove(f)),
                              deleteIconColor: Colors.red,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 8),
                _buildAutocompleteChipInput(
                  controller: _injuryController,
                  suggestions: _suggestedInjuries,
                  currentList: _injuryList,
                  hint: l10n.hintInjuries,
                  onAdd: (val) => setState(() => _injuryList.add(val)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.save,
                  style: AppTextStyles.button,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector(AppLocalizations l10n) {
    return Row(
      children: Gender.values.map((g) {
        final selected = _gender == g;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _gender = g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                    width: selected ? 1.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _genderLabel(g, l10n),
                    style: AppTextStyles.body2.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaysPicker() {
    return Row(
      children: List.generate(6, (i) {
        final days = i + 2; // 2–7
        final selected = _trainingDaysPerWeek == days;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => setState(() => _trainingDaysPerWeek = days),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                    width: selected ? 1.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$days',
                    style: AppTextStyles.body1.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSessionDurationSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SessionDuration.values.map((d) {
        final selected = _sessionDuration == d;
        return GestureDetector(
          onTap: () => setState(() => _sessionDuration = d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.3),
                width: selected ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              d.label,
              style: AppTextStyles.body2.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAutocompleteChipInput({
    required TextEditingController controller,
    required List<String> suggestions,
    required List<String> currentList,
    required String hint,
    required void Function(String) onAdd,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        final input = textEditingValue.text.toLowerCase();
        if (input.isEmpty) return const Iterable<String>.empty();
        return suggestions.where(
            (s) => s.toLowerCase().contains(input) && !currentList.contains(s));
      },
      fieldViewBuilder:
          (context, fieldController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
            hintStyle:
                AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final val = fieldController.text.trim().toLowerCase();
                if (val.isNotEmpty && !currentList.contains(val)) {
                  onAdd(val);
                  fieldController.clear();
                }
              },
            ),
          ),
          onSubmitted: (v) {
            final val = v.trim().toLowerCase();
            if (val.isNotEmpty && !currentList.contains(val)) {
              onAdd(val);
              fieldController.clear();
            }
          },
        );
      },
      onSelected: (selection) {
        if (!currentList.contains(selection)) {
          onAdd(selection);
        }
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    String? suffixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: AppTextStyles.body1),
          const SizedBox(height: 4),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
            hintStyle:
                AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            suffixText: suffixText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  String _genderLabel(Gender g, AppLocalizations l10n) {
    switch (g) {
      case Gender.male:
        return l10n.male;
      case Gender.female:
        return l10n.female;
      case Gender.other:
        return l10n.other;
    }
  }

  String _goalLabel(TrainingGoal g, AppLocalizations l10n) {
    switch (g) {
      case TrainingGoal.strength:
        return l10n.strengthGoal;
      case TrainingGoal.hypertrophy:
        return l10n.hypertrophyGoal;
      case TrainingGoal.endurance:
        return l10n.enduranceGoal;
      case TrainingGoal.fatLoss:
        return l10n.fatLossGoal;
      case TrainingGoal.generalFitness:
        return l10n.generalFitnessGoal;
    }
  }

  String _getIntensityDescription(TrainingIntensity intensity, AppLocalizations l10n) {
    switch (intensity) {
      case TrainingIntensity.light:
        return l10n.intensityLight;
      case TrainingIntensity.moderate:
        return l10n.intensityModerate;
      case TrainingIntensity.intense:
        return l10n.intensityIntense;
    }
  }

  void _save() async {
    final l10n = AppLocalizations.of(context)!;
    final profile = Provider.of<ProfileService>(context, listen: false);
    final selectedGoals = _selectedGoals.entries
        .where((e) => e.value)
        .map((e) => e.key.name)
        .toList();

    if (selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectGoal)),
      );
      return;
    }

    await profile.setGoals(selectedGoals);
    await profile.setExperienceLevel(_experience?.name);
    await profile.setTrainingFocus(_focusList);
    await profile.setPreferredIntensity(_intensity?.name);
    await profile.setGender(_gender?.name);
    await profile.setTrainingDaysPerWeek(_trainingDaysPerWeek);
    await profile.setSessionDuration(_sessionDuration?.name);
    await profile.setInjuries(_injuryList);

    final age = int.tryParse(_ageController.text.trim());
    await profile.setAge(age);

    final height = double.tryParse(_heightController.text.trim());
    await profile.setHeightCm(height);

    final weight = double.tryParse(_weightController.text.trim());
    await profile.setWeightKg(weight);

    final yearsTraining = double.tryParse(_yearsTrainingController.text.trim());
    await profile.setYearsTraining(yearsTraining);

    final country = _countryController.text.trim();
    await profile.setCountry(country.isEmpty ? null : country);

    final city = _cityController.text.trim();
    await profile.setCity(city.isEmpty ? null : city);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileSavedSuccessfully),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}

extension _StringExt on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
