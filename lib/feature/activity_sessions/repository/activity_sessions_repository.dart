import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../model/session_item_model.dart';

class ActivitySessionsRepository {
  ActivitySessionsRepository({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

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
    final raw = await _storage.readJsonList(StorageKeys.activeSessions);
    if (raw.isEmpty) {
      await saveSessions(_seedSessions);
      return _seedSessions;
    }
    return raw.map(SessionItemModel.fromJson).toList();
  }

  Future<List<String>> loadLoginHistory() async {
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
}
