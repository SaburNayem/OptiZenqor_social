import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class WalletPaymentsService extends FeatureServiceBase {
  WalletPaymentsService({super.apiClient});

  @override
  String get featureName => 'wallet_payments';

  @override
  Map<String, String> get endpoints => <String, String>{
    'wallet_payments': ApiEndPoints.walletPayments,
    'wallet_ledger': ApiEndPoints.walletLedger,
    'monetization_wallet': ApiEndPoints.monetizationWallet,
  };
}
