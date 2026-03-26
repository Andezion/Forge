enum NutritionGoal {
  aggressiveFatLoss,
  fatLoss,
  maintain,
  leanBulk,
  bulk,
}

extension NutritionGoalExt on NutritionGoal {
  String get displayName {
    switch (this) {
      case NutritionGoal.aggressiveFatLoss:
        return 'Aggressive Fat Loss';
      case NutritionGoal.fatLoss:
        return 'Fat Loss';
      case NutritionGoal.maintain:
        return 'Maintain Weight';
      case NutritionGoal.leanBulk:
        return 'Lean Bulk';
      case NutritionGoal.bulk:
        return 'Bulk';
    }
  }

  String get description {
    switch (this) {
      case NutritionGoal.aggressiveFatLoss:
        return 'Aggressive deficit for fast fat loss. -500 kcal/day.';
      case NutritionGoal.fatLoss:
        return 'Moderate deficit for steady fat loss. -300 kcal/day.';
      case NutritionGoal.maintain:
        return 'Eat at maintenance to preserve current weight.';
      case NutritionGoal.leanBulk:
        return 'Small surplus for muscle gain with minimal fat. +250 kcal/day.';
      case NutritionGoal.bulk:
        return 'Significant surplus for maximum muscle growth. +500 kcal/day.';
    }
  }

  int get calorieAdjustment {
    switch (this) {
      case NutritionGoal.aggressiveFatLoss:
        return -500;
      case NutritionGoal.fatLoss:
        return -300;
      case NutritionGoal.maintain:
        return 0;
      case NutritionGoal.leanBulk:
        return 250;
      case NutritionGoal.bulk:
        return 500;
    }
  }
}

class MacroTargets {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double waterMl;

  const MacroTargets({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.waterMl,
  });

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'waterMl': waterMl,
      };

  factory MacroTargets.fromJson(Map<String, dynamic> json) => MacroTargets(
        calories: (json['calories'] as num).toDouble(),
        proteinG: (json['proteinG'] as num).toDouble(),
        carbsG: (json['carbsG'] as num).toDouble(),
        fatG: (json['fatG'] as num).toDouble(),
        waterMl: (json['waterMl'] as num).toDouble(),
      );
}

class MealSlot {
  final String name;
  final int hour;
  final int minute;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const MealSlot({
    required this.name,
    required this.hour,
    required this.minute,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'hour': hour,
        'minute': minute,
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
      };

  factory MealSlot.fromJson(Map<String, dynamic> json) => MealSlot(
        name: json['name'] as String,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        calories: (json['calories'] as num).toDouble(),
        proteinG: (json['proteinG'] as num).toDouble(),
        carbsG: (json['carbsG'] as num).toDouble(),
        fatG: (json['fatG'] as num).toDouble(),
      );
}

class NutritionProfile {
  final NutritionGoal? goal;
  final MacroTargets? algorithmTargets;
  final MacroTargets? aiTargets;
  final List<MealSlot> mealSchedule;
  final int waterReminderIntervalMinutes;
  final String? aiReasoning;
  final DateTime? lastCalculated;

  const NutritionProfile({
    this.goal,
    this.algorithmTargets,
    this.aiTargets,
    this.mealSchedule = const [],
    this.waterReminderIntervalMinutes = 90,
    this.aiReasoning,
    this.lastCalculated,
  });

  Map<String, dynamic> toJson() => {
        'goal': goal?.name,
        'algorithmTargets': algorithmTargets?.toJson(),
        'aiTargets': aiTargets?.toJson(),
        'mealSchedule': mealSchedule.map((m) => m.toJson()).toList(),
        'waterReminderIntervalMinutes': waterReminderIntervalMinutes,
        'aiReasoning': aiReasoning,
        'lastCalculated': lastCalculated?.toIso8601String(),
      };

  factory NutritionProfile.fromJson(Map<String, dynamic> json) =>
      NutritionProfile(
        goal: json['goal'] != null
            ? NutritionGoal.values.firstWhere(
                (e) => e.name == json['goal'],
                orElse: () => NutritionGoal.maintain,
              )
            : null,
        algorithmTargets: json['algorithmTargets'] != null
            ? MacroTargets.fromJson(
                json['algorithmTargets'] as Map<String, dynamic>)
            : null,
        aiTargets: json['aiTargets'] != null
            ? MacroTargets.fromJson(json['aiTargets'] as Map<String, dynamic>)
            : null,
        mealSchedule: json['mealSchedule'] != null
            ? (json['mealSchedule'] as List)
                .map((m) => MealSlot.fromJson(m as Map<String, dynamic>))
                .toList()
            : [],
        waterReminderIntervalMinutes:
            json['waterReminderIntervalMinutes'] as int? ?? 90,
        aiReasoning: json['aiReasoning'] as String?,
        lastCalculated: json['lastCalculated'] != null
            ? DateTime.parse(json['lastCalculated'] as String)
            : null,
      );

  NutritionProfile copyWith({
    NutritionGoal? goal,
    MacroTargets? algorithmTargets,
    MacroTargets? aiTargets,
    List<MealSlot>? mealSchedule,
    int? waterReminderIntervalMinutes,
    String? aiReasoning,
    DateTime? lastCalculated,
  }) =>
      NutritionProfile(
        goal: goal ?? this.goal,
        algorithmTargets: algorithmTargets ?? this.algorithmTargets,
        aiTargets: aiTargets ?? this.aiTargets,
        mealSchedule: mealSchedule ?? this.mealSchedule,
        waterReminderIntervalMinutes:
            waterReminderIntervalMinutes ?? this.waterReminderIntervalMinutes,
        aiReasoning: aiReasoning ?? this.aiReasoning,
        lastCalculated: lastCalculated ?? this.lastCalculated,
      );
}
