import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_history.dart';
import '../models/ai_suggested_workout.dart';

const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
const String _model = 'llama-3.3-70b-versatile';

class GroqService {
  /// Generates an AI workout program based on user history and available exercises.
  /// Returns null on failure.
  Future<AiSuggestedWorkout?> generateProgram({
    required List<WorkoutHistory> history,
    required List<Exercise> exercises,
  }) async {
    try {
      final prompt = _buildPrompt(history, exercises);

      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['key'] ?? ''}',
        },
        body: jsonEncode({
          'model': _model,
          'temperature': 0.7,
          'max_tokens': 1500,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an expert fitness coach. You analyze workout history and create personalized training programs. Always respond with valid JSON only, no extra text.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('[GROQ] Error ${response.statusCode}: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;

      return _parseResponse(content, exercises);
    } catch (e) {
      debugPrint('[GROQ] Exception: $e');
      return null;
    }
  }

  String _buildPrompt(List<WorkoutHistory> history, List<Exercise> exercises) {
    // Last 10 sessions summary
    final recentHistory = history.reversed.take(10).toList();
    final historySummary = recentHistory.map((h) {
      final date = '${h.date.day}.${h.date.month}.${h.date.year}';
      final exercisesSummary = h.session.exerciseResults.map((er) {
        final sets = er.setResults;
        if (sets.isEmpty) {
          return '${er.exercise.name}: ${er.targetSets}x${er.targetReps} @ ${er.targetWeight}kg (target)';
        }
        final avgReps = sets.isEmpty
            ? er.targetReps
            : (sets.map((s) => s.actualReps).reduce((a, b) => a + b) /
                    sets.length)
                .round();
        final avgWeight = sets.isEmpty
            ? er.targetWeight
            : sets.map((s) => s.weight).reduce((a, b) => a + b) / sets.length;
        return '${er.exercise.name}: ${sets.length}x$avgReps @ ${avgWeight.toStringAsFixed(1)}kg';
      }).join(', ');
      return '[$date] ${h.session.workoutName}: $exercisesSummary';
    }).join('\n');

    // Available exercises
    final exerciseList = exercises.map((e) {
      final muscles = e.muscleGroups
          .map((mg) => '${mg.group.name}(${mg.intensity.name})')
          .join(', ');
      return '{"id":"${e.id}","name":"${e.name}","muscles":"$muscles","difficulty":"${e.difficulty.name}"}';
    }).join(',\n');

    return '''
Analyze this athlete's recent workout history and create a personalized workout program using ONLY exercises from their library.

WORKOUT HISTORY (last ${recentHistory.length} sessions):
$historySummary

AVAILABLE EXERCISES:
[$exerciseList]

Based on the history, identify:
- Which muscle groups are most trained
- Current weight/rep progression trends
- What would be a good next program step

Return ONLY a JSON object (no markdown, no extra text) with this exact structure:
{
  "name": "Program name (short, max 40 chars)",
  "exercises": [
    {
      "exerciseId": "id from the library above",
      "sets": 3,
      "targetReps": 8,
      "weight": 60.0
    }
  ],
  "reasoning": "2-3 sentences explaining why this program suits the athlete based on their history"
}

Rules:
- Include 6-8 exercises
- Use only exerciseIds from the provided library
- Set realistic weights based on history (slightly progressive)
- Balance muscle groups
''';
  }

  AiSuggestedWorkout? _parseResponse(String content, List<Exercise> exercises) {
    try {
      // Strip markdown code blocks if present
      var jsonStr = content.trim();
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr
            .replaceFirst(RegExp(r'^```[a-z]*\n?'), '')
            .replaceFirst(RegExp(r'\n?```$'), '')
            .trim();
      }

      final Map<String, dynamic> json = jsonDecode(jsonStr);

      final exerciseMap = {for (var e in exercises) e.id: e};

      final workoutExercises = <WorkoutExercise>[];
      for (final item in json['exercises'] as List) {
        final exerciseId = item['exerciseId'] as String;
        final exercise = exerciseMap[exerciseId];
        if (exercise == null) {
          debugPrint('[GROQ] Unknown exerciseId: $exerciseId, skipping');
          continue;
        }
        workoutExercises.add(WorkoutExercise(
          exercise: exercise,
          sets: (item['sets'] as num).toInt(),
          targetReps: (item['targetReps'] as num).toInt(),
          weight: (item['weight'] as num).toDouble(),
        ));
      }

      if (workoutExercises.isEmpty) {
        debugPrint('[GROQ] No valid exercises in response');
        return null;
      }

      final now = DateTime.now();
      final workout = Workout(
        id: 'ai_suggested_${now.millisecondsSinceEpoch}',
        name: json['name'] as String,
        exercises: workoutExercises,
        createdAt: now,
      );

      return AiSuggestedWorkout(
        id: 'suggestion_${now.millisecondsSinceEpoch}',
        workout: workout,
        reasoning: json['reasoning'] as String,
        generatedAt: now,
      );
    } catch (e) {
      debugPrint('[GROQ] Parse error: $e\nContent: $content');
      return null;
    }
  }
}
