import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import 'exercise_library_screen.dart';

class CreateWorkoutScreen extends StatefulWidget {
  final Workout? existingWorkout;

  const CreateWorkoutScreen({
    super.key,
    this.existingWorkout,
  });

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<WorkoutExercise> _workoutExercises = [];
  static const String _draftKey = 'workout_draft';
  bool _isDraft = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.existingWorkout != null) {
      _nameController.text = widget.existingWorkout!.name;
      _workoutExercises = List.from(widget.existingWorkout!.exercises);
    } else {
      _loadDraft();
    }
    _nameController.addListener(_saveDraft);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.removeListener(_saveDraft);
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveDraft();
    }
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString(_draftKey);

      if (draftJson != null && draftJson.isNotEmpty) {
        final draft = jsonDecode(draftJson);
        setState(() {
          _isDraft = true;
          _nameController.text = draft['name'] ?? '';
          _workoutExercises = (draft['exercises'] as List?)
                  ?.map((e) => WorkoutExercise.fromJson(e))
                  .toList() ??
              [];
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Draft restored'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading draft: $e');
    }
  }

  Future<void> _saveDraft() async {
    if (widget.existingWorkout != null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = {
        'name': _nameController.text,
        'exercises': _workoutExercises.map((e) => e.toJson()).toList(),
      };
      await prefs.setString(_draftKey, jsonEncode(draft));
    } catch (e) {
      print('Error saving draft: $e');
    }
  }

  Future<void> _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
      _isDraft = false;
    } catch (e) {
      print('Error clearing draft: $e');
    }
  }

  void _addExercise() async {
    final selectedExercise = await showDialog<Exercise>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        child: ExerciseLibraryScreen(
          onExerciseSelected: (exercise) {
            Navigator.of(dialogContext).pop(exercise);
          },
        ),
      ),
    );

    if (selectedExercise != null && mounted) {
      _showExerciseConfigDialog(selectedExercise);
    }
  }

  void _showExerciseConfigDialog(Exercise exercise,
      [WorkoutExercise? existing]) async {
    final setsController = TextEditingController(
      text: existing?.sets.toString() ?? '3',
    );
    final repsController = TextEditingController(
      text: existing?.targetReps.toString() ?? '10',
    );
    final weightController = TextEditingController(
      text: existing?.weight.toString() ?? '0',
    );

    final result = await showDialog<WorkoutExercise>(
        context: context,
        builder: (dialogContext) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Configure ${exercise.name}',
                          style: AppTextStyles.h4,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: setsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: AppStrings.sets,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: repsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: AppStrings.targetReps,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: '${AppStrings.weight} (kg)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
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
                                onPressed: () {
                                  final workoutExercise = WorkoutExercise(
                                    exercise: exercise,
                                    sets: int.parse(setsController.text),
                                    targetReps: int.parse(repsController.text),
                                    weight: double.parse(weightController.text),
                                  );

                                  Navigator.of(dialogContext)
                                      .pop(workoutExercise);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.textOnPrimary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(AppStrings.save),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));

    if (result != null && mounted) {
      setState(() {
        if (existing != null) {
          final index = _workoutExercises.indexOf(existing);
          _workoutExercises[index] = result;
        } else {
          _workoutExercises.add(result);
        }
      });

      _saveDraft();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing != null
                ? 'Exercise updated: ${result.exercise.name}'
                : 'Exercise added: ${result.exercise.name}',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _setAlternativeExercise(
      WorkoutExercise workoutExercise, int index) async {
    final selectedExercise = await showDialog<Exercise>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        child: ExerciseLibraryScreen(
          onExerciseSelected: (exercise) {
            Navigator.of(dialogContext).pop(exercise);
          },
        ),
      ),
    );

    if (selectedExercise != null && mounted) {
      setState(() {
        _workoutExercises[index] = workoutExercise.copyWith(
          alternativeExercise: selectedExercise,
        );
      });

      _saveDraft();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alternative set: ${selectedExercise.name}',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _saveWorkout() async {
    if (_formKey.currentState!.validate() && _workoutExercises.isNotEmpty) {
      final workout = Workout(
        id: widget.existingWorkout?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        exercises: _workoutExercises,
        createdAt: widget.existingWorkout?.createdAt ?? DateTime.now(),
      );

      await _clearDraft();
      if (mounted) {
        Navigator.of(context).pop(workout);
      }
    } else if (_workoutExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          widget.existingWorkout != null
              ? 'Edit Workout'
              : AppStrings.createWorkout,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveWorkout,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildAddExerciseButton(),
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.workoutName,
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
            ),
            Expanded(
              child: _workoutExercises.isEmpty
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
                            'No exercises added yet',
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add exercises',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _workoutExercises.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = _workoutExercises.removeAt(oldIndex);
                          _workoutExercises.insert(newIndex, item);
                        });
                        _saveDraft();
                      },
                      itemBuilder: (context, index) {
                        final workoutExercise = _workoutExercises[index];
                        return _buildExerciseCard(workoutExercise, index,
                            key: ValueKey(workoutExercise.exercise.id));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(WorkoutExercise workoutExercise, int index,
      {required Key key}) {
    Color difficultyColor;
    switch (workoutExercise.exercise.difficulty) {
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
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.drag_handle, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: difficultyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: difficultyColor,
                  ),
                ),
              ],
            ),
            title: Text(
              workoutExercise.exercise.name,
              style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${workoutExercise.sets} sets x ${workoutExercise.targetReps} reps, ${workoutExercise.weight} kg',
              style: AppTextStyles.body2,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit exercise',
                  onPressed: () => _showExerciseConfigDialog(
                      workoutExercise.exercise, workoutExercise),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete exercise',
                  onPressed: () {
                    setState(() {
                      _workoutExercises.removeAt(index);
                    });
                    _saveDraft();
                  },
                ),
              ],
            ),
          ),
          if (workoutExercise.alternativeExercise != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border(
                  top: BorderSide(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.swap_horiz,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Alternative: ${workoutExercise.alternativeExercise!.name}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _workoutExercises[index] = workoutExercise.copyWith(
                          clearAlternative: true,
                        );
                      });
                      _saveDraft();
                    },
                    tooltip: 'Remove alternative',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _setAlternativeExercise(workoutExercise, index),
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: Text(
                  workoutExercise.alternativeExercise != null
                      ? 'Change Alternative'
                      : 'Add Alternative',
                  style: AppTextStyles.caption,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddExerciseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _addExercise,
          icon: const Icon(Icons.add),
          label: Text(AppStrings.addExercise),
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
}
