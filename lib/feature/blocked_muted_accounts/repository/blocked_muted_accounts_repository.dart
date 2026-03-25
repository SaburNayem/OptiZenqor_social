import '../../../core/constants/storage_keys.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../model/restricted_account_model.dart';

class BlockedMutedAccountsRepository {
  BlockedMutedAccountsRepository({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  static const List<RestrictedAccountModel> _seedBlocked =
      <RestrictedAccountModel>[
        RestrictedAccountModel(
          id: 'b1',
          name: 'Sarah Jenkins',
          handle: '@sarahj',
          status: 'blocked',
        ),
        RestrictedAccountModel(
          id: 'b2',
          name: 'Marcus Chen',
          handle: '@marcusc',
          status: 'blocked',
        ),
        RestrictedAccountModel(
          id: 'b3',
          name: 'Emma Wilson',
          handle: '@emmaw',
          status: 'blocked',
        ),
      ];

  static const List<RestrictedAccountModel> _seedMuted =
      <RestrictedAccountModel>[
        RestrictedAccountModel(
          id: 'm1',
          name: 'Muted Creator',
          handle: '@muted.creator',
          status: 'muted',
        ),
      ];

  Future<List<RestrictedAccountModel>> loadBlocked() async {
    final raw = await _storage.readJsonList(StorageKeys.blockedAccounts);
    if (raw.isEmpty) {
      await saveBlocked(_seedBlocked);
      return _seedBlocked;
    }
    return raw.map(RestrictedAccountModel.fromJson).toList();
  }

  Future<List<RestrictedAccountModel>> loadMuted() async {
    final raw = await _storage.readJsonList(StorageKeys.mutedAccounts);
    if (raw.isEmpty) {
      await saveMuted(_seedMuted);
      return _seedMuted;
    }
    return raw.map(RestrictedAccountModel.fromJson).toList();
  }

  Future<void> saveBlocked(List<RestrictedAccountModel> accounts) {
    return _storage.writeJsonList(
      StorageKeys.blockedAccounts,
      accounts.map((item) => item.toJson()).toList(),
    );
  }

  Future<void> saveMuted(List<RestrictedAccountModel> accounts) {
    return _storage.writeJsonList(
      StorageKeys.mutedAccounts,
      accounts.map((item) => item.toJson()).toList(),
    );
  }
}
