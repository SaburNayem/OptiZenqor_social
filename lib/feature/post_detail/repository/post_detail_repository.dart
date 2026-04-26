import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service/api_client_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../../../core/data/shared_preference/app_shared_preferences.dart';
import '../../../core/enums/reaction_type.dart';
import '../../../core/helpers/format_helper.dart';
import '../../home_feed/repository/home_feed_repository.dart';
import '../model/post_comment_model.dart';
import '../model/post_detail_model.dart';

class PostDetailLoadResult {
  const PostDetailLoadResult({
    required this.detail,
    required this.comments,
    required this.relatedPosts,
    required this.isLiked,
    required this.postReactions,
    required this.selectedReaction,
    required this.currentUser,
  });

  final PostDetailModel detail;
  final List<PostCommentModel> comments;
  final List<PostModel> relatedPosts;
  final bool isLiked;
  final Map<ReactionType, int> postReactions;
  final ReactionType? selectedReaction;
  final UserModel? currentUser;
}

class PostDetailRepository {
  PostDetailRepository({
    ApiClientService? apiClient,
    AppSharedPreferences? storage,
    HomeFeedRepository? homeFeedRepository,
  }) : _apiClient = apiClient ?? ApiClientService(),
       _storage = storage ?? AppSharedPreferences(),
       _homeFeedRepository = homeFeedRepository ?? HomeFeedRepository();

  final ApiClientService _apiClient;
  final AppSharedPreferences _storage;
  final HomeFeedRepository _homeFeedRepository;

  Future<PostDetailLoadResult> fetchPostDetail(String postId) async {
    final List<Object> responses = await Future.wait<Object>(<Future<Object>>[
      _apiClient.get(ApiEndPoints.postById(postId)),
      _apiClient.get(ApiEndPoints.postComments(postId)),
      _apiClient.get(ApiEndPoints.postReactions(postId)),
    ]);

    final ServiceResponseModel<Map<String, dynamic>> postResponse =
        responses[0] as ServiceResponseModel<Map<String, dynamic>>;
    final ServiceResponseModel<Map<String, dynamic>> commentsResponse =
        responses[1] as ServiceResponseModel<Map<String, dynamic>>;
    final ServiceResponseModel<Map<String, dynamic>> reactionsResponse =
        responses[2] as ServiceResponseModel<Map<String, dynamic>>;

    if (!postResponse.isSuccess || postResponse.data['success'] == false) {
      throw Exception(postResponse.message ?? 'Unable to load post');
    }

    final Map<String, dynamic>? postJson = _extractPostPayload(postResponse.data);
    if (postJson == null) {
      throw Exception('Unable to read post details from the response.');
    }
    final List<Map<String, dynamic>> commentItems = _readMapList(
      commentsResponse.data,
      preferredKeys: const <String>['comments', 'data', 'items', 'results'],
    );
    final List<Map<String, dynamic>> reactionItems = _readMapList(
      reactionsResponse.data,
      preferredKeys: const <String>['reactions', 'data', 'items', 'results'],
    );
    final Map<String, UserModel> commentAuthors = await _loadCommentAuthors(
      commentItems,
    );
    final List<PostCommentModel> comments = _flattenComments(
      commentItems,
      commentAuthors,
    );
    final String currentUserId = await _currentUserId();
    final UserModel? currentUser = await currentUserProfile();
    final Map<ReactionType, int> postReactions = _buildReactionCounts(
      reactionItems,
    );
    final ReactionType? selectedReaction = _selectedReactionFor(
      reactionItems,
      currentUserId,
    );
    final PostDetailModel baseDetail = PostDetailModel.fromApiJson(
      postJson,
      liveCommentCount: comments.length,
    );
    final UserModel? author = baseDetail.author ?? await _loadAuthor(baseDetail.authorId);

    return PostDetailLoadResult(
      detail: baseDetail.copyWith(author: author),
      comments: comments,
      relatedPosts: await _relatedPosts(postId),
      isLiked: currentUserId.isNotEmpty &&
          reactionItems.any(
            (Map<String, dynamic> item) =>
                (item['userId'] as Object? ?? '').toString() == currentUserId,
          ),
      postReactions: postReactions,
      selectedReaction: selectedReaction,
      currentUser: currentUser,
    );
  }

  Future<void> setPostLiked({
    required String postId,
    required bool liked,
  }) async {
    final String userId = await _currentUserId();
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _apiClient.patch(
          liked ? ApiEndPoints.postLike(postId) : ApiEndPoints.postUnlike(postId),
          <String, dynamic>{'userId': userId},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to update post like');
    }
  }

