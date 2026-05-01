import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/session_item_model.dart';
import '../service/activity_sessions_service.dart';

class ActivitySessionsRepository {
  ActivitySessionsRepository({ActivitySessionsService? service})
    : _service = service ?? ActivitySessionsService();

  final ActivitySessionsService _service;

  Future<List<SessionItemModel>> loadSessions() async {
    return _loadSessionsFromApi();
  }

  Future<List<String>> loadLoginHistory() async {
    return _loadHistoryFromApi();
  }

  Future<bool> logoutOtherDevices() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .postEndpoint('logout_others');
      return response.isSuccess && response.data['success'] != false;
    } catch (_) {
      return false;
    }
  }

  Future<List<SessionItemModel>> _loadSessionsFromApi() async {
    for (final String key in <String>['activity_sessions', 'security_state']) {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .getEndpoint(key);
      if (!response.isSuccess || response.data['success'] == false) {
        continue;
      }
      final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
        response.data,
        preferredKeys: const <String>['sessions', 'items'],
      );
      if (items.isNotEmpty || response.data.isNotEmpty) {
        return items
            .map(SessionItemModel.fromApiJson)
            .where((SessionItemModel item) => item.id.isNotEmpty)
            .toList(growable: false);
      }
    }
    return const <SessionItemModel>[];
  }

  Future<List<String>> _loadHistoryFromApi() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('history');
    if (!response.isSuccess || response.data['success'] == false) {
      return const <String>[];
    }

    final Object? raw =
        response.data['history'] ??
        response.data['data'] ??
        response.data['items'];
    if (raw is List) {
      final List<String> history = raw
          .map<String>((Object? item) {
            if (item is Map) {
              return ApiPayloadReader.readString(
                item['message'] ?? item['title'] ?? item['description'],
              );
            }
            return item?.toString().trim() ?? '';
          })
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
      if (history.isNotEmpty) {
        return history;
      }
    }
    return const <String>[];
  }
}
