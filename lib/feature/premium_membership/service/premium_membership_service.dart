import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class PremiumMembershipService extends FeatureServiceBase {
  PremiumMembershipService({super.apiClient});

  @override
  String get featureName => 'premium_membership';

  @override
  Map<String, String> get endpoints => <String, String>{
    'premium_membership': ApiEndPoints.premiumMembership,
    'plans': ApiEndPoints.monetizationPlans,
  };
}
