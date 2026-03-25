class InvitedFriend {
  final String name;
  final String avatarUrl;
  final String status; // 'Joined' or 'Pending'

  const InvitedFriend({
    required this.name,
    required this.avatarUrl,
    required this.status,
  });
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
}
