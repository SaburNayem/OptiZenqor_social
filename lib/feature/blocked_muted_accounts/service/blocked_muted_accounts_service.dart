import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class BlockedMutedAccountsService extends FeatureServiceBase {
  BlockedMutedAccountsService({super.apiClient});

  @override
  String get featureName => 'blocked_muted_accounts';

  @override
  Map<String, String> get endpoints => <String, String>{
    'blocked_muted_accounts': ApiEndPoints.blockedMutedAccounts,
    'users': ApiEndPoints.users,
    'block_user': ApiEndPoints.blockByTargetId(':id'),
    'safety_config': ApiEndPoints.safetyConfig,
  };
}
