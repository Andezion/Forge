enum ExerciseDifficulty {
  easy,
  medium,
  hard,
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final ExerciseDifficulty difficulty;
  final DateTime createdAt;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty.name,
      'createdAt': createdAt.toIso8601String(),
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
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    ExerciseDifficulty? difficulty,
    DateTime? createdAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
