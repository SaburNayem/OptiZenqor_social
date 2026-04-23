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

  static const List<AccountIdentityModel> _seedAccounts =
      <AccountIdentityModel>[
        AccountIdentityModel(
          id: 'u1',
          name: 'Maya Quinn',
          handle: '@mayaquinn',
          roleLabel: 'Creator',
          isVerified: true,
        ),
        AccountIdentityModel(
          id: 'u2',
          name: 'Nexa Studio',
          handle: '@nexa.studio',
          roleLabel: 'Business',
          isVerified: true,
        ),
        AccountIdentityModel(
          id: 'u3',
          name: 'Rafi Ahmed',
          handle: '@rafiahmed',
          roleLabel: 'Personal',
        ),
      ];

  Future<List<AccountIdentityModel>> fetchAccounts() async {
    final List<AccountIdentityModel>? remoteAccounts = await _fetchAccountsFromApi();
    if (remoteAccounts != null) {
      await saveAccounts(remoteAccounts);
      return remoteAccounts;
    }

    final raw = await _storage.readJsonList(StorageKeys.linkedAccounts);
    if (raw.isEmpty) {
      await saveAccounts(_seedAccounts);
      return _seedAccounts;
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
      await _service.postEndpoint(
        'active',
        payload: <String, dynamic>{'accountId': accountId},
      );
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
        final Map<String, dynamic>? active = ApiPayloadReader.readMap(
          response.data['data'] ?? response.data['active'] ?? response.data['account'],
        );
        final String accountId = ApiPayloadReader.readString(
          response.data['accountId'] ?? active?['id'],
        );
        if (accountId.isNotEmpty) {
          await _storage.write(StorageKeys.activeAccountId, accountId);
          return accountId;
        }
      }
    } catch (_) {}

    return _storage.read<String>(StorageKeys.activeAccountId);
  }
}
