import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/mock/mock_data.dart';
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
  });

  final PostDetailModel detail;
  final List<PostCommentModel> comments;
  final List<PostModel> relatedPosts;
  final bool isLiked;
  final Map<ReactionType, int> postReactions;
  final ReactionType? selectedReaction;
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

    final Map<String, dynamic> postJson = postResponse.data;
    final List<Map<String, dynamic>> commentItems = _readMapList(
      commentsResponse.data,
    );
    final List<Map<String, dynamic>> reactionItems = _readMapList(
      reactionsResponse.data,
    );
    final Map<String, UserModel> commentAuthors = await _loadCommentAuthors(
      commentItems,
    );
    final List<PostCommentModel> comments = _flattenComments(
      commentItems,
      commentAuthors,
    );
    final String currentUserId = await _currentUserId();
    final Map<ReactionType, int> postReactions = _buildReactionCounts(
      reactionItems,
    );
    final ReactionType? selectedReaction = _selectedReactionFor(
      reactionItems,
      currentUserId,
    );

    return PostDetailLoadResult(
      detail: PostDetailModel.fromApiJson(
        postJson,
        liveCommentCount: comments.length,
      ),
      comments: comments,
      relatedPosts: await _relatedPosts(postId),
      isLiked: currentUserId.isNotEmpty &&
          reactionItems.any(
            (Map<String, dynamic> item) =>
                (item['userId'] as Object? ?? '').toString() == currentUserId,
          ),
      postReactions: postReactions,
      selectedReaction: selectedReaction,
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
    final UserModel currentUser = await _currentUser();
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
      response.data,
      author: currentUser,
    );
  }

  Future<void> reactToComment({
    required String postId,
    required String commentId,
    required String reaction,
  }) async {
    final String userId = await _currentUserId();
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _apiClient.patch(
          ApiEndPoints.postCommentReact(postId, commentId),
          <String, dynamic>{'userId': userId, 'reaction': reaction},
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
        if (response.isSuccess && response.data.isNotEmpty) {
          authors[authorId] = UserModel.fromApiJson(response.data);
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
    final UserModel user = await _currentUser();
    return user.id;
  }

  Future<UserModel> _currentUser() async {
    final Map<String, dynamic>? session =
        await _storage.readJson(StorageKeys.authSession);
    final Object? user = session?['user'];
    if (user is Map<String, dynamic>) {
      return UserModel.fromApiJson(user);
    }
    if (user is Map) {
      return UserModel.fromApiJson(Map<String, dynamic>.from(user));
    }
    return MockData.users.first;
  }
}
