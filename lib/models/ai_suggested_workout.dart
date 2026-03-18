import 'workout.dart';

class AiSuggestedWorkout {
  final String id;
  final Workout workout;
  final String reasoning;
  final DateTime generatedAt;

  AiSuggestedWorkout({
    required this.id,
    required this.workout,
    required this.reasoning,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workout': workout.toJson(),
        'reasoning': reasoning,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory AiSuggestedWorkout.fromJson(Map<String, dynamic> json) =>
      AiSuggestedWorkout(
        id: json['id'],
        workout: Workout.fromJson(json['workout']),
        reasoning: json['reasoning'],
        generatedAt: DateTime.parse(json['generatedAt']),
      );
}
