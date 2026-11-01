import 'workout_session.dart';

class WorkoutHistory {
  final String id;
  final DateTime date;
  final WorkoutSession session;
  final String? note;

  WorkoutHistory({
    required this.id,
    required this.date,
    required this.session,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'session': session.toJson(),
      'note': note,
    };
  }

  factory WorkoutHistory.fromJson(Map<String, dynamic> json) {
    return WorkoutHistory(
      id: json['id'],
      date: DateTime.parse(json['date']),
      session: WorkoutSession.fromJson(json['session']),
      note: json['note'],
    );
  }

  WorkoutHistory copyWithNote(String? note) {
    return WorkoutHistory(
      id: id,
      date: date,
      session: session,
      note: note,
    );
  }

  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  bool get hasNote => note != null && note!.trim().isNotEmpty;
}
