class WorldRecord {
  final String id;
  final String exercise;
  final String federation;
  final String weightClass;
  final String gender;
  final bool equipped;
  final double weight;
  final String athleteName;
  final String country;
  final DateTime? recordDate;

  const WorldRecord({
    required this.id,
    required this.exercise,
    required this.federation,
    required this.weightClass,
    required this.gender,
    required this.equipped,
    required this.weight,
    required this.athleteName,
    required this.country,
    this.recordDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'exercise': exercise,
        'federation': federation,
        'weightClass': weightClass,
        'gender': gender,
        'equipped': equipped,
        'weight': weight,
        'athleteName': athleteName,
        'country': country,
        'recordDate': recordDate?.toIso8601String(),
      };

  factory WorldRecord.fromJson(Map<String, dynamic> json) {
    return WorldRecord(
      id: json['id'] as String,
      exercise: json['exercise'] as String,
      federation: json['federation'] as String,
      weightClass: json['weightClass'] as String,
      gender: json['gender'] as String,
      equipped: json['equipped'] as bool,
      weight: (json['weight'] as num).toDouble(),
      athleteName: json['athleteName'] as String,
      country: json['country'] as String,
      recordDate: json['recordDate'] != null
          ? DateTime.parse(json['recordDate'] as String)
          : null,
    );
  }

  WorldRecord copyWith({
    String? id,
    String? exercise,
    String? federation,
    String? weightClass,
    String? gender,
    bool? equipped,
    double? weight,
    String? athleteName,
    String? country,
    DateTime? recordDate,
  }) {
    return WorldRecord(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      federation: federation ?? this.federation,
      weightClass: weightClass ?? this.weightClass,
      gender: gender ?? this.gender,
      equipped: equipped ?? this.equipped,
      weight: weight ?? this.weight,
      athleteName: athleteName ?? this.athleteName,
      country: country ?? this.country,
      recordDate: recordDate ?? this.recordDate,
    );
  }
}
