import '../model/invite_referral_model.dart';

class InviteReferralController {
  final InviteReferralModel model = const InviteReferralModel(
    inviteCode: 'SOCIAL2024',
    benefit: 'Invite friends to join SocialApp and earn exclusive rewards.',
    currentInvites: 3,
    totalMilestone: 10,
    milestones: [
      ReferralMilestone(
        count: 5,
        reward: 'Premium Profile Badge',
        isAchieved: false,
      ),
      ReferralMilestone(
        count: 10,
        reward: '1 Month Premium Free',
        isAchieved: false,
      ),
    ],
    invitedFriends: [
      InvitedFriend(
        name: 'Sarah Jenkins',
        avatarUrl: 'https://i.pravatar.cc/150?u=sarahj',
        status: 'Joined',
      ),
      InvitedFriend(
        name: 'Marcus Chen',
        avatarUrl: 'https://i.pravatar.cc/150?u=marcusc',
        status: 'Joined',
      ),
      InvitedFriend(
        name: 'Emma Wilson',
        avatarUrl: 'https://i.pravatar.cc/150?u=emmaw',
        status: 'Pending',
      ),
    ],
  );

  String buildInviteLink() {
    return 'https://optizenqor.app/invite/${model.inviteCode}';
  }

  String buildShareMessage() {
    return 'Join me on SocialApp with code ${model.inviteCode}. '
        'Use this link: ${buildInviteLink()}';
  }
}
