import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/restricted_account_model.dart';
import '../service/blocked_muted_accounts_service.dart';

class BlockedMutedAccountsRepository {
  BlockedMutedAccountsRepository({
    LocalStorageService? storage,
    BlockedMutedAccountsService? service,
  }) : _storage = storage ?? LocalStorageService(),
       _service = service ?? BlockedMutedAccountsService();

  final LocalStorageService _storage;
  final BlockedMutedAccountsService _service;

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
    final List<RestrictedAccountModel>? remoteBlocked = await _loadFromApi(
      status: 'blocked',
      preferredKeys: const <String>['blocked', 'users'],
    );
    if (remoteBlocked != null) {
      await saveBlocked(remoteBlocked);
      return remoteBlocked;
    }

    final raw = await _storage.readJsonList(StorageKeys.blockedAccounts);
    if (raw.isEmpty) {
      await saveBlocked(_seedBlocked);
      return _seedBlocked;
    }
    return raw.map(RestrictedAccountModel.fromJson).toList();
  }

  Future<List<RestrictedAccountModel>> loadMuted() async {
    final List<RestrictedAccountModel>? remoteMuted = await _loadFromApi(
      status: 'muted',
      preferredKeys: const <String>['muted', 'users'],
    );
    if (remoteMuted != null) {
      await saveMuted(remoteMuted);
      return remoteMuted;
    }

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

  Future<bool> unblockAccount(String id) async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.apiClient.delete(
            _service.endpoints['block_user']!.replaceFirst(':id', id),
          );
      return response.isSuccess && response.data['success'] != false;
    } catch (_) {
      return false;
    }
  }

  Future<List<RestrictedAccountModel>?> _loadFromApi({
    required String status,
    required List<String> preferredKeys,
  }) async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.getEndpoint('blocked_muted_accounts');
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
      }
      final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
        response.data,
        preferredKeys: preferredKeys,
      );
      if (items.isNotEmpty || response.data.isNotEmpty) {
        return items
            .map(
              (Map<String, dynamic> item) => RestrictedAccountModel.fromApiJson(
                item,
                status: status,
              ),
            )
            .where((RestrictedAccountModel item) => item.id.isNotEmpty)
            .toList(growable: false);
      }
    } catch (_) {}

    return null;
  }
}
