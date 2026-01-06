import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../models/workout_recommendation.dart';
import '../models/workout_history.dart';
import '../models/wellness_entry.dart';
import '../models/user.dart';
import 'progression_service.dart';
import 'wellness_service.dart';
import 'data_manager.dart';
import 'profile_service.dart';

class WorkoutRecommendationService extends ChangeNotifier {
  final ProgressionService _progressionService = ProgressionService();
  final WellnessService _wellnessService;
  final DataManager _dataManager;
  final ProfileService _profileService;

  WorkoutRecommendation? _todaysRecommendation;
  DateTime? _lastRecommendationDate;

  WorkoutRecommendationService({
    required WellnessService wellnessService,
    required DataManager dataManager,
    required ProfileService profileService,
  })  : _wellnessService = wellnessService,
        _dataManager = dataManager,
        _profileService = profileService;

  WorkoutRecommendation? get todaysRecommendation => _todaysRecommendation;

  /// Generate today's workout recommendation
  Future<WorkoutRecommendation?> generateTodaysRecommendation() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Check if we already have a recommendation for today
    if (_lastRecommendationDate != null &&
        _lastRecommendationDate!.year == todayDate.year &&
        _lastRecommendationDate!.month == todayDate.month &&
        _lastRecommendationDate!.day == todayDate.day &&
        _todaysRecommendation != null) {
      return _todaysRecommendation;
    }

    // Get all necessary data
    final workouts = _dataManager.workouts;
    if (workouts.isEmpty) {
      return null;
    }

    final histories = _dataManager.workoutHistory;
    final recentWellness = _wellnessService.recentEntries;

    // Load profile
    await _profileService.load();
    final goals = _profileService.goals
        .map((g) => TrainingGoal.values.firstWhere((e) => e.name == g,
            orElse: () => TrainingGoal.generalFitness))
        .toList();
    final experience = _profileService.experienceLevel != null
        ? ExperienceLevel.values.firstWhere(
            (e) => e.name == _profileService.experienceLevel,
            orElse: () => ExperienceLevel.intermediate)
        : ExperienceLevel.intermediate;
    final intensity = _profileService.preferredIntensity != null
        ? TrainingIntensity.values.firstWhere(
            (e) => e.name == _profileService.preferredIntensity,
            orElse: () => TrainingIntensity.moderate)
        : TrainingIntensity.moderate;

    final profile = UserProfile(
      goals: goals,
      experienceLevel: experience,
      trainingFocus: _profileService.trainingFocus,
      preferredIntensity: intensity,
      age: _profileService.age,
      weightKg: _profileService.weightKg,
      yearsTraining: _profileService.yearsTraining,
    );

    // Analyze factors
    final factors = _analyzeFactors(histories, recentWellness, profile);

    // Select best workout
    final selectedWorkout = _selectBestWorkout(workouts, histories, factors);

    // Generate adjusted workout with progression
    final adjustedResult = await _progressionService.suggestNextWorkout(
      selectedWorkout,
      histories,
      lookback: 5,
      profile: profile,
    );

    final adjustedWorkout = adjustedResult['workout'] as Workout;
    final reasons = adjustedResult['reasons'] as Map<String, String>;
    final needsDeload = adjustedResult['needsDeload'] as bool;

    // Determine recommendation level
    final level = _determineLevel(factors, needsDeload);

    // Build exercise recommendations
    final exerciseRecommendations = <ExerciseRecommendation>[];
    for (var exercise in adjustedWorkout.exercises) {
      final reason = reasons[exercise.exercise.id] ?? 'Standard progression';
      final confidence = _calculateExerciseConfidence(
        exercise.exercise.id,
        histories,
        factors,
      );

      exerciseRecommendations.add(ExerciseRecommendation(
        exercise: exercise,
        reason: reason,
        confidenceScore: confidence,
      ));
    }

    // Build overall reason
    final overallReason = _buildOverallReason(factors, level, needsDeload);

    // Calculate overall confidence
    final overallConfidence = exerciseRecommendations.isEmpty
        ? 0.5
        : exerciseRecommendations
                .map((e) => e.confidenceScore)
                .reduce((a, b) => a + b) /
            exerciseRecommendations.length;

    _todaysRecommendation = WorkoutRecommendation(
      workoutId: adjustedWorkout.id,
      workoutName: adjustedWorkout.name,
      exercises: exerciseRecommendations,
      level: level,
      overallReason: overallReason,
      generatedAt: today,
      overallConfidence: overallConfidence,
      factors: factors,
    );

