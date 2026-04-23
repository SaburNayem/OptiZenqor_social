import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/session_item_model.dart';
import '../service/activity_sessions_service.dart';

class ActivitySessionsRepository {
  ActivitySessionsRepository({
    LocalStorageService? storage,
    ActivitySessionsService? service,
  }) : _storage = storage ?? LocalStorageService(),
       _service = service ?? ActivitySessionsService();

  final LocalStorageService _storage;
  final ActivitySessionsService _service;

  static const List<SessionItemModel> _seedSessions = <SessionItemModel>[
    SessionItemModel(
      id: 's1',
      device: 'Pixel Emulator',
      location: 'Dhaka, BD',
      platform: 'Android',
      lastActive: 'Active now',
      active: true,
      isCurrent: true,
    ),
    SessionItemModel(
      id: 's2',
      device: 'MacBook Pro',
      location: 'Dhaka, BD',
      platform: 'Web',
      lastActive: '2 hours ago',
      active: true,
    ),
    SessionItemModel(
      id: 's3',
      device: 'iPhone 15 Pro',
      location: 'Singapore',
      platform: 'iOS',
      lastActive: 'Yesterday',
      active: false,
    ),
  ];

  static const List<String> _seedHistory = <String>[
    'Login success from Pixel Emulator',
    'Password changed from MacBook Pro',
    'New device approved: iPhone 15 Pro',
  ];

  Future<List<SessionItemModel>> loadSessions() async {
    final List<SessionItemModel>? remoteSessions = await _loadSessionsFromApi();
    if (remoteSessions != null) {
      await saveSessions(remoteSessions);
      return remoteSessions;
    }

    final raw = await _storage.readJsonList(StorageKeys.activeSessions);
    if (raw.isEmpty) {
      await saveSessions(_seedSessions);
      return _seedSessions;
    }
    return raw.map(SessionItemModel.fromJson).toList();
  }

  Future<List<String>> loadLoginHistory() async {
    final List<String>? remoteHistory = await _loadHistoryFromApi();
    if (remoteHistory != null) {
      await _storage.write(StorageKeys.loginHistory, remoteHistory);
      return remoteHistory;
    }

    final history = await _storage.read<List<String>>(StorageKeys.loginHistory);
    if (history == null || history.isEmpty) {
      await _storage.write(StorageKeys.loginHistory, _seedHistory);
      return _seedHistory;
    }
    return history;
  }

  Future<void> saveSessions(List<SessionItemModel> sessions) {
    return _storage.writeJsonList(
      StorageKeys.activeSessions,
      sessions.map((item) => item.toJson()).toList(),
    );
  }

  Future<bool> logoutOtherDevices() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.postEndpoint('logout_others');
      return response.isSuccess && response.data['success'] != false;
    } catch (_) {
      return false;
    }
  }

  Future<List<SessionItemModel>?> _loadSessionsFromApi() async {
    for (final String key in <String>['activity_sessions', 'security_state']) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
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
      } catch (_) {}
    }
    return null;
  }

  Future<List<String>?> _loadHistoryFromApi() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.getEndpoint('history');
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
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
        return history;
      }
    } catch (_) {}
    return null;
  }
}
