import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../models/exercise.dart';
import '../services/data_manager.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  final Function(Exercise) onExerciseSelected;

  const ExerciseLibraryScreen({
    super.key,
    required this.onExerciseSelected,
  });

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _dataManager = DataManager();
  List<Exercise> _filteredExercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadExercises() {
    _filteredExercises = List.from(_dataManager.exercises);
  }

  void _filterExercises(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredExercises = List.from(_dataManager.exercises);
      } else {
        _filteredExercises = _dataManager.exercises
            .where((exercise) =>
                exercise.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showCreateExerciseDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateExerciseDialog(
        onExerciseCreated: (exercise) {
          _dataManager.addExercise(exercise);
          setState(() {
            _filteredExercises = List.from(_dataManager.exercises);
          });
        },
      ),
    );
  }

  Widget _buildCreateExerciseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showCreateExerciseDialog,
          icon: const Icon(Icons.add),
          label: Text(AppStrings.createExercise),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
          'Exercise Library',
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
      ),
      body: Column(
        children: [
          _buildCreateExerciseButton(),
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              onChanged: _filterExercises,
              decoration: InputDecoration(
                hintText: '${AppStrings.search}...',
                hintStyle: AppTextStyles.body2,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No exercises found',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return _buildExerciseCard(exercise);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    Color difficultyColor;
    switch (exercise.difficulty) {
      case ExerciseDifficulty.easy:
        difficultyColor = AppColors.success;
        break;
      case ExerciseDifficulty.medium:
        difficultyColor = AppColors.warning;
        break;
      case ExerciseDifficulty.hard:
        difficultyColor = AppColors.error;
        break;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: difficultyColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.fitness_center,
            color: difficultyColor,
            size: 24,
          ),
        ),
        title: Text(
          exercise.name,
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          exercise.description,
          style: AppTextStyles.body2,
        ),
        trailing: const Icon(Icons.add_circle_outline),
        onTap: () {
          widget.onExerciseSelected(exercise);
        },
      ),
    );
  }
}

class CreateExerciseDialog extends StatefulWidget {
  final Function(Exercise) onExerciseCreated;

  const CreateExerciseDialog({
    super.key,
    required this.onExerciseCreated,
  });

  @override
  State<CreateExerciseDialog> createState() => _CreateExerciseDialogState();
}

class _CreateExerciseDialogState extends State<CreateExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  ExerciseDifficulty _selectedDifficulty = ExerciseDifficulty.medium;

  final Map<MuscleGroup, MuscleGroupIntensity> _selectedMuscleGroups = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createExercise() {
    if (_formKey.currentState!.validate()) {
      final muscleTags = _selectedMuscleGroups.entries
          .map((entry) => MuscleGroupTag(
                group: entry.key,
                intensity: entry.value,
              ))
          .toList();

      final exercise = Exercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        difficulty: _selectedDifficulty,
        createdAt: DateTime.now(),
        muscleGroups: muscleTags,
      );

      widget.onExerciseCreated(exercise);
      Navigator.of(context).pop();
    }
  }

  String _getMuscleGroupLabel(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return 'Грудь';
      case MuscleGroup.back:
        return 'Спина';
      case MuscleGroup.legs:
        return 'Ноги';
      case MuscleGroup.shoulders:
        return 'Плечи';
      case MuscleGroup.biceps:
        return 'Бицепс';
      case MuscleGroup.triceps:
        return 'Трицепс';
      case MuscleGroup.forearms:
        return 'Предплечья';
      case MuscleGroup.wrists:
        return 'Кисти';
      case MuscleGroup.core:
        return 'Кор';
      case MuscleGroup.glutes:
        return 'Ягодицы';
      case MuscleGroup.calves:
        return 'Икры';
      case MuscleGroup.cardio:
        return 'Кардио';
    }
  }

  String _getIntensityLabel(MuscleGroupIntensity intensity) {
    switch (intensity) {
      case MuscleGroupIntensity.primary:
        return 'Основная';
      case MuscleGroupIntensity.secondary:
        return 'Вторичная';
      case MuscleGroupIntensity.stabilizer:
        return 'Стабилизация';
    }
  }

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pick muscle group',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: MuscleGroup.values.map((group) {
                    return ListTile(
                      title: Text(_getMuscleGroupLabel(group)),
                      trailing: _selectedMuscleGroups.containsKey(group)
                          ? Icon(Icons.check, color: AppColors.success)
                          : null,
                      onTap: () {
                        Navigator.pop(context, group);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((selectedGroup) {
      if (selectedGroup != null) {
        _showIntensitySelector(selectedGroup);
      }
    });
  }

  void _showIntensitySelector(MuscleGroup group) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Intensity for\n${_getMuscleGroupLabel(group)}',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...MuscleGroupIntensity.values.map((intensity) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedMuscleGroups[group] = intensity;
                      });
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
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.createExercise,
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.exerciseName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.errorFieldRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppStrings.description,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.errorFieldRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.difficulty,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
                const SizedBox(height: 16),
                Text(
                  'Muscle Groups',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedMuscleGroups.isEmpty)
                  Text(
                    'Press the button below to add muscle groups',
                    style: AppTextStyles.caption,
                  )
                else
                  Wrap(
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
                        deleteIcon: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textOnPrimary,
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedMuscleGroups.remove(entry.key);
                          });
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _showMuscleGroupSelector,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Muscle Group'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(AppStrings.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _createExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(AppStrings.create),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
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
}
