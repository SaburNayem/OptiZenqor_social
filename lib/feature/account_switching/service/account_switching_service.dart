import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class AccountSwitchingService extends FeatureServiceBase {
  AccountSwitchingService({super.apiClient});

  @override
  String get featureName => 'account_switching';

  @override
  Map<String, String> get endpoints => <String, String>{
    'account_switching': ApiEndPoints.accountSwitching,
    'active': ApiEndPoints.accountSwitchingActive,
    'me': ApiEndPoints.authMe,
    'users': ApiEndPoints.users,
  };
}
