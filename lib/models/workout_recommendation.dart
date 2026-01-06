import 'workout.dart';

enum RecommendationLevel {
  rest,
  light,
  moderate,
  intense,
}

class ExerciseRecommendation {
  final WorkoutExercise exercise;
  final String reason;
  final double confidenceScore;

  ExerciseRecommendation({
    required this.exercise,
    required this.reason,
    required this.confidenceScore,
  });
}

class WorkoutRecommendation {
  final String workoutId;
  final String workoutName;
  final List<ExerciseRecommendation> exercises;
  final RecommendationLevel level;
  final String overallReason;
  final DateTime generatedAt;
  final double overallConfidence;
  final Map<String, dynamic> factors;

  WorkoutRecommendation({
    required this.workoutId,
    required this.workoutName,
    required this.exercises,
    required this.level,
    required this.overallReason,
    required this.generatedAt,
    required this.overallConfidence,
    required this.factors,
  });

  Map<String, dynamic> toJson() {
    return {
      'workoutId': workoutId,
      'workoutName': workoutName,
      'exercises': exercises
          .map((e) => {
                'exercise': e.exercise.toJson(),
                'reason': e.reason,
                'confidenceScore': e.confidenceScore,
              })
          .toList(),
      'level': level.name,
      'overallReason': overallReason,
      'generatedAt': generatedAt.toIso8601String(),
      'overallConfidence': overallConfidence,
      'factors': factors,
    };
  }

  factory WorkoutRecommendation.fromJson(Map<String, dynamic> json) {
    return WorkoutRecommendation(
      workoutId: json['workoutId'],
      workoutName: json['workoutName'],
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseRecommendation(
                exercise: WorkoutExercise.fromJson(e['exercise']),
                reason: e['reason'],
                confidenceScore: (e['confidenceScore'] as num).toDouble(),
              ))
          .toList(),
      level: RecommendationLevel.values.firstWhere(
        (l) => l.name == json['level'],
        orElse: () => RecommendationLevel.moderate,
      ),
      overallReason: json['overallReason'],
      generatedAt: DateTime.parse(json['generatedAt']),
      overallConfidence: (json['overallConfidence'] as num).toDouble(),
      factors: Map<String, dynamic>.from(json['factors']),
    );
  }
}
