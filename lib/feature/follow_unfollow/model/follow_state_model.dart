class FollowStateModel {
  const FollowStateModel({
    required this.targetUserId,
    this.isFollowing = false,
    this.hasPendingRequest = false,
    this.isPrivateAccount = false,
  });

  final String targetUserId;
  final bool isFollowing;
  final bool hasPendingRequest;
  final bool isPrivateAccount;

  FollowStateModel copyWith({
    bool? isFollowing,
    bool? hasPendingRequest,
    bool? isPrivateAccount,
  }) {
    return FollowStateModel(
      targetUserId: targetUserId,
      isFollowing: isFollowing ?? this.isFollowing,
      hasPendingRequest: hasPendingRequest ?? this.hasPendingRequest,
      isPrivateAccount: isPrivateAccount ?? this.isPrivateAccount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'targetUserId': targetUserId,
      'isFollowing': isFollowing,
      'hasPendingRequest': hasPendingRequest,
      'isPrivateAccount': isPrivateAccount,
    };
  }

  factory FollowStateModel.fromMap(Map<String, dynamic> map) {
    return FollowStateModel(
      targetUserId: map['targetUserId'] as String,
      isFollowing: map['isFollowing'] as bool? ?? false,
      hasPendingRequest: map['hasPendingRequest'] as bool? ?? false,
      isPrivateAccount: map['isPrivateAccount'] as bool? ?? false,
    );
  }
}
