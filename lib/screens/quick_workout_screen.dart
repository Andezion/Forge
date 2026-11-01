import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';
import '../models/workout_history.dart';
import '../services/data_manager.dart';
import '../services/groq_service.dart';
import '../services/leaderboard_service.dart';
import '../services/settings_service.dart';
import '../services/profile_service.dart';
import '../l10n/l10n.dart';
import '../utils/units.dart';
import '../widgets/fix_set_dialog.dart';
import '../widgets/workout_note_field.dart';
import 'exercise_library_screen.dart';

enum _Mode { idle, exercising }

class QuickWorkoutScreen extends StatefulWidget {
  const QuickWorkoutScreen({super.key});

  @override
  State<QuickWorkoutScreen> createState() => _QuickWorkoutScreenState();
}

class _QuickWorkoutScreenState extends State<QuickWorkoutScreen>
    with WidgetsBindingObserver {
  _Mode _mode = _Mode.idle;
  Timer? _timer;
  int _totalDurationSeconds = 0;
  final DateTime _sessionStartTime = DateTime.now();
  final List<ExerciseResult> _completedExercises = [];
  bool _workoutFinished = false;

  WorkoutExercise? _currentWorkoutExercise;
  ExerciseResult? _currentExerciseResult;
  List<TextEditingController> _repsControllers = [];
  List<TextEditingController> _weightControllers = [];
  List<bool> _setCompleted = [];

  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  Units get _units => Units.of(context, listen: false);

  String _weightFieldText(double kg) => kg > 0 ? _units.weightValue(kg) : '';
  List<int> _setTimers = [];
  int? _activeSetIndex;
  DateTime? _activeSetStartTime;
  ExerciseResult? _previousExercisePerformance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _disposeControllers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _refreshElapsedTime();
        if (_timer == null && mounted && !_workoutFinished) {
          _startTimer();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _timer?.cancel();
        _timer = null;
        break;
      case AppLifecycleState.detached:
        break;
    }
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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _refreshElapsedTime();
    });
  }

  void _refreshElapsedTime() {
    if (!mounted) return;
    setState(() {
      _totalDurationSeconds =
          DateTime.now().difference(_sessionStartTime).inSeconds;
      if (_activeSetIndex != null &&
          _mode == _Mode.exercising &&
          _activeSetStartTime != null) {
        _setTimers[_activeSetIndex!] =
            DateTime.now().difference(_activeSetStartTime!).inSeconds;
      }
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m ${secs}s';
    if (minutes > 0) return '${minutes}m ${secs}s';
    return '${secs}s';
  }

  Future<void> _addExercise() async {
    final exercise = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (_) => ExerciseLibraryScreen(
          onExerciseSelected: (ex) => Navigator.of(context).pop(ex),
        ),
      ),
    );
    if (exercise == null || !mounted) return;
    await _showConfigureExerciseSheet(exercise);
  }

  Future<void> _showConfigureExerciseSheet(Exercise exercise) async {
    final result = await showModalBottomSheet<(int, double)>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ExerciseConfigSheet(exercise: exercise),
    );

    if (result != null && mounted) {
      _startExercise(exercise, result.$1, result.$2);
    }
  }

  void _startExercise(Exercise exercise, int sets, double weight) {
    _disposeControllers();
    final workoutExercise = WorkoutExercise(
      exercise: exercise,
      sets: sets,
      targetReps: 0,
      weight: weight,
    );

    setState(() {
      _currentWorkoutExercise = workoutExercise;
      _currentExerciseResult = ExerciseResult(
        exercise: exercise,
        targetSets: sets,
        targetReps: 0,
        targetWeight: weight,
        setResults: [],
      );
      _repsControllers =
          List.generate(sets, (_) => TextEditingController());
      _weightControllers = List.generate(
        sets,
        (_) => TextEditingController(
          text: _weightFieldText(weight),
        ),
      );
      _setTimers = List.filled(sets, 0, growable: true);
      _setCompleted = List.filled(sets, false, growable: true);
      _activeSetIndex = null;
      _mode = _Mode.exercising;
    });

    _loadPreviousPerformance(exercise);
  }

  void _loadPreviousPerformance(Exercise exercise) {
    final histories = DataManager().workoutHistory;
    for (final history in histories.reversed) {
      for (final result in history.session.exerciseResults) {
        if (result.exercise.id == exercise.id &&
            result.setResults.isNotEmpty) {
          setState(() => _previousExercisePerformance = result);
          return;
        }
      }
    }
    setState(() => _previousExercisePerformance = null);
  }

  void _startSet(int index) {
    if (_activeSetIndex != null) return;
    setState(() {
      _activeSetIndex = index;
      _activeSetStartTime = DateTime.now();
      _setTimers[index] = 0;
    });
  }

  void _addSet() {
    setState(() {
      final current = _currentWorkoutExercise!;
      _currentWorkoutExercise = current.copyWith(sets: current.sets + 1);
      _repsControllers.add(TextEditingController());
      _weightControllers.add(TextEditingController(
        text: _weightFieldText(current.weight),
      ));
      _setTimers.add(0);
      _setCompleted.add(false);
      _currentExerciseResult = _currentExerciseResult!.copyWith(
        targetSets: _currentExerciseResult!.targetSets + 1,
      );
    });
  }

  void _completeSetAtIndex(int index) {
    final actualReps =
        int.tryParse(_repsControllers[index].text) ?? 0;
    final actualWeight =
        _units.parseWeight(_weightControllers[index].text,
                originalKg: _currentWorkoutExercise!.weight) ??
            _currentExerciseResult!.targetWeight;

    if (actualReps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.pleaseEnterReps),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final elapsedSeconds = _activeSetStartTime != null
        ? DateTime.now().difference(_activeSetStartTime!).inSeconds
        : _setTimers[index];

    setState(() {
      _setCompleted[index] = true;
      _activeSetIndex = null;
      _activeSetStartTime = null;
      _currentExerciseResult!.setResults.add(ExerciseSetResult(
        setNumber: index + 1,
        actualReps: actualReps,
        weight: actualWeight,
        timestamp: DateTime.now(),
        durationSeconds: elapsedSeconds,
      ));
    });
  }

  Future<void> _fixSetAtIndex(int index) async {
    final setResults = _currentExerciseResult!.setResults;
    final resultIndex =
        setResults.indexWhere((s) => s.setNumber == index + 1);
    if (resultIndex == -1) return;
    final old = setResults[resultIndex];

    final fixed = await showFixSetDialog(
      context,
      setNumber: old.setNumber,
      reps: old.actualReps,
      weight: old.weight,
    );
    if (fixed == null || !mounted) return;
    final (reps, weight) = fixed;

    setState(() {
      setResults[resultIndex] = ExerciseSetResult(
        setNumber: old.setNumber,
        actualReps: reps,
        weight: weight,
        timestamp: DateTime.now(),
        durationSeconds: old.durationSeconds,
      );
      _repsControllers[index].text = reps.toString();
      _weightControllers[index].text = _weightFieldText(weight);
    });
  }

  void _showDifficultyDialog() {
    ExerciseDifficulty? selectedDifficulty;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
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
                  _l10n.howWasExercise,
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _currentExerciseResult!.exercise.name,
                  style: AppTextStyles.body1
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildDifficultyButton(
                  AppLocalizations.of(context)!.easy,
                  ExerciseDifficulty.easy,
                  AppColors.success,
                  selectedDifficulty,
                  (d) => setDialogState(() => selectedDifficulty = d),
                ),
                const SizedBox(height: 12),
                _buildDifficultyButton(
                  AppLocalizations.of(context)!.medium,
                  ExerciseDifficulty.medium,
                  AppColors.warning,
                  selectedDifficulty,
                  (d) => setDialogState(() => selectedDifficulty = d),
                ),
                const SizedBox(height: 12),
                _buildDifficultyButton(
                  AppLocalizations.of(context)!.hard,
                  ExerciseDifficulty.hard,
                  AppColors.error,
                  selectedDifficulty,
                  (d) => setDialogState(() => selectedDifficulty = d),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: selectedDifficulty != null
                      ? () {
                          Navigator.of(ctx).pop();
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
                  child: Text(AppLocalizations.of(context)!.next),
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
    ExerciseDifficulty? selected,
    Function(ExerciseDifficulty) onTap,
  ) {
    final isSelected = selected == difficulty;
    return GestureDetector(
      onTap: () => onTap(difficulty),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
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

  void _completeExercise(ExerciseDifficulty difficulty) {
    final result =
        _currentExerciseResult!.copyWith(perceivedDifficulty: difficulty);
    setState(() {
      _completedExercises.add(result);
      _mode = _Mode.idle;
      _currentWorkoutExercise = null;
      _currentExerciseResult = null;
      _previousExercisePerformance = null;
    });
    _disposeControllers();
  }

  void _tryFinishExerciseEarly() {
    final completedCount = _setCompleted.where((c) => c).length;
    if (completedCount == 0) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_l10n.finishExerciseEarlyTitle),
        content: Text(
          _l10n.finishExerciseEarlyConfirm(completedCount, _setCompleted.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDifficultyDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: Text(_l10n.finish),
          ),
        ],
      ),
    );
  }

  Future<void> _finishWorkout() async {
    if (_completedExercises.isEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(_l10n.endWorkoutTitle),
          content: Text(_l10n.endWorkoutNoExercises),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                _l10n.endAction,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
      if (confirm != true || !mounted) return;
      Navigator.of(context).pop();
      return;
    }

    if (_workoutFinished) return;
    _workoutFinished = true;
    _timer?.cancel();

    final now = DateTime.now();
    final sessionId = now.millisecondsSinceEpoch.toString();
    final workoutId = 'quick_$sessionId';

    final session = WorkoutSession(
      id: sessionId,
      workoutId: workoutId,
      workoutName: 'Quick Workout',
      startTime: _sessionStartTime,
      endTime: now,
      exerciseResults: _completedExercises,
      status: WorkoutSessionStatus.completed,
      totalDurationSeconds: _totalDurationSeconds,
    );

    final history = WorkoutHistory(
      id: sessionId,
      date: now,
      session: session,
    );
    DataManager().addWorkoutHistory(history);

    double? estimatedCalories;
    String? calorieEstimateError;
    try {
      if (!mounted) return;
      final leaderboardService =
          Provider.of<LeaderboardService>(context, listen: false);
      final settingsService =
          Provider.of<SettingsService>(context, listen: false);
      final profileService =
          Provider.of<ProfileService>(context, listen: false);

      await leaderboardService.syncUserStats(
        workoutHistory: DataManager().workoutHistory,
        isProfileHidden: settingsService.isProfileHidden,
        userBodyWeight: profileService.weightKg,
        country: profileService.country,
        city: profileService.city,
        displayName: settingsService.nickname,
      );

      final groq = GroqService(apiKey: settingsService.groqApiKey);
      estimatedCalories = await groq.estimateWorkoutCalories(
        session: session,
        bodyWeightKg: profileService.weightKg ?? 75.0,
      );
      if (estimatedCalories == null) {
        calorieEstimateError = groq.lastError ?? L10n.current.aiCalorieUnavailable;
      }
    } catch (e) {
      debugPrint('[QUICK_WORKOUT] Post-save error: $e');
    }

    if (!mounted) return;
    String note = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 64),
              const SizedBox(height: 16),
              Text(
                _l10n.workoutComplete,
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _l10n.duration(_formatDuration(_totalDurationSeconds)),
                style: AppTextStyles.body1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _l10n.exercisesTotal(_completedExercises.length),
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),
              if (estimatedCalories != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _l10n.kcalBurned(estimatedCalories.round()),
                        style: AppTextStyles.body1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ] else if (calorieEstimateError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _l10n.calorieEstimateUnavailable(calorieEstimateError),
                          style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              WorkoutNoteField(onChanged: (value) => note = value),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (note.trim().isNotEmpty) {
                    DataManager().updateWorkoutHistoryNote(history.id, note);
                  }
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.done),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetRow(int index) {
    final exercise = _currentWorkoutExercise!;
    final isActive = _activeSetIndex == index;
    final isCompleted = _setCompleted[index];

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
      color: isCompleted
          ? Color.alphaBlend(
              AppColors.success.withValues(alpha: 0.08), AppColors.surface)
          : null,
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
                          '${index + 1}',
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
                        exercise.weight > 0
                            ? _l10n.targetWeight(_units.weight(exercise.weight))
                            : _l10n.bodyweight,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      if (prevSet != null)
                        Text(
                          '${_l10n.lastTimeReps(prevSet.actualReps)}'
                          '${prevSet.weight > 0 ? " × ${_units.weight(prevSet.weight)}" : ""}',
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
                const SizedBox(width: 8),
                FixSetButton(
                  enabled: isCompleted,
                  onPressed: () => _fixSetAtIndex(index),
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
                        hintText: _l10n.reps,
                        labelText: _l10n.reps,
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      enabled: !isCompleted,
                      decoration: InputDecoration(
                        hintText: exercise.weight > 0
                            ? _units.weightValue(exercise.weight)
                            : '0',
                        labelText: _units.weightLabel,
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
                          child:
                              Icon(Icons.check, color: AppColors.success),
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
                              child: Text(_l10n.done),
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
                              child: Text(_l10n.start),
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
    Units.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(_l10n.exitWorkout),
            content: Text(_l10n.progressWillBeLost),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  _l10n.exit,
                  style: const TextStyle(color: AppColors.error),
                ),
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
            _l10n.quickWorkout,
            style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
          ),
        ),
        body:
            _mode == _Mode.idle ? _buildIdleMode() : _buildExercisingMode(),
      ),
    );
  }

  Widget _buildIdleMode() {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, size: 26),
              const SizedBox(width: 10),
              Text(
                _formatDuration(_totalDurationSeconds),
                style:
                    AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: _completedExercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _l10n.noExercisesYet,
                        style: AppTextStyles.h4
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _l10n.tapAddExerciseToStart(_l10n.addExercise),
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: _completedExercises.length,
                  itemBuilder: (_, i) =>
                      _buildCompletedExerciseCard(_completedExercises[i]),
                ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add),
                    label: Text(_l10n.addExercise),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _finishWorkout,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _completedExercises.isEmpty
                            ? AppColors.divider
                            : AppColors.error,
                      ),
                      foregroundColor: _completedExercises.isEmpty
                          ? AppColors.textHint
                          : AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_l10n.endWorkout),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedExerciseCard(ExerciseResult result) {
    final (diffColor, diffLabel) = switch (result.perceivedDifficulty) {
      ExerciseDifficulty.easy => (AppColors.success, AppLocalizations.of(context)!.easy),
      ExerciseDifficulty.medium => (AppColors.warning, AppLocalizations.of(context)!.medium),
      ExerciseDifficulty.hard => (AppColors.error, AppLocalizations.of(context)!.hard),
      _ => (AppColors.textHint, '—'),
    };

    final totalReps = result.setResults.fold(0, (s, r) => s + r.actualReps);
    final weights = result.setResults.map((r) => r.weight).toSet();
    final weightStr = weights.length == 1
        ? (weights.first > 0 ? '× ${_units.weight(weights.first)}' : '')
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check, color: AppColors.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.exercise.name,
                    style: AppTextStyles.body1
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_l10n.setsCount(result.setResults.length)} · ${_l10n.repsCount(totalReps)}'
                    '${weightStr.isNotEmpty ? " $weightStr" : ""}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: diffColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: diffColor.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                diffLabel,
                style: AppTextStyles.caption.copyWith(
                  color: diffColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisingMode() {
    final exercise = _currentWorkoutExercise!;
    final allCompleted = _setCompleted.every((c) => c);
    final anyCompleted = _setCompleted.any((c) => c);

    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _l10n.exerciseNumber(_completedExercises.length + 1),
                style: AppTextStyles.caption,
              ),
              Row(
                children: [
                  const Icon(Icons.timer, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(_totalDurationSeconds),
                    style: AppTextStyles.body1
                        .copyWith(fontWeight: FontWeight.bold),
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
                Text(
                  exercise.exercise.name,
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                if (exercise.exercise.description.isNotEmpty)
                  Text(
                    exercise.exercise.description,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                ...List.generate(exercise.sets, _buildSetRow),
                const SizedBox(height: 4),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _addSet,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(_l10n.addSet, style: AppTextStyles.caption),
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
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: allCompleted
                    ? _showDifficultyDialog
                    : anyCompleted
                        ? _tryFinishExerciseEarly
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      allCompleted ? AppColors.success : AppColors.error,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  allCompleted ? _l10n.finish : _l10n.finishEarly,
                  style: AppTextStyles.button.copyWith(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseConfigSheet extends StatefulWidget {
  final Exercise exercise;

  const _ExerciseConfigSheet({required this.exercise});

  @override
  State<_ExerciseConfigSheet> createState() => _ExerciseConfigSheetState();
}

class _ExerciseConfigSheetState extends State<_ExerciseConfigSheet> {
  late final TextEditingController _setsController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(text: '3');
    _weightController = TextEditingController(
      text: widget.exercise.exerciseType == ExerciseType.repsOnly ? '0' : '',
    );
  }

  @override
  void dispose() {
    _setsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final units = Units.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.exercise.name, style: AppTextStyles.h4),
          if (widget.exercise.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.exercise.description,
              style: AppTextStyles.body2
                  .copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _setsController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.sets,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.weightWithUnit(units.weightLabel),
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final sets =
                  (int.tryParse(_setsController.text) ?? 3).clamp(1, 20);
              final weight =
                  (units.parseWeight(_weightController.text) ?? 0.0)
                      .clamp(0.0, 9999.0);
              Navigator.of(context).pop((sets, weight));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.startExercise),
          ),
        ],
      ),
    );
  }
}
