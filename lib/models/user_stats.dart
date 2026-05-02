class UserStats {
  final String userId;
  final String displayName;
  final int workoutCount;
  final double totalWeightLifted;
  final int currentStreak;
  final DateTime lastWorkoutDate;
  final Map<String, double> exerciseRecords;
  final bool isProfileHidden;
  final bool isProfilePublic;
  final DateTime updatedAt;
  final double weeklyProgressPercentage;
  final String? country;
  final String? city;

  UserStats({
    required this.userId,
    required this.displayName,
    required this.workoutCount,
    required this.totalWeightLifted,
    required this.currentStreak,
    required this.lastWorkoutDate,
    required this.exerciseRecords,
    this.isProfileHidden = false,
    this.isProfilePublic = true,
    required this.updatedAt,
    this.weeklyProgressPercentage = 0.0,
    this.country,
    this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'workoutCount': workoutCount,
      'totalWeightLifted': totalWeightLifted,
      'currentStreak': currentStreak,
      'lastWorkoutDate': lastWorkoutDate.toIso8601String(),
      'exerciseRecords': exerciseRecords,
      'isProfileHidden': isProfileHidden,
      'isProfilePublic': isProfilePublic,
      'updatedAt': updatedAt.toIso8601String(),
      'weeklyProgressPercentage': weeklyProgressPercentage,
      if (country != null) 'country': country,
      if (city != null) 'city': city,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      workoutCount: json['workoutCount'] as int,
      totalWeightLifted: (json['totalWeightLifted'] as num).toDouble(),
      currentStreak: json['currentStreak'] as int,
      lastWorkoutDate: DateTime.parse(json['lastWorkoutDate'] as String),
      exerciseRecords: Map<String, double>.from(
        (json['exerciseRecords'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      isProfileHidden: json['isProfileHidden'] as bool? ?? false,
      isProfilePublic: json['isProfilePublic'] as bool? ?? true,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      weeklyProgressPercentage:
          (json['weeklyProgressPercentage'] as num?)?.toDouble() ?? 0.0,
      country: json['country'] as String?,
      city: json['city'] as String?,
    );
  }

  UserStats copyWith({
    String? userId,
    String? displayName,
    int? workoutCount,
    double? totalWeightLifted,
    int? currentStreak,
    DateTime? lastWorkoutDate,
    Map<String, double>? exerciseRecords,
    bool? isProfileHidden,
    bool? isProfilePublic,
    DateTime? updatedAt,
    double? weeklyProgressPercentage,
    String? country,
    String? city,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      workoutCount: workoutCount ?? this.workoutCount,
      totalWeightLifted: totalWeightLifted ?? this.totalWeightLifted,
      currentStreak: currentStreak ?? this.currentStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      exerciseRecords: exerciseRecords ?? this.exerciseRecords,
      isProfileHidden: isProfileHidden ?? this.isProfileHidden,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      updatedAt: updatedAt ?? this.updatedAt,
      weeklyProgressPercentage:
          weeklyProgressPercentage ?? this.weeklyProgressPercentage,
      country: country ?? this.country,
      city: city ?? this.city,
    );
  }
}
