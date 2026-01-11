import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_history.dart';

class DataManager extends ChangeNotifier {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;

  DataManager._internal();

  SharedPreferences? _prefs;
  List<Exercise> _exercises = [];
  List<Workout> _workouts = [];
  List<WorkoutHistory> _workoutHistory = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    print('[DATA_MANAGER] Initializing...');
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
    _isInitialized = true;
    print('[DATA_MANAGER] Initialization complete');
  }

  Future<void> _loadData() async {
    print('[DATA_MANAGER] Loading data from storage...');

    final exercisesJson = _prefs?.getStringList('exercises') ?? [];
    if (exercisesJson.isEmpty) {
      print('[DATA_MANAGER] No saved exercises, loading defaults...');
      _loadDefaultExercises();
    } else {
      _exercises = exercisesJson
          .map((json) => Exercise.fromJson(jsonDecode(json)))
          .toList();
      print(
          '[DATA_MANAGER] Loaded ${_exercises.length} exercises: ${_exercises.map((e) => e.name).toList()}');
    }

    final workoutsJson = _prefs?.getStringList('workouts') ?? [];
    if (workoutsJson.isEmpty) {
      print('[DATA_MANAGER] No saved workouts, creating demo...');
      _initializeDemoWorkout();
    } else {
      _workouts = workoutsJson
          .map((json) => Workout.fromJson(jsonDecode(json)))
          .toList();
      print(
          '[DATA_MANAGER] Loaded ${_workouts.length} workouts: ${_workouts.map((w) => w.name).toList()}');
    }

    final historyJson = _prefs?.getStringList('workout_history') ?? [];
    _workoutHistory = historyJson
        .map((json) => WorkoutHistory.fromJson(jsonDecode(json)))
        .toList();
    print('[DATA_MANAGER] Loaded ${_workoutHistory.length} history entries');
  }

  Future<void> _saveData() async {
    print('[DATA_MANAGER] Saving data to storage...');
    print(
        '[DATA_MANAGER] Exercises to save: ${_exercises.map((e) => e.name).toList()}');
    print(
        '[DATA_MANAGER] Workouts to save: ${_workouts.map((w) => w.name).toList()}');

    final exercisesJson =
        _exercises.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs?.setStringList('exercises', exercisesJson);

    final workoutsJson = _workouts.map((w) => jsonEncode(w.toJson())).toList();
    await _prefs?.setStringList('workouts', workoutsJson);

    final historyJson =
        _workoutHistory.map((h) => jsonEncode(h.toJson())).toList();
    await _prefs?.setStringList('workout_history', historyJson);

    print('[DATA_MANAGER] Data saved successfully');
  }

  List<Exercise> get exercises => List.unmodifiable(_exercises);
  List<Workout> get workouts => List.unmodifiable(_workouts);
  List<WorkoutHistory> get workoutHistory => List.unmodifiable(_workoutHistory);

  void _loadDefaultExercises() {
    _exercises = [
      Exercise(
        id: '1',
        name: 'Pull-ups',
        description: 'Upper body exercise focusing on back and biceps',
        difficulty: ExerciseDifficulty.medium,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.back,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.biceps,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.forearms,
            intensity: MuscleGroupIntensity.secondary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.core,
            intensity: MuscleGroupIntensity.stabilizer,
          ),
        ],
      ),
      Exercise(
        id: '2',
        name: 'Push-ups',
        description: 'Bodyweight exercise for chest, shoulders and triceps',
        difficulty: ExerciseDifficulty.easy,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.chest,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.triceps,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.shoulders,
            intensity: MuscleGroupIntensity.secondary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.core,
            intensity: MuscleGroupIntensity.stabilizer,
          ),
        ],
      ),
      Exercise(
        id: '3',
        name: 'Squats',
        description: 'Lower body compound exercise',
        difficulty: ExerciseDifficulty.medium,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.legs,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.glutes,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.core,
            intensity: MuscleGroupIntensity.secondary,
          ),
        ],
      ),
      Exercise(
        id: '4',
        name: 'Bench Press',
        description: 'Chest and triceps compound exercise',
        difficulty: ExerciseDifficulty.hard,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.chest,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.triceps,
            intensity: MuscleGroupIntensity.secondary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.shoulders,
            intensity: MuscleGroupIntensity.secondary,
          ),
        ],
      ),
      Exercise(
        id: '5',
        name: 'Deadlift',
        description: 'Full body compound exercise',
        difficulty: ExerciseDifficulty.hard,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.back,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.legs,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.glutes,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.forearms,
            intensity: MuscleGroupIntensity.secondary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.core,
            intensity: MuscleGroupIntensity.stabilizer,
          ),
        ],
      ),
      Exercise(
        id: '6',
        name: 'Overhead Press',
        description: 'Shoulder compound exercise',
        difficulty: ExerciseDifficulty.medium,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.shoulders,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.triceps,
            intensity: MuscleGroupIntensity.secondary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.core,
            intensity: MuscleGroupIntensity.stabilizer,
          ),
        ],
      ),
      Exercise(
        id: '7',
        name: 'Barbell Row',
        description: 'Back compound exercise',
        difficulty: ExerciseDifficulty.medium,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.back,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.biceps,
            intensity: MuscleGroupIntensity.secondary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.forearms,
            intensity: MuscleGroupIntensity.secondary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.core,
            intensity: MuscleGroupIntensity.stabilizer,
          ),
        ],
      ),
      Exercise(
        id: '8',
        name: 'Dips',
        description: 'Chest and triceps bodyweight exercise',
        difficulty: ExerciseDifficulty.hard,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.chest,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.triceps,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.shoulders,
            intensity: MuscleGroupIntensity.secondary,
          ),
        ],
      ),
    ];
  }

  void _initializeDemoWorkout() {
    final demoWorkout = Workout(
      id: 'demo_1',
      name: 'Beginner Strength Program',
      exercises: [
        WorkoutExercise(
          exercise: _exercises[2],
          sets: 3,
          targetReps: 10,
          weight: 20.0,
        ),
        WorkoutExercise(
          exercise: _exercises[1],
          sets: 3,
          targetReps: 12,
          weight: 0.0,
        ),
        WorkoutExercise(
          exercise: _exercises[0],
          sets: 3,
          targetReps: 8,
          weight: 0.0,
        ),
      ],
      createdAt: DateTime.now(),
    );
    _workouts.add(demoWorkout);
  }

  void addExercise(Exercise exercise) {
    _exercises.add(exercise);
    _saveData();
    print('[DATA_MANAGER] Exercise added: ${exercise.name}');
  }

  void removeExercise(String id) {
    _exercises.removeWhere((exercise) => exercise.id == id);
    _saveData();
  }

  Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  void addWorkout(Workout workout) {
    print('[DATA_MANAGER] Adding workout: ${workout.name} (ID: ${workout.id})');
    print('[DATA_MANAGER] Workout has ${workout.exercises.length} exercises');
    _workouts.add(workout);
    print(
        '[DATA_MANAGER] Workouts after add: ${_workouts.map((w) => w.name).toList()}');
    _saveData();
    print('[DATA_MANAGER] Total workouts now: ${_workouts.length}');
    notifyListeners();
  }

  void updateWorkout(int index, Workout workout) {
    if (index >= 0 && index < _workouts.length) {
      print('[DATA_MANAGER] Updating workout at index $index: ${workout.name}');
      _workouts[index] = workout;
      print(
          '[DATA_MANAGER] Workouts after update: ${_workouts.map((w) => w.name).toList()}');
      _saveData();
      notifyListeners();
    }
  }

  void removeWorkout(int index) {
    if (index >= 0 && index < _workouts.length) {
      print(
          '[DATA_MANAGER] Removing workout at index $index: ${_workouts[index].name}');
      _workouts.removeAt(index);
      print(
          '[DATA_MANAGER] Workouts after remove: ${_workouts.map((w) => w.name).toList()}');
      _saveData();
      notifyListeners();
    }
  }

  Workout? getWorkoutById(String id) {
    try {
      return _workouts.firstWhere((workout) => workout.id == id);
    } catch (e) {
      return null;
    }
  }

  Workout? getTodayWorkout() {
    if (_workouts.isNotEmpty) {
      return _workouts[0];
    }
    return null;
  }

  void addWorkoutHistory(WorkoutHistory history) {
    print('[DATA_MANAGER] Adding workout history for ${history.date}');
    _workoutHistory.add(history);
    _saveData();
    print('[DATA_MANAGER] Notifying listeners about new workout...');
    notifyListeners();
    print(
        '[DATA_MANAGER] Listeners notified. Total workout history: ${_workoutHistory.length}');
  }

  List<WorkoutHistory> getWorkoutHistoryForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _workoutHistory.where((h) => h.dateOnly == dateOnly).toList();
  }

  Map<DateTime, List<WorkoutHistory>> getWorkoutHistoryMap() {
    final Map<DateTime, List<WorkoutHistory>> map = {};
    for (var history in _workoutHistory) {
      final dateKey = history.dateOnly;
      if (!map.containsKey(dateKey)) {
        map[dateKey] = [];
      }
      map[dateKey]!.add(history);
    }
    return map;
  }

  bool hasWorkoutOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _workoutHistory.any((h) => h.dateOnly == dateOnly);
  }

  int workoutsThisMonth([DateTime? forDate]) {
    final now = forDate ?? DateTime.now();
    return _workoutHistory
        .where((h) => h.date.year == now.year && h.date.month == now.month)
        .length;
  }

  int currentStreak() {
    if (_workoutHistory.isEmpty) return 0;
    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      final dayOnly = DateTime(day.year, day.month, day.day);
      final has = _workoutHistory.any((h) => h.dateOnly == dayOnly);
      if (has) {
        streak += 1;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int totalWorkouts() => _workoutHistory.length;

  int totalDaysTrained() {
    final days = _workoutHistory.map((h) => h.dateOnly).toSet();
    return days.length;
  }

  int longestStreak() {
    if (_workoutHistory.isEmpty) return 0;
    final dates = _workoutHistory.map((h) => h.dateOnly).toSet().toList()
      ..sort();
    int longest = 0;
    int current = 1;
    for (var i = 1; i < dates.length; i++) {
      final prev = dates[i - 1];
      final cur = dates[i];
      if (cur.difference(prev).inDays == 1) {
        current += 1;
      } else {
        if (current > longest) longest = current;
        current = 1;
      }
    }
    if (current > longest) longest = current;
    return longest;
  }
}
