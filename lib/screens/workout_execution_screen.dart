import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';
import '../models/workout_history.dart';
import '../services/data_manager.dart';
import '../services/leaderboard_service.dart';
import '../services/settings_service.dart';
import '../services/profile_service.dart';
import '../services/progression_service.dart';

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
  Timer? _timer;
  int _totalDurationSeconds = 0;
  final List<ExerciseResult> _exerciseResults = [];
  ExerciseResult? _currentExerciseResult;
  final DataManager _dataManager = DataManager();
  ExerciseResult? _previousExercisePerformance;
  bool _workoutFinished = false;

  int? _activeSetIndex;
  List<TextEditingController> _repsControllers = [];
  List<TextEditingController> _weightControllers = [];
  List<int> _setTimers = [];
  List<bool> _setCompleted = [];

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _startTotalTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final c in _repsControllers) {
      c.dispose();
    }
    for (final c in _weightControllers) {
      c.dispose();
    }
    _repsControllers = [];
    _weightControllers = [];
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

    _loadPreviousPerformance();
    _initSetControllers(_exerciseQueue[0]);
  }

  void _initSetControllers(WorkoutExercise workoutExercise) {
    _disposeControllers();
    final numSets = workoutExercise.sets;
    _repsControllers = List.generate(
      numSets,
      (_) => TextEditingController(),
    );
    _weightControllers = List.generate(
      numSets,
      (_) => TextEditingController(
        text:
            workoutExercise.weight > 0 ? workoutExercise.weight.toString() : '',
      ),
    );
    _setTimers = List.filled(numSets, 0);
    _setCompleted = List.filled(numSets, false);
    _activeSetIndex = null;
  }

  void _loadPreviousPerformance() {
    final histories = _dataManager.workoutHistory;
    final exerciseId = _currentExerciseResult!.exercise.id;

    for (var history in histories.reversed) {
      for (var exerciseResult in history.session.exerciseResults) {
        if (exerciseResult.exercise.id == exerciseId &&
            exerciseResult.setResults.isNotEmpty) {
          setState(() {
            _previousExercisePerformance = exerciseResult;
          });
          return;
        }
      }
    }

    setState(() {
      _previousExercisePerformance = null;
    });
  }

  void _startTotalTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _totalDurationSeconds++;
          if (_activeSetIndex != null) {
            _setTimers[_activeSetIndex!]++;
          }
        });
      }
    });
  }

  void _startSet(int index) {
    setState(() {
      if (_activeSetIndex != null) return;
      _activeSetIndex = index;
      _setTimers[index] = 0;
    });
  }

  void _completeSetAtIndex(int index) {
    final repsText = _repsControllers[index].text;
    final weightText = _weightControllers[index].text;
    final actualReps = int.tryParse(repsText) ?? 0;
    final actualWeight = double.tryParse(weightText) ??
        _currentExerciseResult!.targetWeight.clamp(0.0, double.infinity);

    if (actualReps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the number of reps'),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _setCompleted[index] = true;
      _activeSetIndex = null;

      final setResult = ExerciseSetResult(
        setNumber: index + 1,
        actualReps: actualReps,
        weight: actualWeight,
        timestamp: DateTime.now(),
        durationSeconds: _setTimers[index],
      );

      _currentExerciseResult!.setResults.add(setResult);
    });

    if (_setCompleted.every((c) => c)) {
      Future.microtask(() => _showExerciseDifficultyDialog());
    }
  }

  void _swapExercise(WorkoutExercise currentWorkoutExercise) {
    if (currentWorkoutExercise.alternativeExercise == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Swap Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current exercise:',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentWorkoutExercise.exercise.name,
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Alternative exercise:',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentWorkoutExercise.alternativeExercise!.name,
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              currentWorkoutExercise.alternativeExercise!.description,
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                final alternative = currentWorkoutExercise.alternativeExercise!;
                _exerciseQueue[_currentExerciseIndex] =
                    currentWorkoutExercise.copyWith(
                  exercise: alternative,
                  alternativeExercise: currentWorkoutExercise.exercise,
                );

                _currentExerciseResult = ExerciseResult(
                  exercise: alternative,
                  targetSets: currentWorkoutExercise.sets,
                  targetReps: currentWorkoutExercise.targetReps,
                  targetWeight: currentWorkoutExercise.weight,
                  setResults: [],
                );

                _initSetControllers(_exerciseQueue[_currentExerciseIndex]);
                _loadPreviousPerformance();
              });
              Navigator.of(dialogContext).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Switched to ${currentWorkoutExercise.alternativeExercise!.name}',
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Swap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showExerciseDifficultyDialog() {
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
                          Navigator.of(context).pop();
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

      _currentExerciseResult = ExerciseResult(
        exercise: _exerciseQueue[_currentExerciseIndex].exercise,
        targetSets: _exerciseQueue[_currentExerciseIndex].sets,
        targetReps: _exerciseQueue[_currentExerciseIndex].targetReps,
        targetWeight: _exerciseQueue[_currentExerciseIndex].weight,
        setResults: [],
      );

      _initSetControllers(_exerciseQueue[_currentExerciseIndex]);
      _loadPreviousPerformance();
    });
  }

  void _skipCurrentExercise() {
    if (_exerciseQueue.isEmpty) return;
    final current = _exerciseQueue[_currentExerciseIndex];
    final id = current.exercise.id;
    _skipCounts[id] = (_skipCounts[id] ?? 0) + 1;
    final count = _skipCounts[id]!;

    setState(() {
      final moved = _exerciseQueue.removeAt(_currentExerciseIndex);
      if (count == 1) {
        // Move to next position (right after current)
        final insertIndex = (_currentExerciseIndex + 1).clamp(0, _exerciseQueue.length);
        _exerciseQueue.insert(insertIndex, moved);
      } else {
        // Move to end of queue
        _exerciseQueue.add(moved);
      }

      if (_exerciseQueue.isEmpty) {
        _finishWorkout();
        return;
      }

      if (_currentExerciseIndex >= _exerciseQueue.length) {
        _currentExerciseIndex = 0;
      }

      _currentExerciseResult = ExerciseResult(
        exercise: _exerciseQueue[_currentExerciseIndex].exercise,
        targetSets: _exerciseQueue[_currentExerciseIndex].sets,
        targetReps: _exerciseQueue[_currentExerciseIndex].targetReps,
        targetWeight: _exerciseQueue[_currentExerciseIndex].weight,
        setResults: [],
      );

      _initSetControllers(_exerciseQueue[_currentExerciseIndex]);
      _loadPreviousPerformance();
    });
  }

  void _finishWorkout() async {
    if (_workoutFinished) return;

    _workoutFinished = true;
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

    try {
      final progressionService = ProgressionService();
      await progressionService.applyProgressionToProgram(widget.workout.id);
      debugPrint(
          '[WORKOUT] Progression applied to program: ${widget.workout.name}');
    } catch (e) {
      debugPrint('[WORKOUT] Error applying progression: $e');
    }

    try {
      if (!mounted) return;
      final leaderboardService =
          Provider.of<LeaderboardService>(context, listen: false);
      final settingsService =
          Provider.of<SettingsService>(context, listen: false);
      final workoutHistory = DataManager().workoutHistory;

      final profileService =
          Provider.of<ProfileService>(context, listen: false);
      await leaderboardService.syncUserStats(
        workoutHistory: workoutHistory,
        isProfileHidden: settingsService.isProfileHidden,
        userBodyWeight: profileService.weightKg,
      );
    } catch (e) {
      debugPrint('[WORKOUT] Error syncing stats to Firebase: $e');
    }

    if (!mounted) return;
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

  void _tryFinishExerciseEarly() {
    final completedCount = _setCompleted.where((c) => c).length;
    if (completedCount == 0) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finish exercise early?'),
        content: Text(
          'You completed $completedCount of ${_setCompleted.length} sets. Finish this exercise now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showExerciseDifficultyDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int index, WorkoutExercise currentExercise) {
    final isActive = _activeSetIndex == index;
    final isCompleted = _setCompleted[index];
    final setNum = index + 1;

    ExerciseSetResult? prevSet;
    if (_previousExercisePerformance != null &&
        index < _previousExercisePerformance!.setResults.length) {
      prevSet = _previousExercisePerformance!.setResults[index];
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCompleted
            ? BorderSide(color: AppColors.success, width: 2)
            : isActive
                ? BorderSide(color: AppColors.primary, width: 2)
                : BorderSide.none,
      ),
      color: isCompleted ? AppColors.success.withValues(alpha: 0.05) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isCompleted
                      ? AppColors.success
                      : isActive
                          ? AppColors.primary
                          : AppColors.divider,
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '$setNum',
                          style: AppTextStyles.caption.copyWith(
                            color: isActive
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target: ${currentExercise.targetReps} reps'
                        '${currentExercise.weight > 0 ? " × ${currentExercise.weight} kg" : ""}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (prevSet != null)
                        Text(
                          'Last time: ${prevSet.actualReps} reps'
                          '${prevSet.weight > 0 ? " × ${prevSet.weight} kg" : ""}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isActive)
                  Text(
                    _formatDuration(_setTimers[index]),
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: TextField(
                      controller: _repsControllers[index],
                      keyboardType: TextInputType.number,
                      enabled: !isCompleted,
                      decoration: InputDecoration(
                        hintText: '${currentExercise.targetReps}',
                        labelText: 'Reps',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: AppTextStyles.body2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: TextField(
                      controller: _weightControllers[index],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      enabled: !isCompleted,
                      decoration: InputDecoration(
                        hintText: currentExercise.weight > 0
                            ? '${currentExercise.weight}'
                            : '0',
                        labelText: 'kg',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: AppTextStyles.body2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 42,
                  width: 90,
                  child: isCompleted
                      ? OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.success),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Icon(Icons.check, color: AppColors.success),
                        )
                      : isActive
                          ? ElevatedButton(
                              onPressed: () => _completeSetAtIndex(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: AppColors.textOnPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Done'),
                            )
                          : ElevatedButton(
                              onPressed: _activeSetIndex != null
                                  ? null
                                  : () => _startSet(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textOnPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Start'),
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    final completedExercises =
        widget.workout.exercises.length - _exerciseQueue.length;
    final totalExercises = widget.workout.exercises.length;
    final progress = completedExercises / totalExercises;
    final allSetsCompleted = _setCompleted.every((c) => c);
    final anySetsCompleted = _setCompleted.any((c) => c);

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercise ${completedExercises + 1} of $totalExercises',
                    style: AppTextStyles.caption,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(_totalDurationSeconds),
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            currentExercise.exercise.name,
                            style: AppTextStyles.h3,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if ((_skipCounts[currentExercise.exercise.id] ?? 0) ==
                            1) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentExercise.exercise.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (currentExercise.alternativeExercise != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () => _swapExercise(currentExercise),
                          icon: const Icon(Icons.swap_horiz, size: 18),
                          label: Text('Swap', style: AppTextStyles.caption),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ...List.generate(
                      currentExercise.sets,
                      (i) => _buildSetRow(i, currentExercise),
                    ),
                    const SizedBox(height: 16),
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
                      height: 50,
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
                        height: 50,
                        child: ElevatedButton(
                          onPressed: allSetsCompleted
                              ? _showExerciseDifficultyDialog
                              : anySetsCompleted
                                  ? _tryFinishExerciseEarly
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: allSetsCompleted
                                ? AppColors.success
                                : AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            allSetsCompleted
                                ? 'Finish Exercise'
                                : 'Finish Early',
                            style: AppTextStyles.button.copyWith(fontSize: 16),
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
