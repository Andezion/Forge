import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';
import '../models/workout_history.dart';
import '../services/data_manager.dart';

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
  late List<WorkoutExercise> _exerciseQueue;
  final Map<String, int> _skipCounts = {};
  final List<Exercise> _skippedExercises = [];
  int _currentSetNumber = 1;
  Timer? _timer;
  int _setDurationSeconds = 0;
  int _totalDurationSeconds = 0;
  bool _isSetInProgress = false;
  final List<ExerciseResult> _exerciseResults = [];
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

    _exerciseQueue = List<WorkoutExercise>.from(widget.workout.exercises);

    _currentExerciseResult = ExerciseResult(
      exercise: _exerciseQueue[0].exercise,
      targetSets: _exerciseQueue[0].sets,
      targetReps: _exerciseQueue[0].targetReps,
      targetWeight: _exerciseQueue[0].weight,
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
    final weightController = TextEditingController(
      text: _currentExerciseResult!.targetWeight > 0
          ? _currentExerciseResult!.targetWeight.toString()
          : '',
    );

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
              const SizedBox(height: 16),
              TextFormField(
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '${AppStrings.weight} (kg)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final actualReps = int.tryParse(repsController.text) ?? 0;
                  final parsedWeight = double.tryParse(weightController.text);
                  final actualWeight = parsedWeight ??
                      _currentExerciseResult!.targetWeight
                          .clamp(0.0, double.infinity);

                  if (actualReps > 0) {
                    _completeSet(actualReps, actualWeight);
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

  void _completeSet(int actualReps, double weight) {
    print('[WORKOUT_EXEC] Completing set $_currentSetNumber');
    if (_currentExerciseResult!.setResults
        .any((s) => s.setNumber == _currentSetNumber)) {
      print('[WORKOUT_EXEC] Set already completed, ignoring duplicate');
      return;
    }

    setState(() {
      _isSetInProgress = false;

      final setResult = ExerciseSetResult(
        setNumber: _currentSetNumber,
        actualReps: actualReps,
        weight: weight,
        timestamp: DateTime.now(),
        durationSeconds: _setDurationSeconds,
      );

      _currentExerciseResult!.setResults.add(setResult);
      print(
          '[WORKOUT_EXEC] Set completed. Total sets done: ${_currentExerciseResult!.setResults.length}/${_currentExerciseResult!.targetSets}');

      if (_currentSetNumber >= _currentExerciseResult!.targetSets) {
        print(
            '[WORKOUT_EXEC] All sets completed for exercise. Showing difficulty dialog...');

        Future.microtask(() => _showExerciseDifficultyDialog());
      } else {
        _currentSetNumber++;
        _setDurationSeconds = 0;
        print('[WORKOUT_EXEC] Moving to set $_currentSetNumber');
      }
    });
  }

  void _showExerciseDifficultyDialog() {
    print('[WORKOUT_EXEC] Showing exercise difficulty dialog...');
    ExerciseDifficulty? selectedDifficulty;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
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
                          print(
                              '[WORKOUT_EXEC] Difficulty selected: $selectedDifficulty. Closing dialog...');
                          Navigator.of(context).pop();
                          print('[WORKOUT_EXEC] Difficulty dialog closed.');
                          _completeExercise(selectedDifficulty!);
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
          color: isSelected ? color : color.withValues(alpha: 0.1),
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
    print(
        '[WORKOUT_EXEC] Completing exercise: ${_currentExerciseResult!.exercise.name}');
    print('[WORKOUT_EXEC] Perceived difficulty: $perceivedDifficulty');
    print(
        '[WORKOUT_EXEC] Current exercise index: $_currentExerciseIndex, Total exercises: ${_exerciseQueue.length}');

    setState(() {
      _currentExerciseResult = _currentExerciseResult!.copyWith(
        perceivedDifficulty: perceivedDifficulty,
      );
      _exerciseResults.add(_currentExerciseResult!);

      _exerciseQueue.removeAt(_currentExerciseIndex);

      if (_exerciseQueue.isEmpty) {
        _finishWorkout();
        return;
      }

      if (_currentExerciseIndex >= _exerciseQueue.length) {
        _currentExerciseIndex = 0;
      }

      _currentSetNumber = 1;
      _setDurationSeconds = 0;

      _currentExerciseResult = ExerciseResult(
        exercise: _exerciseQueue[_currentExerciseIndex].exercise,
        targetSets: _exerciseQueue[_currentExerciseIndex].sets,
        targetReps: _exerciseQueue[_currentExerciseIndex].targetReps,
        targetWeight: _exerciseQueue[_currentExerciseIndex].weight,
        setResults: [],
      );
    });
  }

  void _skipCurrentExercise() {
    if (_exerciseQueue.isEmpty) return;
    final current = _exerciseQueue[_currentExerciseIndex];
    final id = current.exercise.id;
    _skipCounts[id] = (_skipCounts[id] ?? 0) + 1;
    final count = _skipCounts[id]!;

    setState(() {
      if (count >= 2) {
        _exerciseQueue.removeAt(_currentExerciseIndex);
        _skippedExercises.add(current.exercise);
      } else {
        final moved = _exerciseQueue.removeAt(_currentExerciseIndex);
        _exerciseQueue.add(moved);
      }

      if (_exerciseQueue.isEmpty) {
        _finishWorkout();
        return;
      }

      if (_currentExerciseIndex >= _exerciseQueue.length) {
        _currentExerciseIndex = 0;
      }

      _currentSetNumber = 1;
      _setDurationSeconds = 0;
      _currentExerciseResult = ExerciseResult(
        exercise: _exerciseQueue[_currentExerciseIndex].exercise,
        targetSets: _exerciseQueue[_currentExerciseIndex].sets,
        targetReps: _exerciseQueue[_currentExerciseIndex].targetReps,
        targetWeight: _exerciseQueue[_currentExerciseIndex].weight,
        setResults: [],
      );
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

    final history = WorkoutHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      session: completedSession,
    );
    DataManager().addWorkoutHistory(history);

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
                'Completed: ${_exerciseResults.length}',
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),
              if (_skippedExercises.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Skipped Exercises:',
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._skippedExercises.map((exercise) => Padding(
                            padding: const EdgeInsets.only(top: 4, left: 28),
                            child: Text(
                              '• ${exercise.name}',
                              style: AppTextStyles.body2,
                            ),
                          )),
                    ],
                  ),
                ),
              ],
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
    if (_exerciseQueue.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _finishWorkout();
        }
      });

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          title: Text(
            widget.workout.name,
            style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No remaining exercises',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final currentExercise = _exerciseQueue[_currentExerciseIndex];
    final progress = (_currentExerciseIndex + 1) / _exerciseQueue.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

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
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                              'Exercise ${_currentExerciseIndex + 1} of ${_exerciseQueue.length}',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    currentExercise.exercise.name,
                                    style: AppTextStyles.h2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if ((_skipCounts[currentExercise.exercise.id] ??
                                        0) ==
                                    1)
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.warning,
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: AppColors.surface),
                                    ),
                                  ),
                              ],
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
                                color: AppColors.primary.withValues(alpha: 0.1),
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
                                  AppColors.success.withValues(alpha: 0.1),
                              child: Text(
                                '${setResult.setNumber}',
                                style: AppTextStyles.body1.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text('${setResult.actualReps} reps'),
                            subtitle: Text('${setResult.weight} kg'),
                            trailing: Text(
                              _formatDuration(setResult.durationSeconds),
                              style: AppTextStyles.caption,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: Row(
                  children: [
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _skipCurrentExercise,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.warning),
                          foregroundColor: AppColors.warning,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(AppStrings.skip),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSetInProgress
                              ? _showCompleteSetDialog
                              : _startSet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSetInProgress
                                ? AppColors.success
                                : AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
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
            ),
          ],
        ),
      ),
    );
  }
}
