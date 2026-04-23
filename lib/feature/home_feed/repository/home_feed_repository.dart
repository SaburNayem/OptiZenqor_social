import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/data/shared_preference/app_shared_preferences.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../service/home_feed_service.dart';

enum FeedSegment { forYou, following, trending }

class HomeFeedRepository {
  HomeFeedRepository({
    AppSharedPreferences? storage,
    HomeFeedService? service,
  }) : _storage = storage ?? AppSharedPreferences(),
       _service = service ?? HomeFeedService();

  final AppSharedPreferences _storage;
  final HomeFeedService _service;

  Future<List<PostModel>> fetchFeed({
    required FeedSegment segment,
    required int page,
  }) async {
    if (page > 1) {
      return <PostModel>[];
    }

    try {
      final response = await _service.apiClient.get(_feedEndpointFor(segment));
      final List<Map<String, dynamic>> items = _readMapList(response.data);
      if (response.isSuccess && items.isNotEmpty) {
        final List<PostModel> parsedPosts = items
            .map(PostModel.fromApiJson)
            .toList(growable: false);
        final List<PostModel> posts = await _hydratePostAuthors(parsedPosts);
        await _storage.writeJsonList(
          StorageKeys.cachedFeed,
          posts.map((PostModel post) => post.toCacheJson()).toList(),
        );
        return posts;
      }
    } catch (_) {}

    final List<PostModel> cached = await readCachedFeed();
    if (cached.isNotEmpty) {
      return cached;
    }

    return const <PostModel>[];
  }

  Future<List<PostModel>> readCachedFeed() async {
    final cached = await _storage.readJsonList(StorageKeys.cachedFeed);
    if (cached.isEmpty) {
      return <PostModel>[];
    }
    return cached
        .map(PostModel.fromApiJson)
        .toList(growable: false);
  }

  Future<void> setPostLiked({
    required String postId,
    required bool liked,
  }) async {
    final String userId = await _currentUserId();
    final response = await _service.apiClient.patch(
      liked ? ApiEndPoints.postLike(postId) : ApiEndPoints.postUnlike(postId),
      <String, dynamic>{'userId': userId},
    );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to update post like');
    }
  }

  Future<List<StoryModel>> fetchStories() async {
    final localStories = await readLocalStories();
    return localStories;
  }

  Future<List<StoryModel>> readLocalStories() async {
    final cached = await _storage.readJsonList(StorageKeys.localStories);
    if (cached.isEmpty) {
      return <StoryModel>[];
    }
    return cached.map(StoryModel.fromJson).toList();
  }

  Future<void> saveLocalStories(List<StoryModel> stories) {
    return _storage.writeJsonList(
      StorageKeys.localStories,
      stories.map((story) => story.toJson()).toList(),
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
      'lessLikeThis': List<String>.from(raw['lessLikeThis'] as List<dynamic>? ?? const <dynamic>[]),
      'hiddenCreators': List<String>.from(raw['hiddenCreators'] as List<dynamic>? ?? const <dynamic>[]),
      'hiddenTopics': List<String>.from(raw['hiddenTopics'] as List<dynamic>? ?? const <dynamic>[]),
    };
  }

  Future<void> writeRecommendationPreferences(Map<String, List<String>> prefs) {
    return _storage.writeJson(StorageKeys.recommendationPreferences, prefs);
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

  List<Map<String, dynamic>> _readMapList(Map<String, dynamic> payload) {
    final Object? raw =
        payload['data'] ?? payload['items'] ?? payload['results'] ?? payload['value'];
    if (raw is List) {
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

  Future<String> _currentUserId() async {
    final Map<String, dynamic>? session =
        await _storage.readJson(StorageKeys.authSession);
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
    final Map<String, dynamic>? session =
        await _storage.readJson(StorageKeys.authSession);
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
        .where((PostModel post) => post.author == null && post.authorId.isNotEmpty)
        .map((PostModel post) => post.authorId)
        .toSet();
    if (missingAuthorIds.isEmpty) {
      return posts;
    }

    final Map<String, UserModel> authors = <String, UserModel>{};
    await Future.wait<void>(
      missingAuthorIds.map((String authorId) async {
        try {
          final ServiceResponseModel<Map<String, dynamic>> response =
              await _service.apiClient.get(ApiEndPoints.userById(authorId));
          if (!response.isSuccess || response.data['success'] == false) {
            return;
          }
          final Map<String, dynamic>? payload =
              _extractUserPayload(response.data);
          if (payload == null) {
            return;
          }
          final UserModel author = UserModel.fromApiJson(payload);
          if (author.id.isNotEmpty) {
            authors[authorId] = author;
          }
        } catch (_) {}
      }),
    );

    return posts
        .map(
          (PostModel post) => post.author != null || !authors.containsKey(post.authorId)
              ? post
              : post.copyWith(author: authors[post.authorId]),
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
