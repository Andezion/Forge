import 'exercise.dart';

class WorkoutExercise {
  final Exercise exercise;
  final int sets;
  final int targetReps;
  final double weight;

  WorkoutExercise({
    required this.exercise,
    required this.sets,
    required this.targetReps,
    required this.weight,
  });

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets,
      'targetReps': targetReps,
      'weight': weight,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exercise: Exercise.fromJson(json['exercise']),
      sets: json['sets'],
      targetReps: json['targetReps'],
      weight: (json['weight'] as num).toDouble(),
    );
  }

  WorkoutExercise copyWith({
    Exercise? exercise,
    int? sets,
    int? targetReps,
    double? weight,
  }) {
    return WorkoutExercise(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      targetReps: targetReps ?? this.targetReps,
      weight: weight ?? this.weight,
    );
  }
}

class Workout {
  final String id;
  final String name;
  final List<WorkoutExercise> exercises;
  final DateTime createdAt;
  final String? userId;

  Workout({
    required this.id,
    required this.name,
    required this.exercises,
    required this.createdAt,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      exercises: (json['exercises'] as List)
          .map((e) => WorkoutExercise.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
    );
  }

  Workout copyWith({
    String? id,
    String? name,
    List<WorkoutExercise>? exercises,
    DateTime? createdAt,
    String? userId,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
