class ExerciseMax {
  final String exerciseId;
  final String exerciseName;
  final double maxWeight;
  final DateTime achievedAt;
  final double rating;

  ExerciseMax({
    required this.exerciseId,
    required this.exerciseName,
    required this.maxWeight,
    required this.achievedAt,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'maxWeight': maxWeight,
      'achievedAt': achievedAt.toIso8601String(),
      'rating': rating,
    };
  }

  factory ExerciseMax.fromJson(Map<String, dynamic> json) {
    return ExerciseMax(
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      maxWeight: (json['maxWeight'] as num).toDouble(),
      achievedAt: DateTime.parse(json['achievedAt']),
      rating: (json['rating'] as num).toDouble(),
    );
  }

  ExerciseMax copyWith({
    String? exerciseId,
    String? exerciseName,
    double? maxWeight,
    DateTime? achievedAt,
    double? rating,
  }) {
    return ExerciseMax(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      maxWeight: maxWeight ?? this.maxWeight,
      achievedAt: achievedAt ?? this.achievedAt,
      rating: rating ?? this.rating,
    );
  }
}

class User {
  final String id;
  final String name;
  final String? nickname;
  final String email;
  final double height;
  final double weight;
  final List<ExerciseMax> exerciseMaxes;
  final double overallRating;
  final DateTime createdAt;
  final DateTime? lastWorkoutDate;

  User({
    required this.id,
    required this.name,
    this.nickname,
    required this.email,
    required this.height,
    required this.weight,
    required this.exerciseMaxes,
    required this.overallRating,
    required this.createdAt,
    this.lastWorkoutDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'email': email,
      'height': height,
      'weight': weight,
      'exerciseMaxes': exerciseMaxes.map((e) => e.toJson()).toList(),
      'overallRating': overallRating,
      'createdAt': createdAt.toIso8601String(),
      'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      nickname: json['nickname'],
      email: json['email'],
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      exerciseMaxes: (json['exerciseMaxes'] as List)
          .map((e) => ExerciseMax.fromJson(e))
          .toList(),
      overallRating: (json['overallRating'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      lastWorkoutDate: json['lastWorkoutDate'] != null
          ? DateTime.parse(json['lastWorkoutDate'])
          : null,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? nickname,
    String? email,
    double? height,
    double? weight,
    List<ExerciseMax>? exerciseMaxes,
    double? overallRating,
    DateTime? createdAt,
    DateTime? lastWorkoutDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      exerciseMaxes: exerciseMaxes ?? this.exerciseMaxes,
      overallRating: overallRating ?? this.overallRating,
      createdAt: createdAt ?? this.createdAt,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
    );
  }
}

enum ExperienceLevel { beginner, intermediate, advanced }

enum TrainingGoal { strength, hypertrophy, endurance, fatLoss, generalFitness }

enum TrainingIntensity { light, moderate, intense }

class UserProfile {
  final List<TrainingGoal> goals;
  final ExperienceLevel experienceLevel;
  final List<String> trainingFocus;
  final TrainingIntensity preferredIntensity;
  final int? age;
  final double? weightKg;
  final double? yearsTraining;

  UserProfile({
    required this.goals,
    required this.experienceLevel,
    required this.trainingFocus,
    required this.preferredIntensity,
    this.age,
    this.weightKg,
    this.yearsTraining,
  });

  Map<String, dynamic> toJson() {
    return {
      'goals': goals.map((g) => g.name).toList(),
      'experienceLevel': experienceLevel.name,
      'trainingFocus': trainingFocus,
      'preferredIntensity': preferredIntensity.name,
      'age': age,
      'weightKg': weightKg,
      'yearsTraining': yearsTraining,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      goals: (json['goals'] as List)
          .map((g) => TrainingGoal.values.firstWhere((e) => e.name == g,
              orElse: () => TrainingGoal.generalFitness))
          .toList(),
      experienceLevel: ExperienceLevel.values.firstWhere(
          (e) => e.name == json['experienceLevel'],
          orElse: () => ExperienceLevel.intermediate),
      trainingFocus:
          (json['trainingFocus'] as List).map((e) => e.toString()).toList(),
      preferredIntensity: TrainingIntensity.values.firstWhere(
          (e) => e.name == json['preferredIntensity'],
          orElse: () => TrainingIntensity.moderate),
      age: json['age'],
      weightKg: json['weightKg'] != null
          ? (json['weightKg'] as num).toDouble()
          : null,
      yearsTraining: json['yearsTraining'] != null
          ? (json['yearsTraining'] as num).toDouble()
          : null,
    );
  }

  UserProfile copyWith({
    List<TrainingGoal>? goals,
    ExperienceLevel? experienceLevel,
    List<String>? trainingFocus,
    TrainingIntensity? preferredIntensity,
    int? age,
    double? weightKg,
    double? yearsTraining,
  }) {
    return UserProfile(
      goals: goals ?? this.goals,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      trainingFocus: trainingFocus ?? this.trainingFocus,
      preferredIntensity: preferredIntensity ?? this.preferredIntensity,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      yearsTraining: yearsTraining ?? this.yearsTraining,
    );
  }
}
