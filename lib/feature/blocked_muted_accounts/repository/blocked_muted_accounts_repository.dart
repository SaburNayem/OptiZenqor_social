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
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .delete(_service.endpoints['block_user']!.replaceFirst(':id', id));
    if (!response.isSuccess || response.data['success'] == false) {
      throw StateError(
        response.message ?? 'Unable to unblock this account right now.',
      );
    }
    return true;
  }

  Future<bool> unmuteAccount(String id) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(
          ApiEndPoints.blockedMutedAccountUnmute(id),
          const <String, dynamic>{},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw StateError(
        response.message ?? 'Unable to unmute this account right now.',
      );
    }
    return true;
  }

  Future<List<RestrictedAccountModel>> _loadFromApi({
    required String status,
    required List<String> preferredKeys,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('blocked_muted_accounts');
    if (!response.isSuccess || response.data['success'] == false) {
      throw StateError(
        response.message ?? 'Unable to load restricted accounts right now.',
      );
    }
    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage:
          'Restricted accounts response did not include a data payload.',
    );
    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      data,
      preferredKeys: preferredKeys,
    );
    if (items.isEmpty) {
      throw StateError(
        'Restricted accounts response did not include ${preferredKeys.first}.',
      );
    }
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
}
