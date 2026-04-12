import '../../../core/constants/storage_keys.dart';
import '../../../core/data/service/local_storage_service.dart';

class PostsRepository {
  PostsRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  Future<void> saveDraft(Map<String, dynamic> draft) async {
    final all = await _storage.readJsonList(StorageKeys.draftPosts);
    all.removeWhere((item) => item['id'] == draft['id']);
    all.insert(0, draft);
    await _storage.writeJsonList(StorageKeys.draftPosts, all);
  }

  Future<List<Map<String, dynamic>>> getDrafts() {
    return _storage.readJsonList(StorageKeys.draftPosts);
  }

  Future<void> deleteDraft(String id) async {
    final all = await _storage.readJsonList(StorageKeys.draftPosts);
    all.removeWhere((item) => item['id'] == id);
    await _storage.writeJsonList(StorageKeys.draftPosts, all);
  }
}
