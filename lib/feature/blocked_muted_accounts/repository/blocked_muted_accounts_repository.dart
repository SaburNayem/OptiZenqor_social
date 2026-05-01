import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/restricted_account_model.dart';
import '../service/blocked_muted_accounts_service.dart';

class BlockedMutedAccountsRepository {
  BlockedMutedAccountsRepository({BlockedMutedAccountsService? service})
    : _service = service ?? BlockedMutedAccountsService();

  final BlockedMutedAccountsService _service;

  Future<List<RestrictedAccountModel>> loadBlocked() async {
    return _loadFromApi(
      status: 'blocked',
      preferredKeys: const <String>['blocked', 'blockedAccounts', 'users'],
    );
  }

  Future<List<RestrictedAccountModel>> loadMuted() async {
    return _loadFromApi(
      status: 'muted',
      preferredKeys: const <String>['muted', 'mutedAccounts', 'users'],
    );
  }

  Future<bool> unblockAccount(String id) async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .apiClient
          .delete(_service.endpoints['block_user']!.replaceFirst(':id', id));
      return response.isSuccess && response.data['success'] != false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unmuteAccount(String id) async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .apiClient
          .patch(
            ApiEndPoints.blockedMutedAccountUnmute(id),
            const <String, dynamic>{},
          );
      return response.isSuccess && response.data['success'] != false;
    } catch (_) {
      return false;
    }
  }

  Future<List<RestrictedAccountModel>> _loadFromApi({
    required String status,
    required List<String> preferredKeys,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('blocked_muted_accounts');
    if (!response.isSuccess || response.data['success'] == false) {
      return const <RestrictedAccountModel>[];
    }
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      response.data,
      preferredKeys: preferredKeys,
    );
    if (items.isNotEmpty || response.data.isNotEmpty) {
      return items
          .map(
            (Map<String, dynamic> item) => RestrictedAccountModel.fromApiJson(
              ApiPayloadReader.readMap(item['user']) ?? item,
              status: status,
            ),
          )
          .where((RestrictedAccountModel item) => item.id.isNotEmpty)
          .toList(growable: false);
    }
    return const <RestrictedAccountModel>[];
  }
}
