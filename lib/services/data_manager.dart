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

    _prefs = await SharedPreferences.getInstance();
    await _loadData();
    _isInitialized = true;
  }

  Future<void> _loadData() async {
    final exercisesJson = _prefs?.getStringList('exercises') ?? [];
    if (exercisesJson.isEmpty) {
      _loadDefaultExercises();
    } else {
      _exercises = exercisesJson
          .map((json) => Exercise.fromJson(jsonDecode(json)))
          .toList();
    }

    final workoutsJson = _prefs?.getStringList('workouts') ?? [];
    if (workoutsJson.isEmpty) {
      _initializeDemoWorkout();
    } else {
      _workouts = workoutsJson
          .map((json) => Workout.fromJson(jsonDecode(json)))
          .toList();
    }

    final historyJson = _prefs?.getStringList('workout_history') ?? [];
    _workoutHistory = historyJson
        .map((json) => WorkoutHistory.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveData() async {
    final exercisesJson =
        _exercises.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs?.setStringList('exercises', exercisesJson);

    final workoutsJson = _workouts.map((w) => jsonEncode(w.toJson())).toList();
    await _prefs?.setStringList('workouts', workoutsJson);

    final historyJson =
        _workoutHistory.map((h) => jsonEncode(h.toJson())).toList();
    await _prefs?.setStringList('workout_history', historyJson);
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
      Exercise(
        id: '9',
        name: 'Wrist Curls',
        description: 'Forearm flexor strengthening for cupping power',
        difficulty: ExerciseDifficulty.easy,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.forearms,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.wrists,
            intensity: MuscleGroupIntensity.primary,
          ),
        ],
      ),
      Exercise(
        id: '10',
        name: 'Reverse Wrist Curls',
        description: 'Forearm extensor training for rising movement',
        difficulty: ExerciseDifficulty.easy,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.forearms,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.wrists,
            intensity: MuscleGroupIntensity.primary,
          ),
        ],
      ),
      Exercise(
        id: '11',
        name: 'Hammer Curls',
        description: 'Brachioradialis and grip strength for toproll',
        difficulty: ExerciseDifficulty.medium,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.biceps,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.forearms,
            intensity: MuscleGroupIntensity.primary,
          ),
        ],
      ),
      Exercise(
        id: '12',
        name: 'Pronation/Supination Training',
        description:
            'Rotational forearm strength with dumbbell or resistance band',
        difficulty: ExerciseDifficulty.medium,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.forearms,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.wrists,
            intensity: MuscleGroupIntensity.primary,
          ),
        ],
      ),
      Exercise(
        id: '13',
        name: 'Heavy Grip Training',
        description: 'Grip crushers or fat grip holds for hand strength',
        difficulty: ExerciseDifficulty.hard,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.forearms,
            intensity: MuscleGroupIntensity.primary,
          ),
        ],
      ),
      Exercise(
        id: '14',
        name: 'Cable Side Pressure',
        description: 'Lateral pulling motion for side pressure technique',
        difficulty: ExerciseDifficulty.hard,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.chest,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.shoulders,
            intensity: MuscleGroupIntensity.secondary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.forearms,
            intensity: MuscleGroupIntensity.secondary,
          ),
        ],
      ),
      Exercise(
        id: '15',
        name: 'Back Pressure Rows',
        description: 'Lat focused rowing for back pressure movement',
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
        ],
      ),
      Exercise(
        id: '16',
        name: 'Weighted Pull-ups',
        description: 'Pull-ups with additional weight for max strength',
        difficulty: ExerciseDifficulty.hard,
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
        ],
      ),
      Exercise(
        id: '17',
        name: 'Weighted Dips',
        description: 'Dips with added weight for maximum strength',
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
      Exercise(
        id: '18',
        name: 'Muscle-ups',
        description: 'Dynamic transition from pull-up to dip',
        difficulty: ExerciseDifficulty.hard,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.back,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.chest,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.triceps,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.core,
            intensity: MuscleGroupIntensity.secondary,
          ),
        ],
      ),
      Exercise(
        id: '19',
        name: 'Front Lever Progression',
        description: 'Isometric hold with body horizontal, facing down',
        difficulty: ExerciseDifficulty.hard,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.back,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.core,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.shoulders,
            intensity: MuscleGroupIntensity.secondary,
          ),
        ],
      ),
      Exercise(
        id: '20',
        name: 'Back Lever Progression',
        description: 'Isometric hold with body horizontal, facing up',
        difficulty: ExerciseDifficulty.hard,
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
            group: MuscleGroup.core,
            intensity: MuscleGroupIntensity.secondary,
          ),
        ],
      ),
      Exercise(
        id: '21',
        name: 'Planche Progression',
        description: 'Horizontal bodyweight hold supported by straight arms',
        difficulty: ExerciseDifficulty.hard,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.shoulders,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.chest,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.core,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.triceps,
            intensity: MuscleGroupIntensity.secondary,
          ),
        ],
      ),
      Exercise(
        id: '22',
        name: 'Human Flag Progression',
        description: 'Lateral hold perpendicular to vertical pole',
        difficulty: ExerciseDifficulty.hard,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.core,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.back,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.shoulders,
            intensity: MuscleGroupIntensity.primary,
          ),
        ],
      ),
      Exercise(
        id: '23',
        name: 'Pistol Squats',
        description: 'Single leg squat for leg strength and balance',
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
        id: '24',
        name: 'Romanian Deadlift',
        description: 'Hip hinge movement for hamstrings and glutes',
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
            group: MuscleGroup.back,
            intensity: MuscleGroupIntensity.secondary,
          ),
        ],
      ),
      Exercise(
        id: '25',
        name: 'Front Squat',
        description: 'Squat variation with bar in front rack position',
        difficulty: ExerciseDifficulty.hard,
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
        id: '26',
        name: 'Close-Grip Bench Press',
        description: 'Bench press variation for triceps strength',
        difficulty: ExerciseDifficulty.medium,
        createdAt: DateTime.now(),
        muscleGroups: [
          MuscleGroupTag(
            group: MuscleGroup.triceps,
            intensity: MuscleGroupIntensity.primary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.chest,
            intensity: MuscleGroupIntensity.secondary,
          ),
          MuscleGroupTag(
            group: MuscleGroup.shoulders,
            intensity: MuscleGroupIntensity.secondary,
          ),
        ],
      ),
      Exercise(
        id: '27',
        name: 'Paused Squats',
        description: 'Squat with 2-3 second pause at bottom for strength',
        difficulty: ExerciseDifficulty.hard,
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
    ];
  }

  void _initializeDemoWorkout() {
    _workouts.addAll([
      Workout(
        id: 'armwrestling_basic_1',
        name: 'Armwrestling Basic - Day 1',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[10], sets: 4, targetReps: 12, weight: 15.0),
          WorkoutExercise(
              exercise: _exercises[8], sets: 4, targetReps: 15, weight: 10.0),
          WorkoutExercise(
              exercise: _exercises[9], sets: 4, targetReps: 15, weight: 8.0),
          WorkoutExercise(
              exercise: _exercises[0], sets: 3, targetReps: 8, weight: 0.0),
        ],
        createdAt: DateTime.now(),
      ),
      Workout(
        id: 'armwrestling_basic_2',
        name: 'Armwrestling Basic - Day 2',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[11], sets: 3, targetReps: 12, weight: 8.0),
          WorkoutExercise(
              exercise: _exercises[14], sets: 4, targetReps: 10, weight: 20.0),
          WorkoutExercise(
              exercise: _exercises[12], sets: 3, targetReps: 20, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[6], sets: 3, targetReps: 10, weight: 30.0),
        ],
        createdAt: DateTime.now(),
      ),

      Workout(
        id: 'armwrestling_grip_1',
        name: 'Armwrestling Grip Focus - Day 1',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[12], sets: 5, targetReps: 30, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[8], sets: 5, targetReps: 20, weight: 12.0),
          WorkoutExercise(
              exercise: _exercises[9], sets: 5, targetReps: 20, weight: 10.0),
          WorkoutExercise(
              exercise: _exercises[11], sets: 4, targetReps: 15, weight: 10.0),
        ],
        createdAt: DateTime.now(),
      ),
      Workout(
        id: 'armwrestling_grip_2',
        name: 'Armwrestling Grip Focus - Day 2',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[10], sets: 4, targetReps: 10, weight: 20.0),
          WorkoutExercise(
              exercise: _exercises[0], sets: 4, targetReps: 10, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[13], sets: 3, targetReps: 8, weight: 25.0),
          WorkoutExercise(
              exercise: _exercises[14], sets: 4, targetReps: 12, weight: 25.0),
        ],
        createdAt: DateTime.now(),
      ),

      Workout(
        id: 'armwrestling_comp_1',
        name: 'Armwrestling Competition - Day 1',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[10], sets: 5, targetReps: 6, weight: 25.0),
          WorkoutExercise(
              exercise: _exercises[13], sets: 4, targetReps: 5, weight: 30.0),
          WorkoutExercise(
              exercise: _exercises[12], sets: 3, targetReps: 15, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[11], sets: 3, targetReps: 10, weight: 12.0),
        ],
        createdAt: DateTime.now(),
      ),

      Workout(
        id: 'streetlifting_beginner_1',
        name: 'Streetlifting Beginner - Day 1',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[0], sets: 5, targetReps: 5, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[1], sets: 5, targetReps: 10, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[2], sets: 4, targetReps: 12, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[7], sets: 3, targetReps: 8, weight: 0.0),
        ],
        createdAt: DateTime.now(),
      ),
      Workout(
        id: 'streetlifting_beginner_2',
        name: 'Streetlifting Beginner - Day 2',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[17], sets: 3, targetReps: 3, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[22], sets: 4, targetReps: 10, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[0], sets: 3, targetReps: 10, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[7], sets: 4, targetReps: 12, weight: 0.0),
        ],
        createdAt: DateTime.now(),
      ),

      Workout(
        id: 'streetlifting_advanced_1',
        name: 'Streetlifting Advanced - Day 1',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[15], sets: 5, targetReps: 3, weight: 20.0),
          WorkoutExercise(
              exercise: _exercises[16], sets: 5, targetReps: 3, weight: 20.0),
          WorkoutExercise(
              exercise: _exercises[17], sets: 4, targetReps: 5, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[18], sets: 3, targetReps: 10, weight: 0.0),
        ],
        createdAt: DateTime.now(),
      ),
      Workout(
        id: 'streetlifting_advanced_2',
        name: 'Streetlifting Advanced - Day 2',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[19], sets: 3, targetReps: 15, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[20], sets: 3, targetReps: 20, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[21], sets: 3, targetReps: 10, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[22], sets: 3, targetReps: 10, weight: 20.0),
        ],
        createdAt: DateTime.now(),
      ),

      Workout(
        id: 'streetlifting_exit_1',
        name: 'Streetlifting Strength Exit - Day 1',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[15], sets: 6, targetReps: 1, weight: 40.0),
          WorkoutExercise(
              exercise: _exercises[0], sets: 3, targetReps: 15, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[18], sets: 4, targetReps: 12, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[6], sets: 4, targetReps: 8, weight: 40.0),
        ],
        createdAt: DateTime.now(),
      ),
      Workout(
        id: 'streetlifting_exit_2',
        name: 'Streetlifting Strength Exit - Day 2',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[16], sets: 6, targetReps: 1, weight: 40.0),
          WorkoutExercise(
              exercise: _exercises[7], sets: 3, targetReps: 15, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[17], sets: 3, targetReps: 5, weight: 0.0),
          WorkoutExercise(
              exercise: _exercises[3], sets: 4, targetReps: 8, weight: 50.0),
        ],
        createdAt: DateTime.now(),
      ),

      Workout(
        id: 'powerlifting_5x5_a',
        name: 'Powerlifting 5x5 - Day A',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[2], sets: 5, targetReps: 5, weight: 60.0),
          WorkoutExercise(
              exercise: _exercises[3], sets: 5, targetReps: 5, weight: 50.0),
          WorkoutExercise(
              exercise: _exercises[6], sets: 5, targetReps: 5, weight: 40.0),
        ],
        createdAt: DateTime.now(),
      ),
      Workout(
        id: 'powerlifting_5x5_b',
        name: 'Powerlifting 5x5 - Day B',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[2], sets: 5, targetReps: 5, weight: 60.0),
          WorkoutExercise(
              exercise: _exercises[5], sets: 5, targetReps: 5, weight: 35.0),
          WorkoutExercise(
              exercise: _exercises[4], sets: 5, targetReps: 5, weight: 80.0),
        ],
        createdAt: DateTime.now(),
      ),

      Workout(
        id: 'powerlifting_inter_1',
        name: 'Powerlifting Intermediate - Day 1',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[2],
              sets: 5,
              targetReps: 3,
              weight: 80.0), // Squats
          WorkoutExercise(
              exercise: _exercises[24],
              sets: 4,
              targetReps: 8,
              weight: 60.0), // Front Squat
          WorkoutExercise(
              exercise: _exercises[23],
              sets: 3,
              targetReps: 12,
              weight: 40.0), // Romanian Deadlift
        ],
        createdAt: DateTime.now(),
      ),
      Workout(
        id: 'powerlifting_inter_2',
        name: 'Powerlifting Intermediate - Day 2',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[3],
              sets: 5,
              targetReps: 3,
              weight: 70.0), // Bench Press
          WorkoutExercise(
              exercise: _exercises[25],
              sets: 4,
              targetReps: 8,
              weight: 50.0), // Close-Grip Bench
          WorkoutExercise(
              exercise: _exercises[5],
              sets: 4,
              targetReps: 6,
              weight: 40.0), // Overhead Press
        ],
        createdAt: DateTime.now(),
      ),
      Workout(
        id: 'powerlifting_inter_3',
        name: 'Powerlifting Intermediate - Day 3',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[4],
              sets: 5,
              targetReps: 2,
              weight: 100.0), // Deadlift
          WorkoutExercise(
              exercise: _exercises[23],
              sets: 4,
              targetReps: 8,
              weight: 70.0), // Romanian Deadlift
          WorkoutExercise(
              exercise: _exercises[6],
              sets: 4,
              targetReps: 10,
              weight: 50.0), // Barbell Row
        ],
        createdAt: DateTime.now(),
      ),

      // Powerlifting: Pre-Competition Peaking
      Workout(
        id: 'powerlifting_peak_1',
        name: 'Powerlifting Competition Prep - Week 1',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[26],
              sets: 5,
              targetReps: 3,
              weight: 85.0), // Paused Squats
          WorkoutExercise(
              exercise: _exercises[3],
              sets: 5,
              targetReps: 2,
              weight: 80.0), // Bench Press
          WorkoutExercise(
              exercise: _exercises[25],
              sets: 3,
              targetReps: 5,
              weight: 55.0), // Close-Grip Bench
        ],
        createdAt: DateTime.now(),
      ),
      Workout(
        id: 'powerlifting_peak_2',
        name: 'Powerlifting Competition Prep - Week 2',
        exercises: [
          WorkoutExercise(
              exercise: _exercises[4], sets: 3, targetReps: 1, weight: 110.0),
          WorkoutExercise(
              exercise: _exercises[2], sets: 3, targetReps: 2, weight: 90.0),
          WorkoutExercise(
              exercise: _exercises[6], sets: 3, targetReps: 8, weight: 55.0),
        ],
        createdAt: DateTime.now(),
      ),
    ]);
  }

  void addExercise(Exercise exercise) {
    _exercises.add(exercise);
    _saveData();
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
    _workouts.add(workout);

    notifyListeners();
  }

  void updateWorkout(int index, Workout workout) {
    if (index >= 0 && index < _workouts.length) {
      _saveData();
      notifyListeners();
    }
  }

  void removeWorkout(int index) {
    if (index >= 0 && index < _workouts.length) {
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
    _workoutHistory.add(history);
    _saveData();

    notifyListeners();
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
