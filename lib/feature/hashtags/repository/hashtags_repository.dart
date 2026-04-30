import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/hashtag_model.dart';
import '../service/hashtags_service.dart';

class HashtagsRepository {
  HashtagsRepository({HashtagsService? service})
    : _service = service ?? HashtagsService();

  final HashtagsService _service;

  Future<List<HashtagModel>> trending() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('hashtags');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(
        response.data['message']?.toString() ?? 'Unable to load hashtags.',
      );
    }

    return ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['items', 'results', 'data', 'hashtags'],
        )
        .map(HashtagModel.fromApiJson)
        .where((HashtagModel item) => item.tag.isNotEmpty)
        .toList(growable: false);
  }
}
