import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_history.dart';
import '../models/ai_suggested_workout.dart';
import '../models/nutrition_profile.dart';
import '../models/user.dart';
import '../models/workout_session.dart';

const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
const String _model = 'llama-3.3-70b-versatile';

enum TrainingDirection {
  fullBody,
  powerlifting,
  armWrestling,
  streetlifting,
}

extension TrainingDirectionDetails on TrainingDirection {
  String get displayName {
    switch (this) {
      case TrainingDirection.fullBody:
        return 'Full Body';
      case TrainingDirection.powerlifting:
        return 'Powerlifting';
      case TrainingDirection.armWrestling:
        return 'Arm Wrestling';
      case TrainingDirection.streetlifting:
        return 'Streetlifting';
    }
  }

  String get contextPrompt {
    switch (this) {
      case TrainingDirection.fullBody:
        return '''
TRAINING DIRECTION: Full Body
Goal: Balanced development of all major muscle groups.
Muscle Group Priorities (high → low): chest, back, legs, shoulders, core, biceps, triceps
Rules:
- Equal attention to upper body, lower body, and core
- Mix of compound and isolation exercises
- Aim for 2 exercises per major muscle group
- Include both bilateral and unilateral movements
''';
      case TrainingDirection.powerlifting:
        return '''
TRAINING DIRECTION: Powerlifting
Goal: Maximum strength in squat, bench press, and deadlift.
Muscle Group Priorities (high → low): legs, back, chest, core, triceps, shoulders
Rules:
- Squat, bench press, deadlift are MANDATORY if in library
- Accessory work must directly support the big 3
- Low reps (3-6), heavy weights
- Minimal isolation work — only what increases main lifts
''';
      case TrainingDirection.armWrestling:
        return '''
TRAINING DIRECTION: Arm Wrestling
Goal: Arm wrestling-specific strength.
Muscle Group Priorities (high → low): forearms, wrists, biceps, back, shoulders, triceps
Rules:
- MAXIMUM forearms/wrists/grip exercises — this is the #1 priority
- Include pronation, supination, wrist flexion/extension movements
- Back (lats/traps) and biceps are secondary priority
- Legs: MAXIMUM 1-2 exercises, only for general fitness
- Include hammer curls, wrist curls, pronation training if available
''';
      case TrainingDirection.streetlifting:
        return '''
TRAINING DIRECTION: Streetlifting / Calisthenics
Goal: Bodyweight strength and weighted calisthenics.
Muscle Group Priorities (high → low): back, chest, core, biceps, triceps, legs
Rules:
- Foundation: pull-ups, dips, push-ups, squats, core — these are base movements
- Progress toward skills: muscle-up, front lever, back lever, planche
- Add weight to basic movements for progression
- Balance push and pull movements
- Core stability is critical for skills
''';
    }
  }
}

class GroqService {
  final String? _apiKey;

  GroqService({String? apiKey}) : _apiKey = apiKey;

  String get _resolvedKey => _apiKey?.isNotEmpty == true
      ? _apiKey!
      : (dotenv.env['key'] ?? '');

