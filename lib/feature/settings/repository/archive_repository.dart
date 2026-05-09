import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/reel_model.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/data/service/api_client_service.dart';

class ArchiveRepository {
  ArchiveRepository({ApiClientService? apiClient})
    : _apiClient = apiClient ?? ApiClientService();

  final ApiClientService _apiClient;

  Future<List<PostModel>> archivedPosts() async {
    return _fetchList(ApiEndPoints.archivePosts, PostModel.fromApiJson);
  }

  Future<List<StoryModel>> archivedStories() async {
    return _fetchList(ApiEndPoints.archiveStories, StoryModel.fromJson);
  }

  Future<List<ReelModel>> archivedReels() async {
    return _fetchList(ApiEndPoints.archiveReels, ReelModel.fromApiJson);
  }

  Future<List<T>> _fetchList<T>(
    String endpoint,
    T Function(Map<String, dynamic>) parser,
  ) async {
    final response = await _apiClient.get(endpoint);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(
        response.data['message']?.toString() ?? 'Unable to load archive data.',
      );
    }
    return _readMapList(
      response.data,
    ).map(parser).where((T item) => true).toList(growable: false);
  }

  List<Map<String, dynamic>> _readMapList(Map<String, dynamic> payload) {
    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      payload,
      fallbackMessage: 'Archive response did not include a data payload.',
    );
    return ApiPayloadReader.readMapList(data);
  }
}
