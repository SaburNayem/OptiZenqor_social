import 'dart:async';

import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/saved_collection_model.dart';
import '../service/saved_collections_service.dart';

class SavedCollectionsRepository {
  SavedCollectionsRepository({
    LocalStorageService? storage,
    SavedCollectionsService? service,
  }) : _storage = storage ?? LocalStorageService(),
       _service = service ?? SavedCollectionsService();

  final LocalStorageService _storage;
  final SavedCollectionsService _service;

  Future<List<SavedCollectionModel>> read() async {
    final List<SavedCollectionModel>? remoteCollections = await _readFromApi();
    if (remoteCollections != null) {
      await _writeLocal(remoteCollections);
      return remoteCollections;
    }

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
    unawaited(_syncRemote(items));
    return _writeLocal(items);
  }

  Future<void> _writeLocal(List<SavedCollectionModel> items) {
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

  Future<List<SavedCollectionModel>?> _readFromApi() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.getEndpoint('collections');
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
      }

      final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
        response.data,
        preferredKeys: const <String>['collections', 'items'],
      );
      if (items.isNotEmpty || response.data.isNotEmpty) {
        return items
            .map(
              (Map<String, dynamic> item) => SavedCollectionModel(
                id: ApiPayloadReader.readString(item['id']),
                name: ApiPayloadReader.readString(item['name']),
                itemIds: ApiPayloadReader.readStringList(
                  item['itemIds'] ?? item['items'],
                ),
              ),
            )
            .where(
              (SavedCollectionModel item) =>
                  item.id.isNotEmpty && item.name.isNotEmpty,
            )
            .toList(growable: false);
      }
    } catch (_) {}

    return null;
  }

  Future<void> _syncRemote(List<SavedCollectionModel> items) async {
    try {
      await _service.postEndpoint(
        'collections',
        payload: <String, dynamic>{
          'items': items
              .map(
                (SavedCollectionModel item) => <String, dynamic>{
                  'id': item.id,
                  'name': item.name,
                  'itemIds': item.itemIds,
                },
              )
              .toList(growable: false),
        },
      );
    } catch (_) {}
  }
}
