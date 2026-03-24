import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';

class SettingsPreferencesRepository {
  SettingsPreferencesRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  Future<Map<String, dynamic>> readAll() async {
    final data = await _storage.readJson(StorageKeys.settingsState);
    return data ?? <String, dynamic>{};
  }

  Future<void> writeAll(Map<String, dynamic> value) async {
    await _storage.writeJson(StorageKeys.settingsState, value);
  }

  Future<bool> readBool(String key, {bool fallback = false}) async {
    final data = await readAll();
    final value = data[key];
    if (value is bool) {
      return value;
    }
    return fallback;
  }

  Future<String> readString(String key, {String fallback = ''}) async {
    final data = await readAll();
    final value = data[key];
    if (value is String) {
      return value;
    }
    return fallback;
  }
}
