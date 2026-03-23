import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../model/bookmark_item_model.dart';

class BookmarksRepository {
  BookmarksRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  Future<List<BookmarkItemModel>> read() async {
    final items = await _storage.readJsonList(StorageKeys.bookmarks);
    return items
        .map(
          (item) => BookmarkItemModel(
            id: item['id'] as String? ?? '',
            title: item['title'] as String? ?? '',
            type: _typeFromString(item['type'] as String?),
          ),
        )
        .where((item) => item.id.isNotEmpty && item.title.isNotEmpty)
        .toList();
  }

  Future<void> write(List<BookmarkItemModel> items) {
    return _storage.writeJsonList(
      StorageKeys.bookmarks,
      items
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'title': item.title,
              'type': item.type.name,
            },
          )
          .toList(),
    );
  }

  BookmarkType _typeFromString(String? value) {
    return BookmarkType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => BookmarkType.post,
    );
  }
}
