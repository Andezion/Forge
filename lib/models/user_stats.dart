class UserStats {
  final String userId;
  final String displayName;
  final int workoutCount;
  final double totalWeightLifted;
  final int currentStreak;
  final DateTime lastWorkoutDate;
  final Map<String, double> exerciseRecords;
  final bool isProfileHidden;
  final DateTime updatedAt;

  UserStats({
    required this.userId,
    required this.displayName,
    required this.workoutCount,
    required this.totalWeightLifted,
    required this.currentStreak,
    required this.lastWorkoutDate,
    required this.exerciseRecords,
    this.isProfileHidden = false,
    required this.updatedAt,
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
      'updatedAt': updatedAt.toIso8601String(),
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
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
    DateTime? updatedAt,
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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
