import '../models/exercise.dart';
import '../models/workout.dart';

class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  final List<Exercise> _exercises = [
    Exercise(
      id: '1',
      name: 'Pull-ups',
      description: 'Upper body exercise focusing on back and biceps',
      difficulty: ExerciseDifficulty.medium,
      createdAt: DateTime.now(),
    ),
    Exercise(
      id: '2',
      name: 'Push-ups',
      description: 'Bodyweight exercise for chest, shoulders and triceps',
      difficulty: ExerciseDifficulty.easy,
      createdAt: DateTime.now(),
    ),
    Exercise(
      id: '3',
      name: 'Squats',
      description: 'Lower body compound exercise',
      difficulty: ExerciseDifficulty.medium,
      createdAt: DateTime.now(),
    ),
    Exercise(
      id: '4',
      name: 'Bench Press',
      description: 'Chest and triceps compound exercise',
      difficulty: ExerciseDifficulty.hard,
      createdAt: DateTime.now(),
    ),
    Exercise(
      id: '5',
      name: 'Deadlift',
      description: 'Full body compound exercise',
      difficulty: ExerciseDifficulty.hard,
      createdAt: DateTime.now(),
    ),
    Exercise(
      id: '6',
      name: 'Overhead Press',
      description: 'Shoulder compound exercise',
      difficulty: ExerciseDifficulty.medium,
      createdAt: DateTime.now(),
    ),
    Exercise(
      id: '7',
      name: 'Barbell Row',
      description: 'Back compound exercise',
      difficulty: ExerciseDifficulty.medium,
      createdAt: DateTime.now(),
    ),
    Exercise(
      id: '8',
      name: 'Dips',
      description: 'Chest and triceps bodyweight exercise',
      difficulty: ExerciseDifficulty.hard,
      createdAt: DateTime.now(),
    ),
  ];

  final List<Workout> _workouts = [];

  List<Exercise> get exercises => List.unmodifiable(_exercises);
  List<Workout> get workouts => List.unmodifiable(_workouts);

  void addExercise(Exercise exercise) {
    _exercises.add(exercise);
  }

  void removeExercise(String id) {
    _exercises.removeWhere((exercise) => exercise.id == id);
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
  }

  void updateWorkout(int index, Workout workout) {
    if (index >= 0 && index < _workouts.length) {
      _workouts[index] = workout;
    }
  }

  void removeWorkout(int index) {
    if (index >= 0 && index < _workouts.length) {
      _workouts.removeAt(index);
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
}
