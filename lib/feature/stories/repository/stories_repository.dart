import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service/upload_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../../../core/utils/app_id.dart';
import '../../auth/repository/auth_repository.dart';
import '../service/stories_service.dart';

class StoriesRepository {
  StoriesRepository({
    StoriesService? service,
    UploadService? uploadService,
    AuthRepository? authRepository,
  }) : _service = service ?? StoriesService(),
       _uploadService = uploadService ?? UploadService(),
       _authRepository = authRepository ?? AuthRepository();

  final StoriesService _service;
  final UploadService _uploadService;
  final AuthRepository _authRepository;

  Future<UserModel?> currentUser() => _authRepository.currentUser();

  Future<List<StoryModel>> createStories(List<StoryModel> drafts) async {
    final List<StoryModel> created = <StoryModel>[];
    for (final StoryModel draft in drafts) {
      created.add(await createStory(draft));
    }
    return created;
  }

  Future<StoryModel> createStory(StoryModel draft) async {
    final UserModel? currentUser = await _authRepository.currentUser();
    if (currentUser == null || currentUser.id.trim().isEmpty) {
      throw Exception('You need to be logged in to create a story.');
    }

    final List<String> sourceMedia = draft.mediaItems.isNotEmpty
        ? draft.mediaItems
        : (draft.media.trim().isNotEmpty ? <String>[draft.media] : <String>[]);
    final List<String> remoteMedia = await _uploadStoryMedia(
      mediaPaths: sourceMedia,
      authorId: currentUser.id,
    );

    final Map<String, dynamic> payload = <String, dynamic>{
      'media': remoteMedia.isEmpty ? '' : remoteMedia.first,
      'mediaItems': remoteMedia,
      'isLocalFile': false,
      if ((draft.text ?? '').trim().isNotEmpty) 'text': draft.text!.trim(),
      if ((draft.music ?? '').trim().isNotEmpty) 'music': draft.music!.trim(),
      if (draft.backgroundColors.isNotEmpty)
        'backgroundColors': draft.backgroundColors,
      'textColorValue': draft.textColorValue,
      if ((draft.sticker ?? '').trim().isNotEmpty)
        'sticker': draft.sticker!.trim(),
      if ((draft.effectName ?? '').trim().isNotEmpty)
        'effectName': draft.effectName!.trim(),
      if ((draft.mentionUsername ?? '').trim().isNotEmpty)
        'mentionUsername': draft.mentionUsername!.trim(),
      if ((draft.linkLabel ?? '').trim().isNotEmpty)
        'linkLabel': draft.linkLabel!.trim(),
      if ((draft.linkUrl ?? '').trim().isNotEmpty)
        'linkUrl': draft.linkUrl!.trim(),
      'privacy': draft.apiPrivacy,
      'collageLayout': draft.collageLayout,
      'textOffsetDx': draft.textOffsetDx,
      'textOffsetDy': draft.textOffsetDy,
      'textScale': draft.textScale,
      'mediaTransforms': draft.mediaTransforms
          .map((StoryMediaTransform item) => item.toJson())
          .toList(growable: false),
    };

    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(_service.endpoints['stories']!, payload);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to create story right now.');
    }

    final Map<String, dynamic>? storyPayload = _extractStoryPayload(
      response.data,
    );
    if (storyPayload == null) {
      throw Exception(
        'Story created but the API did not return a story object.',
      );
    }

    StoryModel created = StoryModel.fromJson(storyPayload);
    if (created.id.trim().isEmpty) {
      throw Exception('Story created but the returned story id was missing.');
    }

