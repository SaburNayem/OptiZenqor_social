import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/account_identity_model.dart';
import '../service/account_switching_service.dart';

class AccountSwitchingRepository {
  AccountSwitchingRepository({
    LocalStorageService? storage,
    AccountSwitchingService? service,
  }) : _storage = storage ?? LocalStorageService(),
       _service = service ?? AccountSwitchingService();

  final LocalStorageService _storage;
  final AccountSwitchingService _service;

  Future<List<AccountIdentityModel>> fetchAccounts() async {
    final List<AccountIdentityModel>? remoteAccounts = await _fetchAccountsFromApi();
    if (remoteAccounts != null) {
      await saveAccounts(remoteAccounts);
      return remoteAccounts;
    }

    final raw = await _storage.readJsonList(StorageKeys.linkedAccounts);
    if (raw.isEmpty) {
      return const <AccountIdentityModel>[];
    }
    return raw.map(AccountIdentityModel.fromJson).toList();
  }

  Future<void> saveAccounts(List<AccountIdentityModel> accounts) {
    return _storage.writeJsonList(
      StorageKeys.linkedAccounts,
      accounts.map((account) => account.toJson()).toList(),
    );
  }

  Future<String?> readActiveAccountId() {
    return _readActiveAccountId();
  }

  Future<void> setActiveAccount(String accountId) async {
    await _storage.write(StorageKeys.activeAccountId, accountId);

    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.postEndpoint(
        'active',
        payload: <String, dynamic>{'accountId': accountId},
      );
      if (response.isSuccess && response.data['success'] != false) {
        final String resolvedAccountId = _extractActiveAccountId(response.data);
        if (resolvedAccountId.isNotEmpty) {
          await _storage.write(StorageKeys.activeAccountId, resolvedAccountId);
        }
      }
    } catch (_) {}
  }

  Future<List<AccountIdentityModel>?> _fetchAccountsFromApi() async {
    for (final String key in <String>['account_switching', 'demo_accounts', 'users']) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }

        final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['accounts', 'linkedAccounts', 'users'],
        );
        if (items.isNotEmpty) {
          return items
              .map(AccountIdentityModel.fromApiJson)
              .where((AccountIdentityModel item) => item.id.isNotEmpty)
              .toList(growable: false);
        }
      } catch (_) {}
    }

    return null;
  }

  Future<String?> _readActiveAccountId() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.getEndpoint('active');
      if (response.isSuccess && response.data['success'] != false) {
        final String accountId = _extractActiveAccountId(response.data);
        if (accountId.isNotEmpty) {
          await _storage.write(StorageKeys.activeAccountId, accountId);
          return accountId;
        }
      }
    } catch (_) {}

    return _storage.read<String>(StorageKeys.activeAccountId);
  }

  String _extractActiveAccountId(Map<String, dynamic> payload) {
    final Map<String, dynamic>? active = ApiPayloadReader.readMap(
      payload['active'] ?? payload['account'],
    );
    final Map<String, dynamic>? data = ApiPayloadReader.readMap(payload['data']);
    return ApiPayloadReader.readString(
      payload['activeAccountId'] ??
          payload['accountId'] ??
          active?['id'] ??
          data?['id'],
    );
  }
}
