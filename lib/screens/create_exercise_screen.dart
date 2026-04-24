import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../models/exercise.dart';
import '../utils/muscle_group_utils.dart';

class CreateExerciseScreen extends StatefulWidget {
  final Function(Exercise) onExerciseCreated;
  final Exercise? existingExercise;

  const CreateExerciseScreen({
    super.key,
    required this.onExerciseCreated,
    this.existingExercise,
  });

  @override
  State<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late ExerciseDifficulty _selectedDifficulty;
  late ExerciseType _selectedType;
  late Map<MuscleGroup, MuscleGroupIntensity> _selectedMuscleGroups;

  bool get _isEditing => widget.existingExercise != null;

  @override
  void initState() {
    super.initState();
    final ex = widget.existingExercise;
    _nameController = TextEditingController(text: ex?.name ?? '');
    _descriptionController = TextEditingController(text: ex?.description ?? '');
    _selectedDifficulty = ex?.difficulty ?? ExerciseDifficulty.medium;
    _selectedType = ex?.exerciseType ?? ExerciseType.weightAndReps;
    _selectedMuscleGroups = ex != null
        ? {for (var tag in ex.muscleGroups) tag.group: tag.intensity}
        : {};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final muscleTags = _selectedMuscleGroups.entries
          .map((e) => MuscleGroupTag(group: e.key, intensity: e.value))
          .toList();

      final exercise = Exercise(
        id: widget.existingExercise?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        difficulty: _selectedDifficulty,
        exerciseType: _selectedType,
        createdAt: widget.existingExercise?.createdAt ?? DateTime.now(),
        muscleGroups: muscleTags,
      );

      widget.onExerciseCreated(exercise);
      Navigator.of(context).pop();
    }
  }

  String _getMuscleGroupLabel(MuscleGroup group) =>
      MuscleGroupUtils.getLabel(group);

  String _getIntensityLabel(MuscleGroupIntensity intensity) =>
      MuscleGroupUtils.getIntensityLabel(intensity);

  Color _getIntensityColor(MuscleGroupIntensity intensity) {
    switch (intensity) {
      case MuscleGroupIntensity.primary:
        return AppColors.primary;
      case MuscleGroupIntensity.secondary:
        return AppColors.warning;
      case MuscleGroupIntensity.stabilizer:
        return AppColors.textSecondary;
    }
  }

  void _showMuscleGroupSelector() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.pickMuscleGroup,
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView(
                  shrinkWrap: true,
                  children: MuscleGroup.values.map((group) {
                    return ListTile(
                      title: Text(_getMuscleGroupLabel(group)),
                      trailing: _selectedMuscleGroups.containsKey(group)
                          ? Icon(Icons.check, color: AppColors.success)
                          : null,
                      onTap: () => Navigator.pop(context, group),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((selectedGroup) {
      if (selectedGroup != null) _showIntensitySelector(selectedGroup);
    });
  }

  void _showIntensitySelector(MuscleGroup group) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${AppStrings.intensityFor}\n${_getMuscleGroupLabel(group)}',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...MuscleGroupIntensity.values.map((intensity) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _selectedMuscleGroups[group] = intensity);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _getIntensityColor(intensity)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _getIntensityLabel(intensity),
                      style: TextStyle(color: _getIntensityColor(intensity)),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(
    String label,
    String subtitle,
    IconData icon,
    ExerciseType type,
    Color color,
  ) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : AppColors.textSecondary.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? color : AppColors.textSecondary, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? color : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(
    String label,
    ExerciseDifficulty difficulty,
    Color color,
  ) {
    final isSelected = _selectedDifficulty == difficulty;
    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = difficulty),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        child: Text(
          label,
          style: AppTextStyles.buttonSmall.copyWith(
            color: isSelected ? AppColors.textOnPrimary : color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          _isEditing ? AppStrings.edit : AppStrings.createExercise,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check, color: Colors.white),
            label: Text(
              _isEditing ? AppStrings.save : AppStrings.create,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: AppStrings.exerciseName,
                  prefixIcon: const Icon(Icons.fitness_center),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.errorFieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: AppStrings.description,
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.errorFieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Exercise Type',
                style:
                    AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Determines what metrics are tracked during workout',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeCard(
                      'Weight + Reps',
                      'Sets, reps & kg',
                      Icons.fitness_center,
                      ExerciseType.weightAndReps,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTypeCard(
                      'Reps Only',
                      'Sets & reps, no weight',
                      Icons.repeat,
                      ExerciseType.repsOnly,
                      AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTypeCard(
                      'Cardio',
                      'Duration only',
                      Icons.directions_walk,
                      ExerciseType.cardio,
                      AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.difficulty,
                style:
                    AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDifficultyChip(
                      AppStrings.easy,
                      ExerciseDifficulty.easy,
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDifficultyChip(
                      AppStrings.medium,
                      ExerciseDifficulty.medium,
                      AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDifficultyChip(
                      AppStrings.hard,
                      ExerciseDifficulty.hard,
                      AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.muscleGroups,
                style:
                    AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (_selectedMuscleGroups.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    AppStrings.pressToAddMuscleGroups,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedMuscleGroups.entries.map((entry) {
                      return Chip(
                        label: Text(
                          '${_getMuscleGroupLabel(entry.key)} (${_getIntensityLabel(entry.value)})',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        backgroundColor: _getIntensityColor(entry.value),
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                        onDeleted: () {
                          setState(
                              () => _selectedMuscleGroups.remove(entry.key));
                        },
                      );
                    }).toList(),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _showMuscleGroupSelector,
                icon: const Icon(Icons.add),
                label: Text(AppStrings.addMuscleGroup),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? AppStrings.save : AppStrings.createExercise,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
