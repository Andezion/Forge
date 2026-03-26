import '../models/nutrition_profile.dart';
import '../models/user.dart';

class NutritionAlgorithmService {
  MacroTargets calculateTargets({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
    required int trainingDaysPerWeek,
    required NutritionGoal goal,
    double workoutCaloriesBurned = 0,
  }) {
    final double bmr;
    switch (gender) {
      case Gender.male:
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
        break;
      case Gender.female:
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
        break;
      case Gender.other:
        final male = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
        final female = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
        bmr = (male + female) / 2;
        break;
    }

    final double activityMultiplier;
    if (trainingDaysPerWeek <= 0) {
      activityMultiplier = 1.2;
    } else if (trainingDaysPerWeek <= 2) {
      activityMultiplier = 1.375;
    } else if (trainingDaysPerWeek <= 4) {
      activityMultiplier = 1.55;
    } else if (trainingDaysPerWeek <= 6) {
      activityMultiplier = 1.725;
    } else {
      activityMultiplier = 1.9;
    }

    final double tdee = bmr * activityMultiplier + workoutCaloriesBurned;
    double targetCalories = tdee + goal.calorieAdjustment;

    targetCalories = targetCalories.clamp(1200.0, 6000.0);

    double proteinG, fatG;
    switch (goal) {
      case NutritionGoal.aggressiveFatLoss:
        proteinG = weightKg * 2.4;
        fatG = weightKg * 0.7;
        break;
      case NutritionGoal.fatLoss:
        proteinG = weightKg * 2.2;
        fatG = weightKg * 0.8;
        break;
      case NutritionGoal.maintain:
        proteinG = weightKg * 1.8;
        fatG = weightKg * 0.9;
        break;
      case NutritionGoal.leanBulk:
        proteinG = weightKg * 2.0;
        fatG = weightKg * 1.0;
        break;
      case NutritionGoal.bulk:
        proteinG = weightKg * 2.0;
        fatG = weightKg * 1.1;
        break;
    }

    final carbCals = targetCalories - (proteinG * 4) - (fatG * 9);

    double carbsG;
    if (carbCals < 50 * 4) {
      carbsG = 50;
      final remaining = targetCalories - (carbsG * 4);
      final pRatio = (proteinG * 4) / ((proteinG * 4) + (fatG * 9));
      proteinG = (remaining * pRatio / 4).clamp(50.0, 400.0);
      fatG = (remaining * (1 - pRatio) / 9).clamp(20.0, 200.0);
    } else {
      carbsG = carbCals / 4;
    }

    final waterMl = (weightKg * 35) +
        (trainingDaysPerWeek > 0 ? (500.0 / 7 * trainingDaysPerWeek) : 0);

    return MacroTargets(
      calories: _r(targetCalories),
      proteinG: _r(proteinG),
      carbsG: _r(carbsG),
      fatG: _r(fatG),
      waterMl: _r(waterMl),
    );
  }

  List<MealSlot> generateMealSchedule({
    required MacroTargets targets,
    required NutritionGoal goal,
  }) {
    final int mealCount;
    switch (goal) {
      case NutritionGoal.aggressiveFatLoss:
      case NutritionGoal.fatLoss:
        mealCount = 4;
        break;
      case NutritionGoal.maintain:
        mealCount = 3;
        break;
      case NutritionGoal.leanBulk:
        mealCount = 4;
        break;
      case NutritionGoal.bulk:
        mealCount = 5;
        break;
    }

    const templates = {
      3: [
        ('Breakfast', 8, 0),
        ('Lunch', 13, 0),
        ('Dinner', 19, 0),
      ],
      4: [
        ('Breakfast', 8, 0),
        ('Lunch', 12, 0),
        ('Afternoon Snack', 16, 0),
        ('Dinner', 19, 30),
      ],
      5: [
        ('Breakfast', 8, 0),
        ('Mid-Morning Snack', 11, 0),
        ('Lunch', 14, 0),
        ('Afternoon Snack', 17, 0),
        ('Dinner', 20, 0),
      ],
    };

    const fractions = {
      3: [0.30, 0.40, 0.30],
      4: [0.25, 0.35, 0.15, 0.25],
      5: [0.20, 0.15, 0.30, 0.15, 0.20],
    };

    final tmpl = templates[mealCount]!;
    final frac = fractions[mealCount]!;

    return List.generate(mealCount, (i) {
      final f = frac[i];
      final (name, hour, minute) = tmpl[i];
      return MealSlot(
        name: name,
        hour: hour,
        minute: minute,
        calories: _r(targets.calories * f),
        proteinG: _r(targets.proteinG * f),
        carbsG: _r(targets.carbsG * f),
        fatG: _r(targets.fatG * f),
      );
    });
  }

  double _r(double v) => (v * 10).round() / 10;
}
