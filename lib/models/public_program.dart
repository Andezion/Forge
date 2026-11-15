import 'package:cloud_firestore/cloud_firestore.dart';

import 'workout.dart';

enum PublicProgramStatus { pending, approved, rejected }

enum ProgramCategory { fullBody, powerlifting, armWrestling, streetlifting, other }

class PublicProgram {
  static const maxNameLength = 60;
  static const maxDescriptionLength = 500;
  static const maxExercises = 40;

  final String id;
  final String authorId;
  final String authorNickname;
  final String name;
  final String description;
  final ProgramCategory category;
  final String language;
  final Workout workout;
  final List<String> muscleGroups;
  final PublicProgramStatus status;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final bool authorNotified;
  final int downloadCount;
  final String sourceWorkoutId;

  const PublicProgram({
    required this.id,
    required this.authorId,
    required this.authorNickname,
    required this.name,
    required this.description,
    required this.category,
    required this.language,
    required this.workout,
    required this.muscleGroups,
    required this.status,
    this.rejectionReason,
    this.createdAt,
    this.reviewedAt,
    this.authorNotified = false,
    this.downloadCount = 0,
    required this.sourceWorkoutId,
  });

  static String docIdFor(String authorId, String workoutId) =>
      '${authorId}_$workoutId';

  int get exerciseCount => workout.exercises.length;

  bool get hasUnseenReview =>
      status != PublicProgramStatus.pending && !authorNotified;

  static Workout sanitizeWorkout(Workout workout, {String? name}) => Workout(
        id: workout.id,
        name: name ?? workout.name,
        createdAt: workout.createdAt,
        exercises: workout.exercises.map((we) => we.copyWith(weight: 0)).toList(),
      );

  static Map<String, dynamic> submissionData({
    required String authorId,
    required String authorNickname,
    required String name,
    required String description,
    required ProgramCategory category,
    required String language,
    required Workout workout,
    int downloadCount = 0,
  }) {
    final clean = sanitizeWorkout(workout, name: name);
    final groups = <String>{
      for (final we in clean.exercises)
        for (final tag in we.exercise.muscleGroups) tag.group.name,
    }.toList();
    return {
      'authorId': authorId,
      'authorNickname': authorNickname,
      'name': name,
      'description': description,
      'category': category.name,
      'language': language,
      'workout': clean.toJson(),
      'exerciseCount': clean.exercises.length,
      'muscleGroups': groups,
      'status': PublicProgramStatus.pending.name,
      'rejectionReason': null,
      'reviewedAt': null,
      'authorNotified': false,
      'downloadCount': downloadCount,
      'sourceWorkoutId': workout.id,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory PublicProgram.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final workoutJson =
        Map<String, dynamic>.from(d['workout'] as Map? ?? const {});
    return PublicProgram(
      id: doc.id,
      authorId: d['authorId'] as String? ?? '',
      authorNickname: d['authorNickname'] as String? ?? '',
      name: d['name'] as String? ?? '',
      description: d['description'] as String? ?? '',
      category: ProgramCategory.values.firstWhere(
        (c) => c.name == d['category'],
        orElse: () => ProgramCategory.other,
      ),
      language: d['language'] as String? ?? '',
      workout: workoutJson.isEmpty
          ? Workout(id: '', name: '', exercises: [], createdAt: DateTime(2000))
          : Workout.fromJson(_deepConvert(workoutJson)),
      muscleGroups: List<String>.from(d['muscleGroups'] as List? ?? const []),
      status: PublicProgramStatus.values.firstWhere(
        (s) => s.name == d['status'],
        orElse: () => PublicProgramStatus.pending,
      ),
      rejectionReason: (d['rejectionReason'] as String?)?.trim().isEmpty == true
          ? null
          : d['rejectionReason'] as String?,
      createdAt: _date(d['createdAt']),
      reviewedAt: _date(d['reviewedAt']),
      authorNotified: d['authorNotified'] as bool? ?? false,
      downloadCount: (d['downloadCount'] as num?)?.toInt() ?? 0,
      sourceWorkoutId: d['sourceWorkoutId'] as String? ?? '',
    );
  }

  PublicProgram copyWith({int? downloadCount}) => PublicProgram(
        id: id,
        authorId: authorId,
        authorNickname: authorNickname,
        name: name,
        description: description,
        category: category,
        language: language,
        workout: workout,
        muscleGroups: muscleGroups,
        status: status,
        rejectionReason: rejectionReason,
        createdAt: createdAt,
        reviewedAt: reviewedAt,
        authorNotified: authorNotified,
        downloadCount: downloadCount ?? this.downloadCount,
        sourceWorkoutId: sourceWorkoutId,
      );

  static DateTime? _date(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static Map<String, dynamic> _deepConvert(Map map) => map.map(
        (k, v) => MapEntry(k.toString(), _convertValue(v)),
      );

  static dynamic _convertValue(dynamic v) {
    if (v is Map) return _deepConvert(v);
    if (v is List) return v.map(_convertValue).toList();
    return v;
  }
}
