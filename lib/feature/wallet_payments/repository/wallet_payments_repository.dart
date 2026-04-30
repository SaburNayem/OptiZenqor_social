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
    final WalletBalanceModel wallet = await _loadWalletFromApi();
    return wallet.available;
  }

  Future<List<WalletTransactionModel>> history() async {
    return _loadHistoryFromApi();
  }

  Future<WalletBalanceModel> _loadWalletFromApi() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(_service.endpoints['monetization_wallet']!);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load wallet balance.');
    }
    return WalletBalanceModel.fromApiJson(response.data);
  }

  Future<List<WalletTransactionModel>> _loadHistoryFromApi() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(_service.endpoints['wallet_ledger']!);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load wallet history.');
    }
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      response.data,
      preferredKeys: const <String>['transactions', 'ledger', 'items', 'data'],
    );
    return items
        .map(WalletTransactionModel.fromApiJson)
        .toList(growable: false);
  }
}
