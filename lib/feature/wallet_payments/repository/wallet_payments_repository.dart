import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/wallet_balance_model.dart';
import '../model/wallet_transaction_model.dart';
import '../service/wallet_payments_service.dart';

class WalletPaymentsRepository {
  WalletPaymentsRepository({WalletPaymentsService? service})
    : _service = service ?? WalletPaymentsService();

  final WalletPaymentsService _service;

  Future<double> balance() async {
    final WalletBalanceModel? remoteBalance = await _loadBalanceFromApi();
    if (remoteBalance != null) {
      return remoteBalance.available;
    }
    return 245.75;
  }

  Future<List<WalletTransactionModel>> history() async {
    final List<WalletTransactionModel>? remoteHistory = await _loadHistoryFromApi();
    if (remoteHistory != null) {
      return remoteHistory;
    }
    return <WalletTransactionModel>[
      WalletTransactionModel(
        title: 'Subscription payout',
        amount: 89.00,
        date: DateTime(2026, 3, 20),
      ),
      WalletTransactionModel(
        title: 'Marketplace sale',
        amount: 120.50,
        date: DateTime(2026, 3, 18),
      ),
      WalletTransactionModel(
        title: 'Boost campaign',
        amount: -35.25,
        date: DateTime(2026, 3, 16),
      ),
    ];
  }

  Future<WalletBalanceModel?> _loadBalanceFromApi() async {
    for (final String key in <String>['wallet_payments', 'monetization_wallet']) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }
        return WalletBalanceModel.fromApiJson(response.data);
      } catch (_) {}
    }
    return null;
  }

  Future<List<WalletTransactionModel>?> _loadHistoryFromApi() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.getEndpoint('wallet_ledger');
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
      }
      final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
        response.data,
        preferredKeys: const <String>['transactions', 'ledger', 'items'],
      );
      if (items.isNotEmpty || response.data.isNotEmpty) {
        return items
            .map(WalletTransactionModel.fromApiJson)
            .toList(growable: false);
      }
    } catch (_) {}
    return null;
  }
}
