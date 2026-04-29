import '../../../core/data/api/api_end_points.dart';
import '../../../core/config/app_config.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service/upload_service.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/data/shared_preference/app_shared_preferences.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../service/home_feed_service.dart';

enum FeedSegment { forYou, following, trending }

class HomeFeedRepository {
  HomeFeedRepository({
    AppSharedPreferences? storage,
    HomeFeedService? service,
    UploadService? uploadService,
  }) : _storage = storage ?? AppSharedPreferences(),
       _service = service ?? HomeFeedService(),
       _uploadService = uploadService ?? UploadService();

  final AppSharedPreferences _storage;
  final HomeFeedService _service;
  final UploadService _uploadService;
  static final Map<String, UserModel> _authorCache = <String, UserModel>{};

  Future<List<PostModel>> fetchFeed({
    required FeedSegment segment,
    required int page,
  }) async {
    if (page > 1) {
      return <PostModel>[];
    }

    final List<PostModel> localPosts = AppConfig.useRemoteOnly
        ? const <PostModel>[]
        : await readLocalCreatedPosts();

    try {
      final response = await _service.apiClient.get(_feedEndpointFor(segment));
      final List<Map<String, dynamic>> items = _readMapList(response.data);
      if (response.isSuccess && items.isNotEmpty) {
        final List<PostModel> parsedPosts = items
            .map(PostModel.fromApiJson)
            .toList(growable: false);
        final List<PostModel> posts = await _hydratePostAuthors(parsedPosts);
        if (AppConfig.allowOfflineFallback) {
          await _storage.writeJsonList(
            StorageKeys.cachedFeed,
            posts.map((PostModel post) => post.toCacheJson()).toList(),
          );
        }
        return AppConfig.useRemoteOnly ? posts : _mergePosts(localPosts, posts);
      }
    } catch (_) {}

    if (AppConfig.allowOfflineFallback) {
      final List<PostModel> cached = await readCachedFeed();
      if (cached.isNotEmpty) {
        return AppConfig.useRemoteOnly
            ? cached
            : _mergePosts(localPosts, cached);
      }
    }

    return AppConfig.useRemoteOnly ? const <PostModel>[] : localPosts;
  }

  Future<List<PostModel>> readCachedFeed() async {
    final cached = await _storage.readJsonList(StorageKeys.cachedFeed);
    if (cached.isEmpty) {
      return <PostModel>[];
    }
    return cached.map(PostModel.fromApiJson).toList(growable: false);
  }

  Future<List<PostModel>> readLocalCreatedPosts() async {
    final List<Map<String, dynamic>> cached = await _storage.readJsonList(
      StorageKeys.localCreatedPosts,
    );
    if (cached.isEmpty) {
      return <PostModel>[];
    }
    return cached
        .map(PostModel.fromApiJson)
        .where((PostModel post) => post.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> saveLocalCreatedPosts(List<PostModel> posts) {
    return _storage.writeJsonList(
      StorageKeys.localCreatedPosts,
      posts.map((PostModel post) => post.toCacheJson()).toList(),
    );
  }

  Future<PostModel> createPost({
    required String caption,
    List<String> mediaPaths = const <String>[],
    bool isVideo = false,
    String audience = 'Everyone',
    String? location,
    List<String> taggedUserIds = const <String>[],
    List<String> mentionUsernames = const <String>[],
    String? altText,
    List<String> editHistory = const <String>[],
  }) async {
    final UserModel? currentUser = await currentUserProfile();
    if (currentUser == null || currentUser.id.trim().isEmpty) {
      throw Exception('You need to be logged in to create a post.');
    }

    final List<String> remoteMedia = await _uploadPostMedia(
      mediaPaths: mediaPaths,
      isVideo: isVideo,
      authorId: currentUser.id,
    );
    final Map<String, dynamic> payload = <String, dynamic>{
      'caption': caption.trim(),
      'media': remoteMedia,
      if (location != null && location.trim().isNotEmpty)
        'location': location.trim(),
      if (taggedUserIds.isNotEmpty) 'taggedUserIds': taggedUserIds,
      if (mentionUsernames.isNotEmpty) 'mentionUsernames': mentionUsernames,
      if (altText != null && altText.trim().isNotEmpty)
        'altText': altText.trim(),
      if (editHistory.isNotEmpty) 'editHistory': editHistory,
    };

    ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(ApiEndPoints.postsCreate, payload);
    if (!response.isSuccess || response.data['success'] == false) {
      response = await _service.apiClient.post(ApiEndPoints.posts, payload);
    }
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to create post right now.');
    }

    final Map<String, dynamic>? postPayload = _extractPostPayload(
      response.data,
    );
    if (postPayload == null) {
      throw Exception('Post created but the API did not return a post object.');
    }

    PostModel created = PostModel.fromApiJson(postPayload);
    if (created.id.isEmpty) {
      throw Exception('Post created but the returned post id was missing.');
    }
    if (created.author == null) {
      created = created.copyWith(author: currentUser);
    }

    return created;
  }

  Future<String> currentUserId() => _currentUserId();

  Future<void> setPostLiked({
    required String postId,
    required bool liked,
  }) async {
    const Map<String, dynamic> payload = <String, dynamic>{};
    final String endpoint = liked
        ? ApiEndPoints.postLike(postId)
        : ApiEndPoints.postUnlike(postId);

    ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(endpoint, payload);
    if (_isSuccessfulMutation(response)) {
      return;
    }

    response = await _service.apiClient.post(endpoint, payload);
    if (_isSuccessfulMutation(response)) {
      return;
    }

    if (!liked) {
      response = await _service.apiClient.delete(
        ApiEndPoints.postLike(postId),
        payload: payload,
      );
      if (_isSuccessfulMutation(response)) {
        return;
      }
    }

    throw Exception(response.message ?? 'Unable to update post like');
  }

  Future<PostModel> updatePost({
    required String postId,
    required String caption,
  }) async {
    final String trimmedCaption = caption.trim();
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch(ApiEndPoints.postById(postId), <String, dynamic>{
          'caption': trimmedCaption,
        });
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to update post right now.');
    }
    final Map<String, dynamic>? postPayload = _extractPostPayload(
      response.data,
    );
    if (postPayload == null) {
      throw Exception('Updated post response did not include a post object.');
    }
    final PostModel updated = PostModel.fromApiJson(postPayload);
    return updated.id.isEmpty
        ? updated.copyWith(caption: trimmedCaption)
        : updated;
  }