    _lastRecommendationDate = todayDate;
    notifyListeners();

    return _todaysRecommendation;
  }

  /// Analyze all factors influencing today's recommendation
  Map<String, dynamic> _analyzeFactors(
    List<WorkoutHistory> histories,
    List<WellnessEntry> wellness,
    UserProfile profile,
  ) {
    final factors = <String, dynamic>{};

    // Recovery analysis
    final lastWorkout = histories.isNotEmpty ? histories.last.date : null;
    final daysSinceLastWorkout = lastWorkout != null
        ? DateTime.now().difference(lastWorkout).inDays
        : 999;
    factors['daysSinceLastWorkout'] = daysSinceLastWorkout;

    // Wellness analysis
    if (wellness.isNotEmpty) {
      final latest = wellness.last;
      final avgScore = latest.averageScore;

      final energy = latest.answers['Energy'] ?? 3;
      final mood = latest.answers['Mood'] ?? 3;
      final tiredness = latest.answers['Tiredness'] ?? 3;
      final stress = latest.answers['Stress'] ?? 3;
      final muscleSoreness = latest.answers['Muscle soreness'] ?? 3;

      factors['wellnessAverage'] = avgScore;
      factors['energy'] = energy;
      factors['mood'] = mood;
      factors['tiredness'] = tiredness;
      factors['stress'] = stress;
      factors['muscleSoreness'] = muscleSoreness;

      // Calculate readiness score (0-1)
      final readiness = ((energy +
                  mood +
                  (5 - tiredness) +
                  (5 - stress) +
                  (5 - muscleSoreness)) /
              25.0)
          .clamp(0.0, 1.0);
      factors['readiness'] = readiness;
    } else {
      factors['wellnessAverage'] = 3.0;
      factors['readiness'] = 0.6;
    }

    // Training frequency analysis
    if (histories.isNotEmpty) {
      final last30Days = histories.where((h) {
        final diff = DateTime.now().difference(h.date).inDays;
        return diff <= 30;
      }).toList();

      factors['workoutsLast30Days'] = last30Days.length;
      factors['avgWorkoutsPerWeek'] =
          (last30Days.length / 4.3).toStringAsFixed(1);
    } else {
      factors['workoutsLast30Days'] = 0;
      factors['avgWorkoutsPerWeek'] = '0.0';
    }

    // Check for overtraining
    final needsDeload = _progressionService.shouldDeload(histories);
    factors['needsDeload'] = needsDeload;

    // Profile factors
    factors['experienceLevel'] = profile.experienceLevel.name;
    factors['preferredIntensity'] = profile.preferredIntensity.name;
    factors['age'] = profile.age ?? 30;

    return factors;
  }

  /// Select the best workout based on rotation and history
  Workout _selectBestWorkout(
    List<Workout> workouts,
    List<WorkoutHistory> histories,
    Map<String, dynamic> factors,
  ) {
    if (workouts.isEmpty) {
      throw Exception('No workouts available');
    }

    if (workouts.length == 1) {
      return workouts.first;
    }

    // Get last few workouts to avoid repetition
    final lastWorkoutIds = histories.reversed
        .take(3)
        .map((h) => h.session.workout?.id)
        .where((id) => id != null)
        .toList();

    // Try to find a workout that wasn't done recently
    final freshWorkouts =
        workouts.where((w) => !lastWorkoutIds.contains(w.id)).toList();

    if (freshWorkouts.isNotEmpty) {
      // Select based on readiness
      final readiness = factors['readiness'] as double;

      if (readiness > 0.7) {
        // High readiness - return the first workout
        return freshWorkouts.first;
      } else if (readiness > 0.5) {
        // Medium readiness - rotate
        return freshWorkouts[freshWorkouts.length > 1 ? 1 : 0];
      } else {
        // Low readiness - prefer lighter workout (first or last)
        return freshWorkouts.first;
      }
    }

    // All workouts were done recently, just rotate
    return workouts.first;
  }

  /// Determine recommendation level based on factors
  RecommendationLevel _determineLevel(
    Map<String, dynamic> factors,
    bool needsDeload,
  ) {
    if (needsDeload) {
      return RecommendationLevel.light;
    }

    final readiness = factors['readiness'] as double;
    final daysSince = factors['daysSinceLastWorkout'] as int;

    // Rest day criteria
    if (daysSince < 1) {
      return RecommendationLevel.rest;
    }

    if (readiness < 0.4) {
      return RecommendationLevel.rest;
    }

    final muscleSoreness = factors['muscleSoreness'] as int? ?? 3;
    final tiredness = factors['tiredness'] as int? ?? 3;

    if (muscleSoreness >= 4 && tiredness >= 4) {
      return RecommendationLevel.rest;
    }

    // Intensity levels
    if (readiness >= 0.75 && daysSince >= 2) {
      return RecommendationLevel.intense;
    } else if (readiness >= 0.6) {
      return RecommendationLevel.moderate;
    } else {
      return RecommendationLevel.light;
    }
  }

  /// Calculate confidence score for individual exercise
  double _calculateExerciseConfidence(
    String exerciseId,
    List<WorkoutHistory> histories,
    Map<String, dynamic> factors,
  ) {
    // Start with base confidence
    double confidence = 0.5;

    // Check exercise history
    int timesPerformed = 0;
    for (var h in histories) {
      for (var er in h.session.exerciseResults) {
        if (er.exercise.id == exerciseId) {
          timesPerformed++;
        }
      }
    }

    // More history = higher confidence
    if (timesPerformed >= 10) {
      confidence += 0.3;
    } else if (timesPerformed >= 5) {
      confidence += 0.2;
    } else if (timesPerformed >= 2) {
      confidence += 0.1;
    }

    // Wellness factors
    final readiness = factors['readiness'] as double;
    confidence += (readiness - 0.5) * 0.4;

    return confidence.clamp(0.0, 1.0);
  }

  /// Build human-readable overall reason
  String _buildOverallReason(
    Map<String, dynamic> factors,
    RecommendationLevel level,
    bool needsDeload,
  ) {
    final reasons = <String>[];

    if (needsDeload) {
      reasons.add('Deload week recommended for recovery');
    }

    final readiness = factors['readiness'] as double;
    final daysSince = factors['daysSinceLastWorkout'] as int;

    if (level == RecommendationLevel.rest) {
      if (daysSince < 1) {
        reasons.add('Rest day - you trained yesterday');
      } else if (readiness < 0.4) {
        reasons.add('Rest day - wellness indicators suggest recovery needed');
      } else {
        reasons.add('Rest day recommended based on overall condition');
      }
    } else {
      if (readiness >= 0.75) {
        reasons.add('High readiness - great day for training');
      } else if (readiness >= 0.6) {
        reasons.add('Good readiness for a moderate workout');
      } else {
        reasons.add('Light training recommended today');
      }

      if (daysSince >= 3) {
        reasons
            .add('${daysSince} days since last workout - good recovery time');
      } else if (daysSince >= 2) {
        reasons.add('Well-recovered from last session');
      } else if (daysSince == 1) {
        reasons.add('One day recovery - intensity adjusted accordingly');
      }
    }

    final muscleSoreness = factors['muscleSoreness'] as int? ?? 3;
    if (muscleSoreness >= 4) {
      reasons.add('High muscle soreness noted - weights adjusted');
    }

    final energy = factors['energy'] as int? ?? 3;
    if (energy <= 2) {
      reasons.add('Low energy - consider lighter intensity');
    } else if (energy >= 4) {
      reasons.add('Good energy levels detected');
    }

    return reasons.join('. ') + '.';
  }

  /// Check if we should recommend rest instead of training
  bool shouldRestToday(Map<String, dynamic> factors) {
    final readiness = factors['readiness'] as double;
    final daysSince = factors['daysSinceLastWorkout'] as int;

    if (daysSince < 1) return true;
    if (readiness < 0.4) return true;

    final muscleSoreness = factors['muscleSoreness'] as int? ?? 3;
    final tiredness = factors['tiredness'] as int? ?? 3;

    if (muscleSoreness >= 4 && tiredness >= 4) return true;

    return false;
  }

  /// Clear today's recommendation (e.g., after completing workout)
  void clearTodaysRecommendation() {
    _todaysRecommendation = null;
    _lastRecommendationDate = null;
    notifyListeners();
  }

  /// Force regenerate recommendation
  Future<WorkoutRecommendation?> regenerateRecommendation() async {
    _lastRecommendationDate = null;
    return await generateTodaysRecommendation();
  }
}
