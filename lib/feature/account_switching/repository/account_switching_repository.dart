import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../model/account_identity_model.dart';

class AccountSwitchingRepository {
  AccountSwitchingRepository({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

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
    return _storage.read<String>(StorageKeys.activeAccountId);
  }

  Future<void> setActiveAccount(String accountId) {
    return _storage.write(StorageKeys.activeAccountId, accountId);
  }
}
