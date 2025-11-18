import 'exercise.dart';

class ExerciseSetResult {
  final int setNumber;
  final int actualReps;
  final double weight;
  final DateTime timestamp;
  final int durationSeconds;

  ExerciseSetResult({
    required this.setNumber,
    required this.actualReps,
    required this.weight,
    required this.timestamp,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'actualReps': actualReps,
      'weight': weight,
      'timestamp': timestamp.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  factory ExerciseSetResult.fromJson(Map<String, dynamic> json) {
    return ExerciseSetResult(
      setNumber: json['setNumber'],
      actualReps: json['actualReps'],
      weight: (json['weight'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      durationSeconds: json['durationSeconds'],
    );
  }
}

class ExerciseResult {
  final Exercise exercise;
  final int targetSets;
  final int targetReps;
  final double targetWeight;
  final List<ExerciseSetResult> setResults;
  final ExerciseDifficulty? perceivedDifficulty;

  ExerciseResult({
    required this.exercise,
    required this.targetSets,
    required this.targetReps,
    required this.targetWeight,
    required this.setResults,
    this.perceivedDifficulty,
  });

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'targetSets': targetSets,
      'targetReps': targetReps,
      'targetWeight': targetWeight,
      'setResults': setResults.map((e) => e.toJson()).toList(),
      'perceivedDifficulty': perceivedDifficulty?.name,
    };
  }

  factory ExerciseResult.fromJson(Map<String, dynamic> json) {
    return ExerciseResult(
      exercise: Exercise.fromJson(json['exercise']),
      targetSets: json['targetSets'],
      targetReps: json['targetReps'],
      targetWeight: (json['targetWeight'] as num).toDouble(),
      setResults: (json['setResults'] as List)
          .map((e) => ExerciseSetResult.fromJson(e))
          .toList(),
      perceivedDifficulty: json['perceivedDifficulty'] != null
          ? ExerciseDifficulty.values.firstWhere(
              (e) => e.name == json['perceivedDifficulty'],
              orElse: () => ExerciseDifficulty.medium,
            )
          : null,
    );
  }

  ExerciseResult copyWith({
    Exercise? exercise,
    int? targetSets,
    int? targetReps,
    double? targetWeight,
    List<ExerciseSetResult>? setResults,
    ExerciseDifficulty? perceivedDifficulty,
  }) {
    return ExerciseResult(
      exercise: exercise ?? this.exercise,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      setResults: setResults ?? this.setResults,
      perceivedDifficulty: perceivedDifficulty ?? this.perceivedDifficulty,
    );
  }
}

enum WorkoutSessionStatus {
  notStarted,
  inProgress,
  completed,
}

class WorkoutSession {
  final String id;
  final String workoutId;
  final String workoutName;
  final DateTime startTime;
  final DateTime? endTime;
  final List<ExerciseResult> exerciseResults;
  final WorkoutSessionStatus status;
  final int totalDurationSeconds;
  final String? userId;

  WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.startTime,
    this.endTime,
    required this.exerciseResults,
    required this.status,
    required this.totalDurationSeconds,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'workoutName': workoutName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'exerciseResults': exerciseResults.map((e) => e.toJson()).toList(),
      'status': status.name,
      'totalDurationSeconds': totalDurationSeconds,
      'userId': userId,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      workoutId: json['workoutId'],
      workoutName: json['workoutName'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      exerciseResults: (json['exerciseResults'] as List)
          .map((e) => ExerciseResult.fromJson(e))
          .toList(),
      status: WorkoutSessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WorkoutSessionStatus.notStarted,
      ),
      totalDurationSeconds: json['totalDurationSeconds'],
      userId: json['userId'],
    );
  }

  WorkoutSession copyWith({
    String? id,
    String? workoutId,
    String? workoutName,
    DateTime? startTime,
    DateTime? endTime,
    List<ExerciseResult>? exerciseResults,
    WorkoutSessionStatus? status,
    int? totalDurationSeconds,
    String? userId,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exerciseResults: exerciseResults ?? this.exerciseResults,
      status: status ?? this.status,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      userId: userId ?? this.userId,
    );
  }
}
