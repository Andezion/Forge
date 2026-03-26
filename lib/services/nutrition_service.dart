import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nutrition_profile.dart';
import '../models/user.dart';
import '../models/workout_session.dart';
import 'nutrition_algorithm_service.dart';
import 'groq_service.dart';

class NutritionService extends ChangeNotifier {
  static const _keyProfile = 'nutrition_profile';

  final _algorithm = NutritionAlgorithmService();
  final _groq = GroqService();

  NutritionProfile _profile = const NutritionProfile();
  bool _isCalculating = false;
  String? _error;

  NutritionProfile get profile => _profile;
  bool get isCalculating => _isCalculating;
  String? get error => _error;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyProfile);
    if (raw != null) {
      try {
        _profile =
            NutritionProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _profile = const NutritionProfile();
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, jsonEncode(_profile.toJson()));
  }

  Future<void> setGoal(NutritionGoal goal) async {
    _profile = _profile.copyWith(goal: goal);
    notifyListeners();
    await _save();
  }

  Future<void> setWaterReminderInterval(int minutes) async {
    _profile = _profile.copyWith(waterReminderIntervalMinutes: minutes);
    notifyListeners();
    await _save();
  }

  Future<void> recalculate({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
    required int trainingDaysPerWeek,
    WorkoutSession? workoutSession,
  }) async {
    final goal = _profile.goal ?? NutritionGoal.maintain;

    _isCalculating = true;
    _error = null;
    notifyListeners();

    try {
      double workoutCalories = 0;
      if (workoutSession != null) {
        workoutCalories = await _groq.estimateWorkoutCalories(
              session: workoutSession,
              bodyWeightKg: weightKg,
            ) ??
            0;
      }

      // Step 2: Algorithm calculation (instant, always succeeds)
      final algoTargets = _algorithm.calculateTargets(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
        trainingDaysPerWeek: trainingDaysPerWeek,
        goal: goal,
        workoutCaloriesBurned: workoutCalories,
      );
      final algoMeals = _algorithm.generateMealSchedule(
        targets: algoTargets,
        goal: goal,
      );

      // Step 3: AI nutrition plan (may fail — that's OK)
      final aiResult = await _groq.generateNutritionPlan(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
        trainingDaysPerWeek: trainingDaysPerWeek,
        goal: goal,
        workoutCaloriesBurned: workoutCalories,
      );

      _profile = _profile.copyWith(
        algorithmTargets: algoTargets,
        // Use AI meal schedule if available, otherwise algorithm's
        mealSchedule: aiResult?.mealSchedule ?? algoMeals,
        aiTargets: aiResult?.targets,
        aiReasoning: aiResult?.reasoning,
        lastCalculated: DateTime.now(),
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('[NutritionService] recalculate error: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
      await _save();
    }
  }

  /// Quick recalculation using only the algorithm (no AI call).
  /// Useful when profile parameters change.
  Future<void> recalculateAlgorithmOnly({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
    required int trainingDaysPerWeek,
  }) async {
    final goal = _profile.goal ?? NutritionGoal.maintain;

    final algoTargets = _algorithm.calculateTargets(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
      trainingDaysPerWeek: trainingDaysPerWeek,
      goal: goal,
    );
    final algoMeals = _algorithm.generateMealSchedule(
      targets: algoTargets,
      goal: goal,
    );

    _profile = _profile.copyWith(
      algorithmTargets: algoTargets,
      mealSchedule: _profile.aiTargets != null
          ? _profile.mealSchedule // keep AI schedule if we already have one
          : algoMeals,
      lastCalculated: DateTime.now(),
    );
    notifyListeners();
    await _save();
  }
}