    created = created.copyWith(
      userId: created.userId.trim().isEmpty ? currentUser.id : created.userId,
      media: created.media.trim().isEmpty && remoteMedia.isNotEmpty
          ? remoteMedia.first
          : created.media,
      mediaItems: created.mediaItems.isEmpty ? remoteMedia : created.mediaItems,
      isLocalFile: false,
      author: created.author ?? currentUser,
      createdAt: created.createdAt ?? DateTime.now(),
    );
    return created;
  }

  Future<void> markStoryViewed(String storyId) async {
    if (storyId.trim().isEmpty) {
      return;
    }

    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(ApiEndPoints.storyView(storyId), const <String, dynamic>{});
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to mark story as viewed.');
    }
  }

  Future<List<UserModel>> fetchStoryViewers(String storyId) async {
    if (storyId.trim().isEmpty) {
      return const <UserModel>[];
    }

    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get(ApiEndPoints.storyViewers(storyId));
    if (!response.isSuccess || response.data['success'] == false) {
      return const <UserModel>[];
    }

    return _readMapList(response.data)
        .map(UserModel.fromApiJson)
        .where((UserModel user) => user.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> setStoryReaction({
    required String storyId,
    required bool liked,
  }) async {
    if (storyId.trim().isEmpty) {
      return;
    }

    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(ApiEndPoints.storyReactions(storyId), <String, dynamic>{
          'reaction': 'love',
          'active': liked,
        });
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to update story reaction.');
    }
  }

  Future<void> deleteStory(String storyId) async {
    if (storyId.trim().isEmpty) {
      return;
    }

    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .delete(ApiEndPoints.storyById(storyId));
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to delete story right now.');
    }
  }

  Future<List<String>> _uploadStoryMedia({
    required List<String> mediaPaths,
    required String authorId,
  }) async {
    if (mediaPaths.isEmpty) {
      return const <String>[];
    }

    final List<String> uploaded = <String>[];
    for (final String rawPath in mediaPaths) {
      final String localPath = rawPath.trim();
      if (localPath.isEmpty) {
        continue;
      }
      if (localPath.startsWith('http://') || localPath.startsWith('https://')) {
        uploaded.add(localPath);
        continue;
      }

      final String taskId = AppId.makeLocal(
        'upload',
        sequence: uploaded.length,
      );
      UploadProgress? lastProgress;
      await for (final UploadProgress progress in _uploadService.uploadFile(
        taskId: taskId,
        localPath: localPath,
        fields: <String, String>{
          'resourceType': _resourceTypeFor(localPath),
          'folder': 'optizenqor/stories/$authorId',
          'publicId': taskId,
        },
      )) {
        lastProgress = progress;
      }

      if (lastProgress == null ||
          lastProgress.status != UploadStatus.completed ||
          lastProgress.remotePath == null ||
          lastProgress.remotePath!.trim().isEmpty) {
        throw Exception(lastProgress?.error ?? 'Story media upload failed.');
      }
      uploaded.add(lastProgress.remotePath!.trim());
    }
    return uploaded;
  }

  String _resourceTypeFor(String path) {
    final String lower = path.toLowerCase();
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm')) {
      return 'video';
    }
    return 'image';
  }

  Map<String, dynamic>? _extractStoryPayload(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>?> candidates = <Map<String, dynamic>?>[
      _looksLikeStory(payload) ? payload : null,
      _readMap(payload['story']),
      _readMap(payload['data']),
      _readMap(payload['result']),
    ];

    for (final Map<String, dynamic>? candidate in candidates) {
      if (candidate == null || candidate.isEmpty) {
        continue;
      }
      if (_looksLikeStory(candidate)) {
        return candidate;
      }
      final Map<String, dynamic>? nestedStory = _readMap(candidate['story']);
      if (nestedStory != null && _looksLikeStory(nestedStory)) {
        return nestedStory;
      }
    }
    return null;
  }

  bool _looksLikeStory(Map<String, dynamic> payload) {
    return (payload.containsKey('id') || payload.containsKey('_id')) &&
        (payload.containsKey('media') ||
            payload.containsKey('mediaItems') ||
            payload.containsKey('text') ||
            payload.containsKey('userId') ||
            payload.containsKey('author'));
  }

  List<Map<String, dynamic>> _readMapList(Map<String, dynamic> payload) {
    for (final Object? raw in <Object?>[
      payload['data'],
      payload['items'],
      payload['results'],
      _readMap(payload['data'])?['items'],
      _readMap(payload['data'])?['results'],
      _readMap(payload['data'])?['viewers'],
    ]) {
      if (raw is! List) {
        continue;
      }
      return raw
          .whereType<Object>()
          .map((Object item) => _readMap(item) ?? const <String, dynamic>{})
          .where((Map<String, dynamic> item) => item.isNotEmpty)
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