  Future<PostCommentModel> createComment({
    required String postId,
    required String message,
    String? replyTo,
  }) async {
    final UserModel? currentUser = await currentUserProfile();
    if (currentUser == null) {
      throw Exception('You must be signed in to comment.');
    }
    final String endpoint = replyTo == null || replyTo.trim().isEmpty
        ? ApiEndPoints.postComments(postId)
        : ApiEndPoints.postCommentReplies(postId, replyTo);
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _apiClient.post(endpoint, <String, dynamic>{
          'authorId': currentUser.id,
          'author': currentUser.name,
          'message': message.trim(),
          if (replyTo != null && replyTo.trim().isNotEmpty) 'replyTo': replyTo,
          'mentions': RegExp(r'@([a-zA-Z0-9_.]+)')
              .allMatches(message)
              .map((Match item) => item.group(1) ?? '')
              .where((String item) => item.isNotEmpty)
              .toList(growable: false),
        });
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to create comment');
    }
    return _toCommentModel(
      _extractCommentPayload(response.data) ?? response.data,
      author: currentUser,
    );
  }

  Future<void> reactToComment({
    required String postId,
    required String commentId,
    required String reaction,
    required bool active,
  }) async {
    final String userId = await _currentUserId();
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _apiClient.patch(
          ApiEndPoints.postCommentReact(postId, commentId),
          <String, dynamic>{
            'userId': userId,
            'reaction': reaction,
            'active': active,
          },
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to react to comment');
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _apiClient.delete(ApiEndPoints.postCommentById(postId, commentId));
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to delete comment');
    }
  }

  Future<PostDetailModel> updatePostCaption({
    required String postId,
    required String caption,
  }) async {
    final String trimmedCaption = caption.trim();
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _apiClient.patch(
          ApiEndPoints.postById(postId),
          <String, dynamic>{'caption': trimmedCaption},
        );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to update post right now.');
    }
    final Map<String, dynamic>? payload = _extractPostPayload(response.data);
    if (payload == null) {
      throw Exception('Updated post response did not include post data.');
    }
    return PostDetailModel.fromApiJson(payload);
  }

  Future<void> deletePost(String postId) async {
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _apiClient.delete(ApiEndPoints.postById(postId));
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to delete post right now.');
    }
  }

  Future<List<PostModel>> _relatedPosts(String postId) async {
    final List<PostModel> feed = await _homeFeedRepository.fetchFeed(
      segment: FeedSegment.forYou,
      page: 1,
    );
    return feed
        .where((PostModel item) => item.id != postId)
        .take(3)
        .toList(growable: false);
  }

  Future<UserModel?> _loadAuthor(String authorId) async {
    if (authorId.trim().isEmpty) {
      return null;
    }
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _apiClient.get(ApiEndPoints.userById(authorId));
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
      }
      final Map<String, dynamic>? payload = _extractUserPayload(response.data);
      if (payload == null) {
        return null;
      }
      final UserModel user = UserModel.fromApiJson(payload);
      return user.id.isEmpty ? null : user;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, UserModel>> _loadCommentAuthors(
    List<Map<String, dynamic>> comments,
  ) async {
    final Set<String> authorIds = <String>{};
    void collect(List<Map<String, dynamic>> items) {
      for (final Map<String, dynamic> item in items) {
        final String authorId = (item['authorId'] as Object? ?? '').toString();
        if (authorId.isNotEmpty) {
          authorIds.add(authorId);
        }
        collect(_readMapList(<String, dynamic>{'data': item['replies']}));
      }
    }

    collect(comments);
    final Map<String, UserModel> authors = <String, UserModel>{};
    await Future.wait<void>(
      authorIds.map((String authorId) async {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _apiClient.get(ApiEndPoints.userById(authorId));
        if (!response.isSuccess || response.data.isEmpty) {
          return;
        }
        final Map<String, dynamic>? payload = _extractUserPayload(response.data);
        if (payload == null) {
          return;
        }
        final UserModel author = UserModel.fromApiJson(payload);
        if (author.id.isNotEmpty) {
          authors[authorId] = author;
        }
      }),
    );
    return authors;
  }

  List<PostCommentModel> _flattenComments(
    List<Map<String, dynamic>> items,
    Map<String, UserModel> authors,
  ) {
    final List<PostCommentModel> comments = <PostCommentModel>[];

    void visit(Map<String, dynamic> item) {
      final String authorId = (item['authorId'] as Object? ?? '').toString();
      comments.add(
        _toCommentModel(
          item,
          author: authors[authorId],
        ),
      );

      final List<Map<String, dynamic>> replies = _readMapList(
        <String, dynamic>{'data': item['replies']},
      );
      for (final Map<String, dynamic> reply in replies) {
        visit(reply);
      }
    }

    for (final Map<String, dynamic> item in items) {
      visit(item);
    }
    return comments;
  }

  PostCommentModel _toCommentModel(
    Map<String, dynamic> item, {
    UserModel? author,
  }) {
    final String authorId = (item['authorId'] as Object? ?? '').toString();
    return PostCommentModel(
      id: (item['id'] as Object? ?? '').toString(),
      postId: (item['postId'] as Object? ?? '').toString(),
      authorId: authorId,
      author: (item['author'] as String? ?? author?.name ?? 'Unknown user').trim(),
      authorUsername: author?.username,
      authorAvatar: author?.avatar,
      message: (item['message'] as String? ?? '').trim(),
      replyTo: item['replyTo'] as String?,
      createdAt: _relativeTime(item['createdAt']),
      likeCount: _readInt(item['likeCount']),
      isLikedByMe: item['isLikedByMe'] as bool? ?? false,
      isReported: item['isReported'] as bool? ?? false,
      isEdited: item['isEdited'] as bool? ?? false,
      reactions: _readReactionMap(item['reactions']),
      mentions: _readStringList(item['mentions']),
      replyCount: _readInt(item['replyCount']),
    );
  }

  Map<ReactionType, int> _buildReactionCounts(
    List<Map<String, dynamic>> items,
  ) {
    final Map<ReactionType, int> counts = <ReactionType, int>{};
    for (final Map<String, dynamic> item in items) {
      final ReactionType? type = _reactionTypeFromValue(item['reaction']);
      if (type == null) {
        continue;
      }
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  ReactionType? _selectedReactionFor(
    List<Map<String, dynamic>> items,
    String currentUserId,
  ) {
    if (currentUserId.isEmpty) {
      return null;
    }
    final Map<String, dynamic>? currentReaction = items
        .where(
          (Map<String, dynamic> item) =>
              (item['userId'] as Object? ?? '').toString() == currentUserId,
        )
        .cast<Map<String, dynamic>?>()
        .firstOrNull;
    if (currentReaction == null) {
      return null;
    }
    return _reactionTypeFromValue(currentReaction['reaction']);
  }

  ReactionType? _reactionTypeFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'like':
        return ReactionType.like;
      case 'love':
      case 'fire':
        return ReactionType.love;
      case 'haha':
        return ReactionType.haha;
      case 'wow':
        return ReactionType.wow;
      case 'sad':
        return ReactionType.sad;
      case 'angry':
        return ReactionType.angry;
      default:
        return null;
    }
  }

  List<Map<String, dynamic>> _readMapList(
    Map<String, dynamic> payload, {
    List<String> preferredKeys = const <String>['data', 'items', 'results', 'value'],
  }) {
    for (final Object? raw in <Object?>[
      ...preferredKeys.map((String key) => payload[key]),
      payload['data'],
      payload['items'],
      payload['results'],
      payload['value'],
    ]) {
      if (raw is List) {
        return raw
            .whereType<Object>()
            .map((Object item) => _readMap(item) ?? const <String, dynamic>{})
            .where((Map<String, dynamic> item) => item.isNotEmpty)
            .toList(growable: false);
      }
      final Map<String, dynamic>? rawMap = _readMap(raw);
      if (rawMap == null || rawMap.isEmpty) {
        continue;
      }
      final List<Map<String, dynamic>> nested = _readMapList(rawMap);
      if (nested.isNotEmpty) {
        return nested;
      }
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, int> _readReactionMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value.map<String, int>(
        (String key, dynamic item) => MapEntry(key, _readInt(item)),
      );
    }
    if (value is Map) {
      return value.map<String, int>(
        (dynamic key, dynamic item) =>
            MapEntry(key.toString(), _readInt(item)),
      );
    }
    return const <String, int>{};
  }

  List<String> _readStringList(Object? value) {
    if (value is List) {
      return value
          .map((Object? item) => item?.toString() ?? '')
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }

  int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is List) {
      return value.length;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _relativeTime(Object? value) {
    final String raw = value?.toString() ?? '';
    final DateTime? dateTime = DateTime.tryParse(raw);
    if (dateTime == null) {
      return raw;
    }
    return FormatHelper.timeAgo(dateTime.toLocal());
  }

  Future<String> _currentUserId() async {
    final UserModel? user = await currentUserProfile();
    return user?.id ?? '';
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
      _readMap(payload['detail']),
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
      final Map<String, dynamic>? nestedDetail = _readMap(candidate['detail']);
      if (nestedDetail != null && _looksLikePost(nestedDetail)) {
        return nestedDetail;
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractCommentPayload(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>?> candidates = <Map<String, dynamic>?>[
      _looksLikeComment(payload) ? payload : null,
      _readMap(payload['comment']),
      _readMap(payload['data']),
      _readMap(payload['result']),
    ];
    for (final Map<String, dynamic>? candidate in candidates) {
      if (candidate == null || candidate.isEmpty) {
        continue;
      }
      if (_looksLikeComment(candidate)) {
        return candidate;
      }
      final Map<String, dynamic>? nestedComment = _readMap(candidate['comment']);
      if (nestedComment != null && _looksLikeComment(nestedComment)) {
        return nestedComment;
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

  bool _looksLikeComment(Map<String, dynamic> payload) {
    return payload.containsKey('id') &&
        (payload.containsKey('message') ||
            payload.containsKey('authorId') ||
            payload.containsKey('postId'));
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
