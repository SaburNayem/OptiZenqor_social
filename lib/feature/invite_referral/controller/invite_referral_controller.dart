import '../model/invite_referral_model.dart';
import '../repository/invite_referral_repository.dart';

class InviteReferralController {
  InviteReferralController({InviteReferralRepository? repository})
    : _repository = repository ?? InviteReferralRepository();

  final InviteReferralRepository _repository;

  Future<InviteReferralModel> load() => _repository.load();

  String buildInviteLink(InviteReferralModel model) {
    return 'https://optizenqor.app/invite/${model.inviteCode}';
  }

  String buildShareMessage(InviteReferralModel model) {
    return 'Join me on SocialApp with code ${model.inviteCode}. '
        'Use this link: ${buildInviteLink(model)}';
  }
}
