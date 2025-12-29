class Friend {
  final String userId;
  final String name;
  final String email;
  final double? weight;
  final double? overallRating;
  final DateTime? lastWorkoutDate;
  final DateTime friendsSince;

  Friend({
    required this.userId,
    required this.name,
    required this.email,
    this.weight,
    this.overallRating,
    this.lastWorkoutDate,
    required this.friendsSince,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'weight': weight,
      'overallRating': overallRating,
      'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
      'friendsSince': friendsSince.toIso8601String(),
    };
  }

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      weight:
          json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      overallRating: json['overallRating'] != null
          ? (json['overallRating'] as num).toDouble()
          : null,
      lastWorkoutDate: json['lastWorkoutDate'] != null
          ? DateTime.parse(json['lastWorkoutDate'] as String)
          : null,
      friendsSince: DateTime.parse(json['friendsSince'] as String),
    );
  }

  Friend copyWith({
    String? userId,
    String? name,
    String? email,
    double? weight,
    double? overallRating,
    DateTime? lastWorkoutDate,
    DateTime? friendsSince,
  }) {
    return Friend(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      weight: weight ?? this.weight,
      overallRating: overallRating ?? this.overallRating,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      friendsSince: friendsSince ?? this.friendsSince,
    );
  }
}

enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequest {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String fromUserEmail;
  final String toUserId;
  final String toUserEmail;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserEmail,
    required this.toUserId,
    required this.toUserEmail,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserEmail': fromUserEmail,
      'toUserId': toUserId,
      'toUserEmail': toUserEmail,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  factory FriendRequest.fromJson(Map<String, dynamic> json, String id) {
    return FriendRequest(
      id: id,
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      fromUserEmail: json['fromUserEmail'] as String,
      toUserId: json['toUserId'] as String,
      toUserEmail: json['toUserEmail'] as String,
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }

  FriendRequest copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? fromUserEmail,
    String? toUserId,
    String? toUserEmail,
    FriendRequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserEmail: fromUserEmail ?? this.fromUserEmail,
      toUserId: toUserId ?? this.toUserId,
      toUserEmail: toUserEmail ?? this.toUserEmail,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
