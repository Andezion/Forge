enum ExerciseDifficulty {
  easy,
  medium,
  hard,
}

enum MuscleGroup {
  chest,
  back, // Спина
  legs, // Ноги
  shoulders, // Плечи
  biceps, // Бицепс
  triceps, // Трицепс
  forearms, // Предплечья
  wrists, // Кисти (для армрестлинга)
  core, // Кор/Пресс
  glutes, // Ягодицы
  calves, // Икры
  cardio, // Кардио
}

enum MuscleGroupIntensity {
  primary,
  secondary,
  stabilizer,
}

class MuscleGroupTag {
  final MuscleGroup group;
  final MuscleGroupIntensity intensity;

  const MuscleGroupTag({
    required this.group,
    required this.intensity,
  });

  int get score {
    switch (intensity) {
      case MuscleGroupIntensity.primary:
        return 3;
      case MuscleGroupIntensity.secondary:
        return 2;
      case MuscleGroupIntensity.stabilizer:
        return 1;
    }
  }

  Map<String, dynamic> toJson() => {
        'group': group.name,
        'intensity': intensity.name,
      };

  factory MuscleGroupTag.fromJson(Map<String, dynamic> json) {
    return MuscleGroupTag(
      group: MuscleGroup.values.firstWhere(
        (e) => e.name == json['group'],
        orElse: () => MuscleGroup.core,
      ),
      intensity: MuscleGroupIntensity.values.firstWhere(
        (e) => e.name == json['intensity'],
        orElse: () => MuscleGroupIntensity.secondary,
      ),
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final ExerciseDifficulty difficulty;
  final DateTime createdAt;

  final List<MuscleGroupTag> muscleGroups;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.createdAt,
    this.muscleGroups = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty.name,
      'createdAt': createdAt.toIso8601String(),
      'muscleGroups': muscleGroups.map((mg) => mg.toJson()).toList(),
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      difficulty: ExerciseDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ExerciseDifficulty.medium,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      muscleGroups: json['muscleGroups'] != null
          ? (json['muscleGroups'] as List)
              .map((mg) => MuscleGroupTag.fromJson(mg))
              .toList()
          : [],
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    ExerciseDifficulty? difficulty,
    DateTime? createdAt,
    List<MuscleGroupTag>? muscleGroups,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      muscleGroups: muscleGroups ?? this.muscleGroups,
    );
  }
}
