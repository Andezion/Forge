import 'package:flutter/material.dart';

enum ChallengeType {
  workouts, // Most workouts
  totalWeight, // Most weight lifted
  specificExercise, // Best performance in specific exercise
  streak, // Longest streak
  consistency, // Most consistent training
}

enum ChallengeStatus {
  pending,
  active,
  completed,
  expired,
}

class Challenge {
  final String id;
  final String creatorId;
  final String creatorName;
  final List<String> participantIds;
  final List<String> participantNames;
  final ChallengeType type;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final ChallengeStatus status;
  final String? exerciseId;
  final String? exerciseName;
  final Map<String, double> scores; // userId -> score
  final String? winnerId;

  Challenge({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.participantIds,
    required this.participantNames,
    required this.type,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.exerciseId,
    this.exerciseName,
    this.scores = const {},
    this.winnerId,
  });

  bool get isActive => status == ChallengeStatus.active;
  bool get isCompleted => status == ChallengeStatus.completed;
  bool get isPending => status == ChallengeStatus.pending;

  Duration get timeRemaining => endDate.difference(DateTime.now());
  Duration get duration => endDate.difference(startDate);

  double get progress {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 1.0;

    final total = endDate.difference(startDate).inMilliseconds;
    final elapsed = now.difference(startDate).inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'type': type.name,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'scores': scores,
      'winnerId': winnerId,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      creatorId: json['creatorId'],
      creatorName: json['creatorName'],
      participantIds: List<String>.from(json['participantIds']),
      participantNames: List<String>.from(json['participantNames']),
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.workouts,
      ),
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChallengeStatus.pending,
      ),
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      scores: Map<String, double>.from(json['scores'] ?? {}),
      winnerId: json['winnerId'],
    );
  }

  Challenge copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    List<String>? participantIds,
    List<String>? participantNames,
    ChallengeType? type,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ChallengeStatus? status,
    String? exerciseId,
    String? exerciseName,
    Map<String, double>? scores,
    String? winnerId,
  }) {
    return Challenge(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      scores: scores ?? this.scores,
      winnerId: winnerId ?? this.winnerId,
    );
  }
}

class ChallengeTemplate {
  final ChallengeType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int defaultDurationDays;

  const ChallengeTemplate({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.defaultDurationDays = 7,
  });

  static List<ChallengeTemplate> getTemplates() {
    return [
      ChallengeTemplate(
        type: ChallengeType.workouts,
        title: 'Workout Challenge',
        description: 'Who can complete the most workouts?',
        icon: Icons.fitness_center,
        color: Colors.blue,
        defaultDurationDays: 7,
      ),
      ChallengeTemplate(
        type: ChallengeType.totalWeight,
        title: 'Weight Challenge',
        description: 'Who can lift the most total weight?',
        icon: Icons.fitness_center,
        color: Colors.orange,
        defaultDurationDays: 7,
      ),
      ChallengeTemplate(
        type: ChallengeType.specificExercise,
        title: 'Exercise Challenge',
        description: 'Who can lift the most in a specific exercise?',
        icon: Icons.emoji_events,
        color: Colors.purple,
        defaultDurationDays: 7,
      ),
      ChallengeTemplate(
        type: ChallengeType.streak,
        title: 'Streak Challenge',
        description: 'Who can maintain the longest training streak?',
        icon: Icons.local_fire_department,
        color: Colors.red,
        defaultDurationDays: 14,
      ),
      ChallengeTemplate(
        type: ChallengeType.consistency,
        title: 'Consistency Challenge',
        description: 'Who can train the most days in a row?',
        icon: Icons.calendar_today,
        color: Colors.green,
        defaultDurationDays: 30,
      ),
    ];
  }
}
