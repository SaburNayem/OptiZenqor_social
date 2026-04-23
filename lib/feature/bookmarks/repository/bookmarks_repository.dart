import 'dart:async';

import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/shared_preference/app_shared_preferences.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/bookmark_item_model.dart';
import '../service/bookmarks_service.dart';

class BookmarksRepository {
  BookmarksRepository({
    AppSharedPreferences? storage,
    BookmarksService? service,
  }) : _storage = storage ?? AppSharedPreferences(),
       _service = service ?? BookmarksService();

  final AppSharedPreferences _storage;
  final BookmarksService _service;

  Future<List<BookmarkItemModel>> read() async {
    final List<BookmarkItemModel>? remoteItems = await _readFromApi();
    if (remoteItems != null) {
      await _writeLocal(remoteItems);
      return remoteItems;
    }

    final items = await _storage.readJsonList(StorageKeys.bookmarks);
    return items
        .map(
          (item) => _mapItem(item),
        )
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  Future<void> write(List<BookmarkItemModel> items) {
    unawaited(_syncRemote(items));
    return _writeLocal(items);
  }

  Future<void> add(BookmarkItemModel item, List<BookmarkItemModel> items) async {
    try {
      await _service.apiClient.post(
        ApiEndPoints.bookmarkPost(item.id),
        const <String, dynamic>{},
      );
    } catch (_) {}
    await write(items);
  }

  Future<void> remove(String itemId, List<BookmarkItemModel> items) async {
    try {
      await _service.apiClient.delete(ApiEndPoints.bookmarkPost(itemId));
    } catch (_) {}
    await write(items);
  }

  Future<void> _writeLocal(List<BookmarkItemModel> items) {
    return _storage.writeJsonList(
      StorageKeys.bookmarks,
      items
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'title': item.title,
              'type': item.type.name,
              'authorId': item.authorId,
              'authorName': item.authorName,
              'authorAvatar': item.authorAvatar,
              'caption': item.caption,
              'thumbnail': item.thumbnail,
              'savedAt': item.savedAt.toIso8601String(),
              'isVideo': item.isVideo,
            },
          )
          .toList(),
    );
  }

  BookmarkItemModel _mapItem(Map<String, dynamic> item) {
    final String id = item['id'] as String? ?? '';
    final String title = item['title'] as String? ?? '';
    final String caption = item['caption'] as String? ?? title;
    final DateTime savedAt =
        DateTime.tryParse(item['savedAt'] as String? ?? '') ?? DateTime.now();
    final BookmarkItemModel fallback = _legacyFallbackItem(
      id: id,
      title: title,
      type: _typeFromString(item['type'] as String?),
      savedAt: savedAt,
    );

    return BookmarkItemModel(
      id: id,
      title: title.isEmpty ? fallback.title : title,
      type: _typeFromString(item['type'] as String?),
      authorId: item['authorId'] as String? ?? fallback.authorId,
      authorName: item['authorName'] as String? ?? fallback.authorName,
      authorAvatar: item['authorAvatar'] as String? ?? fallback.authorAvatar,
      caption: caption.isEmpty ? fallback.caption : caption,
      thumbnail: item['thumbnail'] as String? ?? fallback.thumbnail,
      savedAt: savedAt,
      isVideo: item['isVideo'] as bool? ?? fallback.isVideo,
    );
  }

  BookmarkItemModel _legacyFallbackItem({
    required String id,
    required String title,
    required BookmarkType type,
    required DateTime savedAt,
  }) {
    final post = MockData.posts.where((item) => item.id == id).firstOrNull;
    final author = post == null
        ? null
        : MockData.users.where((item) => item.id == post.authorId).firstOrNull;

    return BookmarkItemModel(
      id: id,
      title: title.isEmpty ? post?.caption ?? 'Saved post' : title,
      type: type,
      authorId: author?.id ?? '',
      authorName: author?.name ?? 'Unknown creator',
      authorAvatar: author?.avatar ?? '',
      caption: post?.caption ?? title,
      thumbnail: post?.media.isEmpty ?? true ? '' : post!.media.first,
      savedAt: savedAt,
      isVideo: _isVideoPath(post?.media.isEmpty ?? true ? '' : post!.media.first),
    );
  }

  bool _isVideoPath(String value) {
    final String lower = value.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm');
  }

  BookmarkType _typeFromString(String? value) {
    return BookmarkType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => BookmarkType.post,
    );
  }

  Future<List<BookmarkItemModel>?> _readFromApi() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.getEndpoint('bookmarks');
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
      }
      final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
        response.data,
        preferredKeys: const <String>['bookmarks', 'items'],
      );
      if (items.isNotEmpty || response.data.isNotEmpty) {
        return items
            .map(BookmarkItemModel.fromApiJson)
            .where((BookmarkItemModel item) => item.id.isNotEmpty)
            .toList(growable: false);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _syncRemote(List<BookmarkItemModel> items) async {
    try {
      await _service.postEndpoint(
        'bookmarks',
        payload: <String, dynamic>{
          'items': items
              .map(
                (BookmarkItemModel item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'type': item.type.name,
                  'authorId': item.authorId,
                  'authorName': item.authorName,
                  'authorAvatar': item.authorAvatar,
                  'caption': item.caption,
                  'thumbnail': item.thumbnail,
                  'savedAt': item.savedAt.toIso8601String(),
                  'isVideo': item.isVideo,
                },
              )
              .toList(growable: false),
        },
      );
    } catch (_) {}
  }
}
