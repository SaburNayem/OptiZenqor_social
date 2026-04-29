import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/saved_collection_model.dart';
import '../service/saved_collections_service.dart';

class SavedCollectionsRepository {
  SavedCollectionsRepository({SavedCollectionsService? service})
    : _service = service ?? SavedCollectionsService();

  final SavedCollectionsService _service;

  Future<List<SavedCollectionModel>> read() async {
    return _readFromApi();
  }

  Future<List<SavedCollectionModel>> write(List<SavedCollectionModel> items) async {
    final ServiceResponseModel<Map<String, dynamic>> response =
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
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to update saved collections.');
    }
    return _readCollectionsFromPayload(response.data);
  }

  Future<List<SavedCollectionModel>> _readFromApi() async {
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _service.getEndpoint('collections');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load saved collections.');
    }
    return _readCollectionsFromPayload(response.data);
  }

  List<SavedCollectionModel> _readCollectionsFromPayload(
    Map<String, dynamic> response,
  ) {
    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response['data']) ?? response;

    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      payload,
      preferredKeys: const <String>['collections', 'items'],
    );
    if (items.isNotEmpty) {
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

    final Map<String, dynamic>? singleItem = ApiPayloadReader.readMap(
      payload['collection'] ?? payload['item'],
    );
    if (singleItem != null && singleItem.isNotEmpty) {
      final SavedCollectionModel item = SavedCollectionModel(
        id: ApiPayloadReader.readString(singleItem['id']),
        name: ApiPayloadReader.readString(singleItem['name']),
        itemIds: ApiPayloadReader.readStringList(
          singleItem['itemIds'] ?? singleItem['items'],
        ),
      );
      if (item.id.isNotEmpty && item.name.isNotEmpty) {
        return <SavedCollectionModel>[item];
      }
    }
    return const <SavedCollectionModel>[];
  }
}