  Future<AiSuggestedWorkout?> generateProgram({
    required List<WorkoutHistory> history,
    required List<Exercise> exercises,
    required TrainingDirection direction,
  }) async {
    try {
      final prompt = _buildPrompt(history, exercises, direction);

      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_resolvedKey',
        },
        body: jsonEncode({
          'model': _model,
          'temperature': 0.7,
          'max_tokens': 2000,
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

  String _buildPrompt(List<WorkoutHistory> history, List<Exercise> exercises,
      TrainingDirection direction) {
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

    final exerciseList = exercises.map((e) {
      final muscles = e.muscleGroups
          .map((mg) => '${mg.group.name}(${mg.intensity.name})')
          .join(', ');
      return '{"id":"${e.id}","name":"${e.name}","muscles":"$muscles","difficulty":"${e.difficulty.name}"}';
    }).join(',\n');

    return '''
You are an expert strength & conditioning coach. Your task is to design a workout program for an athlete.

${direction.contextPrompt}

WORKOUT HISTORY (last ${recentHistory.length} sessions):
${historySummary.isEmpty ? 'No history yet — this is a beginner session.' : historySummary}

AVAILABLE EXERCISES:
[$exerciseList]

RESEARCH INSTRUCTIONS:
For each exercise you select, do the following analysis before including it:
1. Identify which muscle groups it actually activates (primary, secondary, stabilizers)
2. Assess its difficulty — does the difficulty tag in the library match your knowledge?
3. Consider which exercises pair well with it in the same session
4. If an exercise name is unfamiliar or unclear, reason carefully from its name and any clues in the muscle tag data to estimate its purpose and difficulty
5. Avoid pairing exercises that heavily fatigue the same muscle group back-to-back

Based on the athlete's history and training direction above:
- Identify progression trends (weights, reps)
- Prioritize muscle groups according to the training direction rules
- Select exercises that complement each other well within the session

Return ONLY a JSON object (no markdown, no extra text):
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
  "reasoning": "3-4 sentences: explain why these specific exercises were chosen for this training direction, and how they support the athlete's current progression"
}

Rules:
- Include 6-8 exercises
- Use ONLY exerciseIds from the provided library
- Follow the muscle group priorities from the training direction
- Set realistic weights based on history (slightly progressive — about 2-5% more than last session)
- weight: 0.0 for bodyweight exercises
''';
  }

  Future<double?> estimateWorkoutCalories({
    required WorkoutSession session,
    required double bodyWeightKg,
  }) async {
    try {
      final summary = session.exerciseResults.map((er) {
        final sets = er.setResults;
        if (sets.isEmpty) {
          return '${er.exercise.name}: ${er.targetSets}x${er.targetReps} @ ${er.targetWeight}kg';
        }
        final totalReps = sets.map((s) => s.actualReps).reduce((a, b) => a + b);
        final avgWeight =
            sets.map((s) => s.weight).reduce((a, b) => a + b) / sets.length;
        return '${er.exercise.name}: ${sets.length}x$totalReps total reps @ ${avgWeight.toStringAsFixed(1)}kg';
      }).join('\n');

      final durationMin = session.totalDurationSeconds ~/ 60;

      final prompt = '''
Estimate the total calories burned during the following strength training workout.
Athlete body weight: ${bodyWeightKg.toStringAsFixed(1)} kg
Workout duration: $durationMin minutes

Exercises performed:
$summary

Return ONLY a JSON object (no markdown, no extra text):
{"caloriesBurned": 320, "reasoning": "Brief 1-sentence explanation"}
''';

      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_resolvedKey',
        },
        body: jsonEncode({
          'model': _model,
          'temperature': 0.3,
          'max_tokens': 200,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a sports science expert. Estimate calorie expenditure accurately. Respond with valid JSON only.',
            },
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      var jsonStr = content.trim();
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr
            .replaceFirst(RegExp(r'^```[a-z]*\n?'), '')
            .replaceFirst(RegExp(r'\n?```$'), '')
            .trim();
      }
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
      return (parsed['caloriesBurned'] as num).toDouble();
    } catch (e) {
      debugPrint('[GROQ] estimateWorkoutCalories error: $e');
      return null;
    }
  }

  Future<
      ({
        MacroTargets targets,
        List<MealSlot> mealSchedule,
        String reasoning
      })?> generateNutritionPlan({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
    required int trainingDaysPerWeek,
    required NutritionGoal goal,
    double workoutCaloriesBurned = 0,
  }) async {
    try {
      final genderStr = gender.name;
      final prompt = '''
You are a certified sports nutritionist. Create a personalized daily nutrition plan.

ATHLETE PROFILE:
- Weight: ${weightKg.toStringAsFixed(1)} kg
- Height: ${heightCm.toStringAsFixed(0)} cm
- Age: $age years
- Gender: $genderStr
- Training days per week: $trainingDaysPerWeek
- Nutrition goal: ${goal.displayName} (calorie adjustment: ${goal.calorieAdjustment > 0 ? '+' : ''}${goal.calorieAdjustment} kcal/day)
- Calories burned in today's workout: ${workoutCaloriesBurned.toStringAsFixed(0)} kcal

Calculate:
1. Daily calorie target (TDEE-based with goal adjustment)
2. Protein, carbs, fat in grams
3. Daily water intake in ml
4. A meal schedule (3-5 meals) that distributes the macros throughout the day

Return ONLY a JSON object (no markdown, no extra text):
{
  "calories": 2200,
  "proteinG": 175,
  "carbsG": 230,
  "fatG": 70,
  "waterMl": 2800,
  "mealSchedule": [
    {"name": "Breakfast", "hour": 8, "minute": 0, "calories": 550, "proteinG": 44, "carbsG": 58, "fatG": 18},
    {"name": "Lunch", "hour": 13, "minute": 0, "calories": 770, "proteinG": 61, "carbsG": 80, "fatG": 24},
    {"name": "Dinner", "hour": 19, "minute": 0, "calories": 660, "proteinG": 53, "carbsG": 69, "fatG": 21},
    {"name": "Evening Snack", "hour": 21, "minute": 30, "calories": 220, "proteinG": 17, "carbsG": 23, "fatG": 7}
  ],
  "reasoning": "2-3 sentences explaining the rationale for these targets and meal timing"
}
''';

      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_resolvedKey',
        },
        body: jsonEncode({
          'model': _model,
          'temperature': 0.4,
          'max_tokens': 1000,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a certified sports nutritionist. Respond with valid JSON only, no extra text.',
            },
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('[GROQ] nutrition plan error ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      var jsonStr = content.trim();
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr
            .replaceFirst(RegExp(r'^```[a-z]*\n?'), '')
            .replaceFirst(RegExp(r'\n?```$'), '')
            .trim();
      }

      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

      final targets = MacroTargets(
        calories: (parsed['calories'] as num).toDouble(),
        proteinG: (parsed['proteinG'] as num).toDouble(),
        carbsG: (parsed['carbsG'] as num).toDouble(),
        fatG: (parsed['fatG'] as num).toDouble(),
        waterMl: (parsed['waterMl'] as num).toDouble(),
      );

      final mealSchedule = (parsed['mealSchedule'] as List)
          .map((m) => MealSlot.fromJson(m as Map<String, dynamic>))
          .toList();

      final reasoning = parsed['reasoning'] as String? ?? '';

      return (
        targets: targets,
        mealSchedule: mealSchedule,
        reasoning: reasoning,
      );
    } catch (e) {
      debugPrint('[GROQ] generateNutritionPlan error: $e');
      return null;
    }
  }

  // Matches a user exercise name to a standard powerlifting lift via AI.
  // Returns 'squat', 'bench', 'deadlift', or null if no confident match.
  // Result is cached in SharedPreferences to avoid repeated API calls.
  Future<String?> matchExerciseToRecord(String exerciseId, String exerciseName) async {
    const cachePrefix = 'rankMatch_';
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$cachePrefix$exerciseId');
    if (cached != null) return cached == 'none' ? null : cached;

    try {
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_resolvedKey',
        },
        body: jsonEncode({
          'model': _model,
          'temperature': 0.1,
          'max_tokens': 60,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a powerlifting expert. Match exercise names to standard competition lifts. Respond with valid JSON only.',
            },
            {
              'role': 'user',
              'content': '''
Does the exercise "$exerciseName" correspond to one of the 3 standard powerlifting competition lifts?
Rules:
- "squat" = back squat, low bar squat, high bar squat, competition squat
- "bench" = flat bench press, competition bench press
- "deadlift" = conventional deadlift, sumo deadlift, competition deadlift
- Variations like Romanian Deadlift, Pause Squat, Close Grip Bench are NOT competition lifts → null
- If unsure or it's a variation → null

Return ONLY JSON: {"match": "squat"|"bench"|"deadlift"|null, "confidence": 0.0-1.0}''',
            },
          ],
        }),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      var content = (data['choices'][0]['message']['content'] as String).trim();
      if (content.startsWith('```')) {
        content = content
            .replaceFirst(RegExp(r'^```[a-z]*\n?'), '')
            .replaceFirst(RegExp(r'\n?```$'), '')
            .trim();
      }
      final parsed = jsonDecode(content) as Map<String, dynamic>;
      final match = parsed['match'] as String?;
      final confidence = (parsed['confidence'] as num?)?.toDouble() ?? 0.0;

      final result = (match != null && confidence >= 0.75) ? match : null;
      await prefs.setString('$cachePrefix$exerciseId', result ?? 'none');
      return result;
    } catch (e) {
      debugPrint('[GROQ] matchExerciseToRecord error: $e');
      return null;
    }
  }

  AiSuggestedWorkout? _parseResponse(String content, List<Exercise> exercises) {
    try {
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
