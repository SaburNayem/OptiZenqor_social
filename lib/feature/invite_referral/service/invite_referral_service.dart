import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class InviteReferralService extends FeatureServiceBase {
  InviteReferralService({super.apiClient});

  @override
  String get featureName => 'invite_referral';

  @override
  Map<String, String> get endpoints => <String, String>{
    'invite_referral': ApiEndPoints.inviteReferral,
  };
}