  Future<void> deletePost(String postId) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .delete(ApiEndPoints.postById(postId));
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to delete post right now.');
    }
  }

  Future<List<StoryModel>> fetchStories({String? scope}) async {
    final Set<String> seenStoryIds = await readSeenStoryIds();
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .apiClient
          .get(
            ApiEndPoints.stories,
            queryParameters: scope == null || scope.trim().isEmpty
                ? null
                : <String, dynamic>{'scope': scope.trim()},
          );
      if (!response.isSuccess || response.data['success'] == false) {
        return const <StoryModel>[];
      }
      final List<Map<String, dynamic>> items = _readMapList(
        response.data,
        preferredKeys: const <String>['stories', 'data', 'items', 'results'],
      );
      final List<StoryModel> remoteStories = await _hydrateStoryAuthors(
        items
            .map(StoryModel.fromJson)
            .where((StoryModel story) => story.id.isNotEmpty)
            .toList(growable: false),
      );
      return _applySeenState(_sortStories(remoteStories), seenStoryIds);
    } catch (_) {}

    return const <StoryModel>[];
  }

  Future<Set<String>> readSeenStoryIds() async {
    final List<dynamic>? raw = await _storage.read<List<dynamic>>(
      StorageKeys.seenStoryIds,
    );
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }
    return raw
        .map((dynamic item) => item.toString().trim())
        .where((String item) => item.isNotEmpty)
        .toSet();
  }

  Future<void> saveSeenStoryIds(Set<String> storyIds) {
    return _storage.write(
      StorageKeys.seenStoryIds,
      storyIds.toList(growable: false),
    );
  }

  Future<Map<String, List<String>>> readRecommendationPreferences() async {
    final raw = await _storage.readJson(StorageKeys.recommendationPreferences);
    if (raw == null) {
      return <String, List<String>>{
        'lessLikeThis': <String>[],
        'hiddenCreators': <String>[],
        'hiddenTopics': <String>[],
      };
    }
    return <String, List<String>>{
      'lessLikeThis': List<String>.from(
        raw['lessLikeThis'] as List<dynamic>? ?? const <dynamic>[],
      ),
      'hiddenCreators': List<String>.from(
        raw['hiddenCreators'] as List<dynamic>? ?? const <dynamic>[],
      ),
      'hiddenTopics': List<String>.from(
        raw['hiddenTopics'] as List<dynamic>? ?? const <dynamic>[],
      ),
    };
  }

  Future<void> writeRecommendationPreferences(Map<String, List<String>> prefs) {
    return _storage.writeJson(StorageKeys.recommendationPreferences, prefs);
  }

  bool _isSuccessfulMutation(
    ServiceResponseModel<Map<String, dynamic>> response,
  ) {
    if (!response.isSuccess) {
      return false;
    }
    return response.data['success'] != false;
  }

  String _feedEndpointFor(FeedSegment segment) {
    switch (segment) {
      case FeedSegment.forYou:
        return ApiEndPoints.feedHome;
      case FeedSegment.following:
      case FeedSegment.trending:
        return ApiEndPoints.feed;
    }
  }

  List<Map<String, dynamic>> _readMapList(
    Map<String, dynamic> payload, {
    List<String> preferredKeys = const <String>[],
  }) {
    for (final Object? raw in <Object?>[
      ...preferredKeys.map((String key) => payload[key]),
      payload['data'],
      payload['items'],
      payload['results'],
      payload['value'],
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

  Future<String> _currentUserId() async {
    final Map<String, dynamic>? session = await _storage.readJson(
      StorageKeys.authSession,
    );
    final Object? user = session?['user'];
    if (user is Map<String, dynamic>) {
      final String id = (user['id'] as Object? ?? '').toString();
      if (id.isNotEmpty) {
        return id;
      }
    }
    if (user is Map) {
      final String id = (user['id'] as Object? ?? '').toString();
      if (id.isNotEmpty) {
        return id;
      }
    }
    return '';
  }

  Future<UserModel?> currentUserProfile() async {
    final Map<String, dynamic>? session = await _storage.readJson(
      StorageKeys.authSession,
    );
    final Object? user = session?['user'];
    if (user is Map<String, dynamic>) {
      final UserModel resolved = UserModel.fromApiJson(user);
      return resolved.id.isEmpty ? null : resolved;
    }
    if (user is Map) {
      final UserModel resolved = UserModel.fromApiJson(
        Map<String, dynamic>.from(user),
      );
      return resolved.id.isEmpty ? null : resolved;
    }
    return null;
  }

  Future<List<PostModel>> _hydratePostAuthors(List<PostModel> posts) async {
    final Set<String> missingAuthorIds = posts
        .where(
          (PostModel post) => post.author == null && post.authorId.isNotEmpty,
        )
        .map((PostModel post) => post.authorId)
        .toSet();
    if (missingAuthorIds.isEmpty) {
      return posts;
    }

    final Map<String, UserModel> authors = <String, UserModel>{};
    await Future.wait<void>(
      missingAuthorIds.map((String authorId) async {
        final UserModel? cachedAuthor = _authorCache[authorId];
        if (cachedAuthor != null) {
          authors[authorId] = cachedAuthor;
          return;
        }
        final UserModel? currentUser = await currentUserProfile();
        if (currentUser != null && currentUser.id == authorId) {
          _authorCache[authorId] = currentUser;
          authors[authorId] = currentUser;
          return;
        }
        try {
          final ServiceResponseModel<Map<String, dynamic>> response =
              await _service.apiClient.get(ApiEndPoints.userById(authorId));
          if (!response.isSuccess || response.data['success'] == false) {
            return;
          }
          final Map<String, dynamic>? payload = _extractUserPayload(
            response.data,
          );
          if (payload == null) {
            return;
          }
          final UserModel author = UserModel.fromApiJson(payload);
          if (author.id.isNotEmpty) {
            _authorCache[authorId] = author;
            authors[authorId] = author;
          }
        } catch (_) {}
      }),
    );

    return posts
        .map(
          (PostModel post) =>
              post.author != null || !authors.containsKey(post.authorId)
              ? post
              : post.copyWith(author: authors[post.authorId]),
        )
        .toList(growable: false);
  }

  Future<List<StoryModel>> _hydrateStoryAuthors(
    List<StoryModel> stories,
  ) async {
    final Set<String> missingAuthorIds = stories
        .where(
          (StoryModel story) =>
              story.author == null && story.userId.trim().isNotEmpty,
        )
        .map((StoryModel story) => story.userId)
        .toSet();
    if (missingAuthorIds.isEmpty) {
      return stories;
    }

    final Map<String, UserModel> authors = <String, UserModel>{};
    await Future.wait<void>(
      missingAuthorIds.map((String authorId) async {
        final UserModel? cachedAuthor = _authorCache[authorId];
        if (cachedAuthor != null) {
          authors[authorId] = cachedAuthor;
          return;
        }
        try {
          final ServiceResponseModel<Map<String, dynamic>> response =
              await _service.apiClient.get(ApiEndPoints.userById(authorId));
          if (!response.isSuccess || response.data['success'] == false) {
            return;
          }
          final Map<String, dynamic>? payload = _extractUserPayload(
            response.data,
          );
          if (payload == null) {
            return;
          }
          final UserModel author = UserModel.fromApiJson(payload);
          if (author.id.isNotEmpty) {
            _authorCache[authorId] = author;
            authors[authorId] = author;
          }
        } catch (_) {}
      }),
    );

    return stories
        .map(
          (StoryModel story) =>
              story.author != null || !authors.containsKey(story.userId)
              ? story
              : story.copyWith(author: authors[story.userId]),
        )
        .toList(growable: false);
  }

  Map<String, dynamic>? _extractUserPayload(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>?> candidates = <Map<String, dynamic>?>[
      payload,
      _readMap(payload['user']),
      _readMap(payload['data']),
      _readMap(payload['profile']),
      _readMap(payload['result']),
    ];
    for (final Map<String, dynamic>? candidate in candidates) {
      if (candidate == null || candidate.isEmpty) {
        continue;
      }
      if (candidate.containsKey('id') ||
          candidate.containsKey('username') ||
          candidate.containsKey('name')) {
        return candidate;
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractPostPayload(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>?> candidates = <Map<String, dynamic>?>[
      _looksLikePost(payload) ? payload : null,
      _readMap(payload['post']),
      _readMap(payload['data']),
      _readMap(payload['result']),
    ];
    for (final Map<String, dynamic>? candidate in candidates) {
      if (candidate == null || candidate.isEmpty) {
        continue;
      }
      if (_looksLikePost(candidate)) {
        return candidate;
      }
      final Map<String, dynamic>? nestedPost = _readMap(candidate['post']);
      if (nestedPost != null && _looksLikePost(nestedPost)) {
        return nestedPost;
      }
    }
    return null;
  }

  bool _looksLikePost(Map<String, dynamic> payload) {
    return payload.containsKey('id') &&
        (payload.containsKey('caption') ||
            payload.containsKey('media') ||
            payload.containsKey('authorId') ||
            payload.containsKey('author'));
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

  List<StoryModel> _applySeenState(
    List<StoryModel> stories,
    Set<String> seenStoryIds,
  ) {
    return stories
        .map(
          (StoryModel story) => seenStoryIds.contains(story.id)
              ? story.copyWith(seen: true)
              : story,
        )
        .toList(growable: false);
  }

  List<StoryModel> _sortStories(List<StoryModel> stories) {
    final List<StoryModel> ordered = List<StoryModel>.from(stories);
    ordered.sort((StoryModel a, StoryModel b) {
      final DateTime aTime =
          a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bTime =
          b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return ordered;
  }

  List<PostModel> _mergePosts(
    List<PostModel> localPosts,
    List<PostModel> remotePosts,
  ) {
    final Map<String, PostModel> merged = <String, PostModel>{};
    for (final PostModel post in remotePosts) {
      merged[post.id] = post;
    }
    for (final PostModel post in localPosts) {
      merged[post.id] = post;
    }
    final List<PostModel> ordered = merged.values.toList(growable: false);
    ordered.sort(
      (PostModel a, PostModel b) => b.createdAt.compareTo(a.createdAt),
    );
    return ordered;
  }

  Future<List<String>> _uploadPostMedia({
    required List<String> mediaPaths,
    required bool isVideo,
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

      final String taskId =
          'post-${DateTime.now().microsecondsSinceEpoch}-${uploaded.length}';
      UploadProgress? lastProgress;
      await for (final UploadProgress progress in _uploadService.uploadFile(
        taskId: taskId,
        localPath: localPath,
        fields: <String, String>{
          'resourceType': _resourceTypeFor(localPath, isVideo: isVideo),
          'folder': 'optizenqor/posts/$authorId',
          'publicId': taskId,
        },
      )) {
        lastProgress = progress;
      }

      if (lastProgress == null ||
          lastProgress.status != UploadStatus.completed ||
          lastProgress.remotePath == null ||
          lastProgress.remotePath!.trim().isEmpty) {
        throw Exception(lastProgress?.error ?? 'Media upload failed.');
      }
      final String remotePath = lastProgress.remotePath!.trim();
      uploaded.add(remotePath);
    }
    return uploaded;
  }

  String _resourceTypeFor(String path, {required bool isVideo}) {
    if (isVideo) {
      return 'video';
    }
    final String lower = path.toLowerCase();
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm')) {
      return 'video';
    }
    return 'image';
  }
}
