import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';

class WorkoutExecutionScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutExecutionScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutExecutionScreen> createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  late WorkoutSession _session;
  int _currentExerciseIndex = 0;
  int _currentSetNumber = 1;
  Timer? _timer;
  int _setDurationSeconds = 0;
  int _totalDurationSeconds = 0;
  bool _isSetInProgress = false;
  List<ExerciseResult> _exerciseResults = [];
  ExerciseResult? _currentExerciseResult;

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _startTotalTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeSession() {
    _session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutId: widget.workout.id,
      workoutName: widget.workout.name,
      startTime: DateTime.now(),
      exerciseResults: [],
      status: WorkoutSessionStatus.inProgress,
      totalDurationSeconds: 0,
    );

    _currentExerciseResult = ExerciseResult(
      exercise: widget.workout.exercises[0].exercise,
      targetSets: widget.workout.exercises[0].sets,
      targetReps: widget.workout.exercises[0].targetReps,
      targetWeight: widget.workout.exercises[0].weight,
      setResults: [],
    );
  }

  void _startTotalTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _totalDurationSeconds++;
          if (_isSetInProgress) {
            _setDurationSeconds++;
          }
        });
      }
    });
  }

  void _startSet() {
    setState(() {
      _isSetInProgress = true;
      _setDurationSeconds = 0;
    });
  }

  void _showCompleteSetDialog() {
    final repsController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
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
                'Set $_currentSetNumber Complete',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Target: ${_currentExerciseResult!.targetReps} reps',
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: repsController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: AppStrings.actualReps,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final actualReps = int.tryParse(repsController.text) ?? 0;
                  if (actualReps > 0) {
                    _completeSet(actualReps);
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppStrings.done),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completeSet(int actualReps) {
    setState(() {
      _isSetInProgress = false;

      final setResult = ExerciseSetResult(
        setNumber: _currentSetNumber,
        actualReps: actualReps,
        weight: _currentExerciseResult!.targetWeight,
        timestamp: DateTime.now(),
        durationSeconds: _setDurationSeconds,
      );

      _currentExerciseResult!.setResults.add(setResult);

      if (_currentSetNumber >= _currentExerciseResult!.targetSets) {
        _showExerciseDifficultyDialog();
      } else {
        _currentSetNumber++;
        _setDurationSeconds = 0;
      }
    });
  }

  void _showExerciseDifficultyDialog() {
    ExerciseDifficulty? selectedDifficulty;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
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
                  'How was this exercise?',
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _currentExerciseResult!.exercise.name,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildDifficultyButton(
                  AppStrings.easy,
                  ExerciseDifficulty.easy,
                  AppColors.success,
                  selectedDifficulty,
                  (difficulty) {
                    setDialogState(() {
                      selectedDifficulty = difficulty;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildDifficultyButton(
                  AppStrings.medium,
                  ExerciseDifficulty.medium,
                  AppColors.warning,
                  selectedDifficulty,
                  (difficulty) {
                    setDialogState(() {
                      selectedDifficulty = difficulty;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildDifficultyButton(
                  AppStrings.hard,
                  ExerciseDifficulty.hard,
                  AppColors.error,
                  selectedDifficulty,
                  (difficulty) {
                    setDialogState(() {
                      selectedDifficulty = difficulty;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: selectedDifficulty != null
                      ? () {
                          _completeExercise(selectedDifficulty!);
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppStrings.next),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    String label,
    ExerciseDifficulty difficulty,
    Color color,
    ExerciseDifficulty? selectedDifficulty,
    Function(ExerciseDifficulty) onTap,
  ) {
    final isSelected = selectedDifficulty == difficulty;
    return GestureDetector(
      onTap: () => onTap(difficulty),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            color: isSelected ? AppColors.textOnPrimary : color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _completeExercise(ExerciseDifficulty perceivedDifficulty) {
    setState(() {
      _currentExerciseResult = _currentExerciseResult!.copyWith(
        perceivedDifficulty: perceivedDifficulty,
      );
      _exerciseResults.add(_currentExerciseResult!);

      if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
        _currentExerciseIndex++;
        _currentSetNumber = 1;
        _setDurationSeconds = 0;

        _currentExerciseResult = ExerciseResult(
          exercise: widget.workout.exercises[_currentExerciseIndex].exercise,
          targetSets: widget.workout.exercises[_currentExerciseIndex].sets,
          targetReps:
              widget.workout.exercises[_currentExerciseIndex].targetReps,
          targetWeight: widget.workout.exercises[_currentExerciseIndex].weight,
          setResults: [],
        );
      } else {
        _finishWorkout();
      }
    });
  }

  void _finishWorkout() {
    _timer?.cancel();

    final completedSession = _session.copyWith(
      endTime: DateTime.now(),
      exerciseResults: _exerciseResults,
      status: WorkoutSessionStatus.completed,
      totalDurationSeconds: _totalDurationSeconds,
    );

    // TODO: Save session to database

    showDialog(
      context: context,
      barrierDismissible: false,
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
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Workout Complete!',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: ${_formatDuration(_totalDurationSeconds)}',
                style: AppTextStyles.body1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Exercises: ${_exerciseResults.length}',
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(completedSession);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppStrings.done),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = widget.workout.exercises[_currentExerciseIndex];
    final progress =
        (_currentExerciseIndex + 1) / widget.workout.exercises.length;

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Workout?'),
            content: const Text('Your progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          title: Text(
            widget.workout.name,
            style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
          ),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Total: ${_formatDuration(_totalDurationSeconds)}',
                    style: AppTextStyles.h4,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Exercise ${_currentExerciseIndex + 1} of ${widget.workout.exercises.length}',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentExercise.exercise.name,
                              style: AppTextStyles.h2,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentExercise.exercise.description,
                              style: AppTextStyles.body2,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Set $_currentSetNumber of ${currentExercise.sets}',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Target: ${currentExercise.targetReps} reps',
                                    style: AppTextStyles.body1,
                                  ),
                                  if (currentExercise.weight > 0)
                                    Text(
                                      'Weight: ${currentExercise.weight} kg',
                                      style: AppTextStyles.body1,
                                    ),
                                ],
                              ),
                            ),
                            if (_isSetInProgress) ...[
                              const SizedBox(height: 24),
                              Text(
                                _formatDuration(_setDurationSeconds),
                                style: AppTextStyles.h1.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 48,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_currentExerciseResult!.setResults.isNotEmpty) ...[
                      Text(
                        'Completed Sets',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 12),
                      ..._currentExerciseResult!.setResults.map((setResult) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.success.withOpacity(0.1),
                              child: Text(
                                '${setResult.setNumber}',
                                style: AppTextStyles.body1.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text('${setResult.actualReps} reps'),
                            trailing: Text(
                              _formatDuration(setResult.durationSeconds),
                              style: AppTextStyles.caption,
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isSetInProgress ? _showCompleteSetDialog : _startSet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSetInProgress
                        ? AppColors.success
                        : AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isSetInProgress ? 'Complete Set' : 'Start Set',
                    style: AppTextStyles.button.copyWith(fontSize: 18),
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
