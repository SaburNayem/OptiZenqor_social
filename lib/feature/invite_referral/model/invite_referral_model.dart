class InvitedFriend {
  final String id;
  final String name;
  final String avatarUrl;
  final String status; // 'Joined' or 'Pending'
  final String? invitedAt;

  const InvitedFriend({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
    this.invitedAt,
  });

  factory InvitedFriend.fromApiJson(Map<String, dynamic> json) {
    return InvitedFriend(
      id: (json['id'] ?? json['email'] ?? json['name'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
      status: (json['status'] ?? 'Pending').toString(),
      invitedAt: json['invitedAt']?.toString(),
    );
  }
}

class ReferralMilestone {
  final int count;
  final String reward;
  final bool isAchieved;

  const ReferralMilestone({
    required this.count,
    required this.reward,
    required this.isAchieved,
  });

  factory ReferralMilestone.fromApiJson(Map<String, dynamic> json) {
    return ReferralMilestone(
      count: int.tryParse('${json['count'] ?? 0}') ?? 0,
      reward: (json['reward'] ?? '').toString(),
      isAchieved: json['isAchieved'] == true,
    );
  }
}

class InviteReferralModel {
  const InviteReferralModel({
    required this.inviteCode,
    required this.benefit,
    required this.currentInvites,
    required this.totalMilestone,
    required this.milestones,
    required this.invitedFriends,
  });

  final String inviteCode;
  final String benefit;
  final int currentInvites;
  final int totalMilestone;
  final List<ReferralMilestone> milestones;
  final List<InvitedFriend> invitedFriends;

  factory InviteReferralModel.fromApiJson(Map<String, dynamic> json) {
    final List<dynamic> rawMilestones =
        (json['milestones'] as List<dynamic>?) ?? const <dynamic>[];
    final List<dynamic> rawFriends =
        (json['invitedFriends'] as List<dynamic>?) ?? const <dynamic>[];
    return InviteReferralModel(
      inviteCode: (json['inviteCode'] ?? '').toString(),
      benefit: (json['benefit'] ?? '').toString(),
      currentInvites: int.tryParse('${json['currentInvites'] ?? 0}') ?? 0,
      totalMilestone: int.tryParse('${json['totalMilestone'] ?? 0}') ?? 0,
      milestones: rawMilestones
          .whereType<Map<String, dynamic>>()
          .map(ReferralMilestone.fromApiJson)
          .toList(growable: false),
      invitedFriends: rawFriends
          .whereType<Map<String, dynamic>>()
          .map(InvitedFriend.fromApiJson)
          .toList(growable: false),
    );
  }
}
