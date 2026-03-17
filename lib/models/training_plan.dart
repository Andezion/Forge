class ScheduledWorkout {
  final String workoutId;
  final String workoutName;
  final List<int> daysOfWeek; // 1=Monday ... 7=Sunday
  final int frequencyWeeks; // 1=every week, 2=every 2 weeks
  final int weekOffset; // 0 or 1, used for biweekly to pick which week

  ScheduledWorkout({
    required this.workoutId,
    required this.workoutName,
    required this.daysOfWeek,
    this.frequencyWeeks = 1,
    this.weekOffset = 0,
  });

  /// Returns true if this workout should happen on [date].
  bool isScheduledForDate(DateTime date) {
    if (!daysOfWeek.contains(date.weekday)) return false;
    if (frequencyWeeks == 1) return true;
    // Biweekly: use a fixed epoch Monday to count weeks
    final epoch = DateTime(2024, 1, 1); // a Monday
    final daysDiff = date.difference(epoch).inDays;
    final weekIndex = daysDiff ~/ 7;
    return weekIndex % frequencyWeeks == weekOffset % frequencyWeeks;
  }

  Map<String, dynamic> toJson() => {
        'workoutId': workoutId,
        'workoutName': workoutName,
        'daysOfWeek': daysOfWeek,
        'frequencyWeeks': frequencyWeeks,
        'weekOffset': weekOffset,
      };

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) =>
      ScheduledWorkout(
        workoutId: json['workoutId'],
        workoutName: json['workoutName'],
        daysOfWeek: List<int>.from(json['daysOfWeek']),
        frequencyWeeks: json['frequencyWeeks'] ?? 1,
        weekOffset: json['weekOffset'] ?? 0,
      );

  ScheduledWorkout copyWith({
    String? workoutId,
    String? workoutName,
    List<int>? daysOfWeek,
    int? frequencyWeeks,
    int? weekOffset,
  }) =>
      ScheduledWorkout(
        workoutId: workoutId ?? this.workoutId,
        workoutName: workoutName ?? this.workoutName,
        daysOfWeek: daysOfWeek ?? this.daysOfWeek,
        frequencyWeeks: frequencyWeeks ?? this.frequencyWeeks,
        weekOffset: weekOffset ?? this.weekOffset,
      );
}

class TrainingPlan {
  final String id;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final List<ScheduledWorkout> schedule;

  TrainingPlan({
    required this.id,
    required this.name,
    this.isActive = false,
    required this.createdAt,
    required this.schedule,
  });

  /// Returns workouts scheduled for [date].
  List<ScheduledWorkout> workoutsForDate(DateTime date) =>
      schedule.where((sw) => sw.isScheduledForDate(date)).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'schedule': schedule.map((s) => s.toJson()).toList(),
      };

  factory TrainingPlan.fromJson(Map<String, dynamic> json) => TrainingPlan(
        id: json['id'],
        name: json['name'],
        isActive: json['isActive'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        schedule: (json['schedule'] as List)
            .map((s) => ScheduledWorkout.fromJson(s))
            .toList(),
      );

  TrainingPlan copyWith({
    String? id,
    String? name,
    bool? isActive,
    DateTime? createdAt,
    List<ScheduledWorkout>? schedule,
  }) =>
      TrainingPlan(
        id: id ?? this.id,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        schedule: schedule ?? this.schedule,
      );
}
