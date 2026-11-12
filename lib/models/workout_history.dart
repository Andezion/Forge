import 'workout_session.dart';

class WorkoutHistory {
  final String id;
  final DateTime date;
  final WorkoutSession session;
  final String? note;

  final double? estimatedCalories;

  WorkoutHistory({
    required this.id,
    required this.date,
    required this.session,
    this.note,
    this.estimatedCalories,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'session': session.toJson(),
      'note': note,
      'estimatedCalories': estimatedCalories,
    };
  }

  factory WorkoutHistory.fromJson(Map<String, dynamic> json) {
    return WorkoutHistory(
      id: json['id'],
      date: DateTime.parse(json['date']),
      session: WorkoutSession.fromJson(json['session']),
      note: json['note'],
      estimatedCalories: (json['estimatedCalories'] as num?)?.toDouble(),
    );
  }

  WorkoutHistory copyWithNote(String? note) {
    return WorkoutHistory(
      id: id,
      date: date,
      session: session,
      note: note,
      estimatedCalories: estimatedCalories,
    );
  }

  WorkoutHistory copyWithCalories(double? calories) {
    return WorkoutHistory(
      id: id,
      date: date,
      session: session,
      note: note,
      estimatedCalories: calories,
    );
  }

  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  bool get hasNote => note != null && note!.trim().isNotEmpty;

  bool get hasCalories => estimatedCalories != null && estimatedCalories! > 0;
}
