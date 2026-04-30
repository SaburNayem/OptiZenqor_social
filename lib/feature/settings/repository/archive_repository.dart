import '../../../core/data/api/api_end_points.dart';
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
    for (final Object? raw in <Object?>[
      payload['data'],
      payload['items'],
      payload['results'],
      _readMap(payload['data'])?['items'],
      _readMap(payload['data'])?['results'],
    ]) {
      if (raw is! List) {
        continue;
      }
      return raw
          .whereType<Object>()
          .map(
            (Object item) => item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item as Map),
          )
          .toList(growable: false);
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
