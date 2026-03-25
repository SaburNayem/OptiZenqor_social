import '../../../core/constants/storage_keys.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../model/saved_collection_model.dart';

class SavedCollectionsRepository {
  SavedCollectionsRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  Future<List<SavedCollectionModel>> read() async {
    final items = await _storage.readJsonList(StorageKeys.savedCollections);
    return items
        .map(
          (item) => SavedCollectionModel(
            id: item['id'] as String? ?? '',
            name: item['name'] as String? ?? '',
            itemIds: (item['itemIds'] as List<dynamic>? ?? <dynamic>[])
                .map((id) => id.toString())
                .toList(),
          ),
        )
        .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
        .toList();
  }

  Future<void> write(List<SavedCollectionModel> items) {
    return _storage.writeJsonList(
      StorageKeys.savedCollections,
      items
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'name': item.name,
              'itemIds': item.itemIds,
            },
          )
          .toList(),
    );
  }
}
