enum WeightUnit { kg, lb }

enum DistanceUnit { meters, feet }

enum AppLanguage { english, russian }

class AppSettings {
  final String? nickname;
  final String? region;
  final AppLanguage language;
  final WeightUnit weightUnit;
  final DistanceUnit distanceUnit;
  final bool isProfilePublic;
  final bool showWorkoutHistory;
  final bool showPersonalRecords;
  final bool allowFriendRequests;
  final bool isProfileHidden;

  const AppSettings({
    this.nickname,
    this.region,
    this.language = AppLanguage.english,
    this.weightUnit = WeightUnit.kg,
    this.distanceUnit = DistanceUnit.meters,
    this.isProfilePublic = true,
    this.showWorkoutHistory = true,
    this.showPersonalRecords = true,
    this.allowFriendRequests = true,
    this.isProfileHidden = false,
  });

  AppSettings copyWith({
    String? nickname,
    String? region,
    AppLanguage? language,
    WeightUnit? weightUnit,
    DistanceUnit? distanceUnit,
    bool? isProfilePublic,
    bool? showWorkoutHistory,
    bool? showPersonalRecords,
    bool? allowFriendRequests,
    bool? isProfileHidden,
  }) {
    return AppSettings(
      nickname: nickname ?? this.nickname,
      region: region ?? this.region,
      language: language ?? this.language,
      weightUnit: weightUnit ?? this.weightUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      showWorkoutHistory: showWorkoutHistory ?? this.showWorkoutHistory,
      showPersonalRecords: showPersonalRecords ?? this.showPersonalRecords,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      isProfileHidden: isProfileHidden ?? this.isProfileHidden,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'region': region,
      'language': language.name,
      'weightUnit': weightUnit.name,
      'distanceUnit': distanceUnit.name,
      'isProfilePublic': isProfilePublic,
      'showWorkoutHistory': showWorkoutHistory,
      'showPersonalRecords': showPersonalRecords,
      'allowFriendRequests': allowFriendRequests,
      'isProfileHidden': isProfileHidden,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      nickname: json['nickname'],
      region: json['region'],
      language: AppLanguage.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => AppLanguage.english,
      ),
      weightUnit: WeightUnit.values.firstWhere(
        (e) => e.name == json['weightUnit'],
        orElse: () => WeightUnit.kg,
      ),
      distanceUnit: DistanceUnit.values.firstWhere(
        (e) => e.name == json['distanceUnit'],
        orElse: () => DistanceUnit.meters,
      ),
      isProfilePublic: json['isProfilePublic'] ?? true,
      showWorkoutHistory: json['showWorkoutHistory'] ?? true,
      showPersonalRecords: json['showPersonalRecords'] ?? true,
      allowFriendRequests: json['allowFriendRequests'] ?? true,
      isProfileHidden: json['isProfileHidden'] ?? false,
    );
  }
}
