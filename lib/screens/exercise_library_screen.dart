import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../models/exercise.dart';
import '../services/data_manager.dart';
import '../utils/muscle_group_utils.dart';
import 'create_exercise_screen.dart';

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
  MuscleGroup? _primaryFilter;
  MuscleGroup? _secondaryFilter;
  MuscleGroup? _stabilizerFilter;

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

  void _applyFilters() {
    final query = _searchController.text;
    setState(() {
      _filteredExercises = _dataManager.exercises.where((exercise) {
        if (query.isNotEmpty &&
            !exercise.name.toLowerCase().contains(query.toLowerCase())) {
          return false;
        }
        if (_primaryFilter != null) {
          final hasPrimary = exercise.muscleGroups.any((mg) =>
              mg.intensity == MuscleGroupIntensity.primary &&
              mg.group == _primaryFilter);
          if (!hasPrimary) return false;
        }
        if (_secondaryFilter != null) {
          final hasSecondary = exercise.muscleGroups.any((mg) =>
              mg.intensity == MuscleGroupIntensity.secondary &&
              mg.group == _secondaryFilter);
          if (!hasSecondary) return false;
        }
        if (_stabilizerFilter != null) {
          final hasStabilizer = exercise.muscleGroups.any((mg) =>
              mg.intensity == MuscleGroupIntensity.stabilizer &&
              mg.group == _stabilizerFilter);
          if (!hasStabilizer) return false;
        }
        return true;
      }).toList();
    });
  }

  void _filterExercises(String query) => _applyFilters();

  void _showCreateExerciseDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateExerciseScreen(
          onExerciseCreated: (exercise) {
            _dataManager.addExercise(exercise);
            setState(() {
              _filteredExercises = List.from(_dataManager.exercises);
            });
          },
        ),
      ),
    );
  }

  Widget _buildMuscleGroupFilters() {
    final items = [
      const DropdownMenuItem<MuscleGroup>(
        value: null,
        child: Text('Any'),
      ),
      ...MuscleGroup.values.map((g) => DropdownMenuItem<MuscleGroup>(
            value: g,
            child: Text(MuscleGroupUtils.getLabel(g)),
          )),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              label: 'Primary',
              value: _primaryFilter,
              items: items,
              color: AppColors.primary,
              onChanged: (v) {
                _primaryFilter = v;
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterDropdown(
              label: 'Secondary',
              value: _secondaryFilter,
              items: items,
              color: AppColors.warning,
              onChanged: (v) {
                _secondaryFilter = v;
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterDropdown(
              label: 'Stabilizer',
              value: _stabilizerFilter,
              items: items,
              color: AppColors.textSecondary,
              onChanged: (v) {
                _stabilizerFilter = v;
                _applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required MuscleGroup? value,
    required List<DropdownMenuItem<MuscleGroup>> items,
    required Color color,
    required ValueChanged<MuscleGroup?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value != null ? color : AppColors.background,
              width: value != null ? 1.5 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MuscleGroup>(
              value: value,
              isExpanded: true,
              isDense: true,
              style: AppTextStyles.caption,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateExerciseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showCreateExerciseDialog,
          icon: const Icon(Icons.add, color: Colors.white),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
          _buildMuscleGroupFilters(),
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

  void _showEditExerciseDialog(Exercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateExerciseScreen(
          existingExercise: exercise,
          onExerciseCreated: (updatedExercise) {
            _dataManager.updateExercise(updatedExercise);
            setState(() {
              _filteredExercises = List.from(_dataManager.exercises);
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${updatedExercise.name} updated'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _deleteExercise(Exercise exercise) async {
    final isUsed = _dataManager.isExerciseUsed(exercise.id);

    if (isUsed) {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exercise in Use'),
          content: Text(
            'The exercise "${exercise.name}" is currently used in one or more workout programs. Are you sure you want to delete it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (shouldDelete != true) return;
    } else {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Exercise'),
          content: Text(
            'Are you sure you want to delete "${exercise.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (shouldDelete != true) return;
    }

    _dataManager.removeExercise(exercise.id);
    setState(() {
      _filteredExercises = List.from(_dataManager.exercises);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${exercise.name} deleted'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.primary,
              onPressed: () => _showEditExerciseDialog(exercise),
              tooltip: AppStrings.edit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              onPressed: () => _deleteExercise(exercise),
              tooltip: AppStrings.delete,
            ),
            const Icon(Icons.add_circle_outline),
          ],
        ),
        onTap: () {
          widget.onExerciseSelected(exercise);
        },
      ),
    );
  }
}

