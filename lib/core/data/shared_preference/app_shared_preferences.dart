import '../service/local_storage_service.dart';

class AppSharedPreferences {
  AppSharedPreferences({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  Future<T?> read<T>(String key) => _storage.read<T>(key);

  Future<void> write(String key, dynamic value) => _storage.write(key, value);

  Future<Map<String, dynamic>?> readJson(String key) => _storage.readJson(key);

  Future<List<Map<String, dynamic>>> readJsonList(String key) =>
      _storage.readJsonList(key);

  Future<void> writeJson(String key, Map<String, dynamic> value) =>
      _storage.writeJson(key, value);

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> value) =>
      _storage.writeJsonList(key, value);

  Future<void> remove(String key) => _storage.remove(key);
}
