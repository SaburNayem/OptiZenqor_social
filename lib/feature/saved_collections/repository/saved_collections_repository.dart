import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/saved_collection_model.dart';
import '../service/saved_collections_service.dart';

class SavedCollectionsRepository {
  SavedCollectionsRepository({SavedCollectionsService? service})
    : _service = service ?? SavedCollectionsService();

  final SavedCollectionsService _service;

  Future<List<SavedCollectionModel>> read() async {
    try {
      return await _readFromApi();
    } catch (_) {
      return const <SavedCollectionModel>[];
    }
  }

  Future<List<SavedCollectionModel>> create(String name) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .postEndpoint(
          'collections',
          payload: <String, dynamic>{'name': name.trim()},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(
        response.message ?? 'Unable to create a saved collection.',
      );
    }
    return _readCollectionsFromPayload(response.data);
  }

  Future<SavedCollectionModel?> addItem(
    String collectionId,
    String itemId,
  ) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch('/saved-collections', <String, dynamic>{
          'collectionId': collectionId,
          'itemId': itemId,
        });
    if (!response.isSuccess || response.data['success'] == false) {
      return null;
    }
    return _readSingleCollection(response.data);
  }

  Future<SavedCollectionModel?> updateItems(
    String collectionId,
    List<String> itemIds,
  ) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch('/saved-collections/$collectionId', <String, dynamic>{
          'itemIds': itemIds,
        });
    if (!response.isSuccess || response.data['success'] == false) {
      return null;
    }
    return _readSingleCollection(response.data);
  }

  Future<List<SavedCollectionModel>> _readFromApi() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('collections');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load saved collections.');
    }
    return _readCollectionsFromPayload(response.data);
  }

  List<SavedCollectionModel> _readCollectionsFromPayload(
    Map<String, dynamic> response,
  ) {
    final Map<String, dynamic> payload = ApiPayloadReader.requireDataMap(
      response,
      fallbackMessage:
          'Saved collections response did not include a data payload.',
    );

    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['collections'],
    );
    if (items.isNotEmpty) {
      return items
          .map(
            (Map<String, dynamic> item) => SavedCollectionModel(
              id: ApiPayloadReader.readString(item['id']),
              name: ApiPayloadReader.readString(item['name']),
              itemIds: ApiPayloadReader.readStringList(item['itemIds']),
            ),
          )
          .where(
            (SavedCollectionModel item) =>
                item.id.isNotEmpty && item.name.isNotEmpty,
          )
          .toList(growable: false);
    }

    final Map<String, dynamic>? singleItem = ApiPayloadReader.readMap(
      payload['collection'] ?? payload['item'],
    );
    if (singleItem != null && singleItem.isNotEmpty) {
      final SavedCollectionModel item = SavedCollectionModel(
        id: ApiPayloadReader.readString(singleItem['id']),
        name: ApiPayloadReader.readString(singleItem['name']),
        itemIds: ApiPayloadReader.readStringList(singleItem['itemIds']),
      );
      if (item.id.isNotEmpty && item.name.isNotEmpty) {
        return <SavedCollectionModel>[item];
      }
    }
    return const <SavedCollectionModel>[];
  }

  SavedCollectionModel? _readSingleCollection(Map<String, dynamic> response) {
    final Map<String, dynamic>? data = ApiPayloadReader.readDataMap(response);
    final Map<String, dynamic>? item = ApiPayloadReader.readMap(
      data?['collection'] ?? data?['item'] ?? data,
    );
    if (item == null || item.isEmpty) {
      return null;
    }
    final SavedCollectionModel collection = SavedCollectionModel(
      id: ApiPayloadReader.readString(item['id']),
      name: ApiPayloadReader.readString(item['name']),
      itemIds: ApiPayloadReader.readStringList(item['itemIds']),
    );
    return collection.id.isNotEmpty ? collection : null;
  }
}
