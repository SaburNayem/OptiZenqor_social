import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/app_config.dart';
import '../../../core/data/models/load_state_model.dart';
import '../../../core/data/models/pagination_state_model.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/data/service/analytics_service.dart';
import '../../../core/utils/app_logger.dart';
import '../helper/home_feed_post_factory.dart';
import '../repository/home_feed_repository.dart';
import '../../stories/repository/stories_repository.dart';

enum FeedTab { forYou, following, trending }

class HomeFeedController extends Cubit<int> {
  HomeFeedController({
    HomeFeedRepository? repository,
    AnalyticsService? analytics,
    StoriesRepository? storiesRepository,
  }) : _repository = repository ?? HomeFeedRepository(),
       _analytics = analytics ?? AnalyticsService(),
       _storiesRepository = storiesRepository ?? StoriesRepository(),
       super(0);

  final HomeFeedRepository _repository;
  final AnalyticsService _analytics;
  final StoriesRepository _storiesRepository;

  LoadStateModel loadState = const LoadStateModel();
  PaginationStateModel pagination = const PaginationStateModel();
  List<PostModel> posts = <PostModel>[];
  List<StoryModel> stories = <StoryModel>[];
  List<PostModel> hiddenPostRecords = <PostModel>[];
  FeedTab activeTab = FeedTab.forYou;
  final Set<String> _hiddenPostIds = <String>{};
  final Set<String> _failedActionPostIds = <String>{};
  final Set<String> _likedPostIds = <String>{};
  final Set<String> _lessLikeThisPostIds = <String>{};
  final Set<String> _hiddenCreatorIds = <String>{};
  final Set<String> _hiddenTopics = <String>{};
  String _currentUserId = '';
  final List<String> suggestedUsers = <String>['Maya', 'Rohan', 'Liam'];
  final List<String> suggestedGroups = <String>[
    'Flutter Builders',
    'Photo Club',
  ];
  final List<String> suggestedPages = <String>['Travel Daily', 'Fitness Bites'];

  bool get hasError => loadState.hasError;
  bool get isLoading => loadState.isLoading;
  bool get isLoadingMore => loadState.isLoadingMore;
  List<PostModel> get visiblePosts => posts
      .where((PostModel post) => !_hiddenPostIds.contains(post.id))
      .toList();
  List<PostModel> get hiddenPosts => hiddenPostRecords;
  bool isPostActionFailed(String postId) =>
      _failedActionPostIds.contains(postId);
  bool isLiked(String postId) {
    for (final PostModel post in posts) {
      if (post.id == postId) {
        return post.liked;
      }
    }
    return _likedPostIds.contains(postId);
  }

  String get currentUserId => _currentUserId;
  bool isOwnPost(PostModel post) =>
      _currentUserId.isNotEmpty && post.authorId == _currentUserId;

  Future<void> loadInitial() async {
    loadState = loadState.copyWith(
      isLoading: true,
      hasError: false,
      isSuccess: false,
      isEmpty: false,
      errorMessage: null,
    );
    _notify();
    try {
      _currentUserId = await _repository.currentUserId();
      final prefs = await _repository.readRecommendationPreferences();
      _lessLikeThisPostIds
        ..clear()
        ..addAll(prefs['lessLikeThis'] ?? const <String>[]);
      _hiddenCreatorIds
        ..clear()
        ..addAll(prefs['hiddenCreators'] ?? const <String>[]);
      _hiddenTopics
        ..clear()
        ..addAll(prefs['hiddenTopics'] ?? const <String>[]);
      stories = await _repository.fetchStories();
      final FeedSegment segment = _segmentForTab(activeTab);
      final results = await Future.wait<Object>(<Future<Object>>[
        _repository.fetchFeed(segment: segment, page: 1),
        _repository.fetchHiddenPosts(),
      ]);
      posts = results[0] as List<PostModel>;
      hiddenPostRecords = results[1] as List<PostModel>;
      _hiddenPostIds
        ..clear()
        ..addAll(hiddenPostRecords.map((PostModel post) => post.id));
      _likedPostIds
        ..clear()
        ..addAll(
          posts
              .where((PostModel post) => post.liked)
              .map((PostModel post) => post.id),
        );
      pagination = pagination.copyWith(page: 1, hasMore: true);
      loadState = loadState.copyWith(
        isLoading: false,
        hasError: false,
        isEmpty: posts.isEmpty && stories.isEmpty,
        isSuccess: posts.isNotEmpty || stories.isNotEmpty,
        errorMessage: null,
      );
      _notify();
    } catch (_) {
      loadState = loadState.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Unable to load feed right now.',
      );
      _notify();
    }
  }

  Future<void> refreshFeed() async {
    await _analytics.logEvent(
      'feed_refresh',
      params: <String, dynamic>{'tab': activeTab.name},
    );
    await loadInitial();
  }

  Future<void> loadNextPage() async {
    if (loadState.isLoadingMore || !pagination.hasMore) {
      return;
    }
    loadState = loadState.copyWith(
      isLoadingMore: true,
      hasError: false,
      errorMessage: null,
    );
    _notify();
    try {
      final FeedSegment segment = _segmentForTab(activeTab);
      final next = await _repository.fetchFeed(
        segment: segment,
        page: pagination.page + 1,
      );
      if (next.isEmpty) {
        pagination = pagination.copyWith(hasMore: false);
      } else {
        posts = <PostModel>[...posts, ...next];
        _likedPostIds.addAll(
          next
              .where((PostModel post) => post.liked)
              .map((PostModel post) => post.id),
        );
        pagination = pagination.copyWith(
          page: pagination.page + 1,
          hasMore: true,
        );
      }
      loadState = loadState.copyWith(isLoadingMore: false);
      _notify();
    } catch (_) {
      loadState = loadState.copyWith(
        isLoadingMore: false,
        hasError: true,
        errorMessage: 'Failed to load more posts',
      );
      _notify();
    }
  }

  Future<void> setTab(FeedTab tab) async {
    if (activeTab == tab) {
      return;
    }
    activeTab = tab;
    await _analytics.logEvent(
      'feed_tab_switched',
      params: <String, dynamic>{'tab': tab.name},
    );
    await loadInitial();
  }

  Future<void> likePost(String postId) async {
    final int index = posts.indexWhere((PostModel post) => post.id == postId);
    if (index == -1) {
      return;
    }
    final PostModel previous = posts[index];
    final bool wasLiked = previous.liked;
    if (wasLiked) {
      _likedPostIds.remove(postId);
    } else {
      _likedPostIds.add(postId);
    }
    posts[index] = previous.copyWith(
      liked: !wasLiked,
      likes: wasLiked
          ? (previous.likes - 1).clamp(0, 999999)
          : previous.likes + 1,
    );
    _notify();
    try {
      await _repository.setPostLiked(postId: postId, liked: !wasLiked);
      _failedActionPostIds.remove(postId);
      await _analytics.logEvent(
        'post_like_toggle',
        params: <String, dynamic>{'postId': postId, 'liked': !wasLiked},
      );
      _notify();
    } catch (_) {
      posts[index] = previous;
      if (wasLiked) {
        _likedPostIds.add(postId);
      } else {
        _likedPostIds.remove(postId);
      }
      _failedActionPostIds.add(postId);
      _notify();
    }
  }

  void syncPostLike({
    required String postId,
    required bool liked,
    required int likes,
  }) {
    final int index = posts.indexWhere((PostModel post) => post.id == postId);
    if (index == -1) {
      if (liked) {
        _likedPostIds.add(postId);
      } else {
        _likedPostIds.remove(postId);
      }
      _notify();
      return;
    }
    final PostModel current = posts[index];
    posts[index] = current.copyWith(liked: liked, likes: likes);
    if (liked) {
      _likedPostIds.add(postId);
    } else {
      _likedPostIds.remove(postId);
    }
    _notify();
  }

  int displayLikeCount(PostModel post) => post.likes;

  bool canRetryPostAction(String postId) {
    return _failedActionPostIds.contains(postId);
  }

  void retryPostAction(String postId) {
    _failedActionPostIds.remove(postId);
    _notify();
  }

  Future<void> notInterested(String postId) async {
    final int index = posts.indexWhere((PostModel post) => post.id == postId);
    if (index == -1) {
      return;
    }
    final PostModel target = posts[index];
    final bool wasHidden = _hiddenPostIds.contains(postId);
    if (!wasHidden) {
      _hiddenPostIds.add(postId);
      hiddenPostRecords = <PostModel>[
        target,
        ...hiddenPostRecords.where((PostModel post) => post.id != postId),
      ];
      _notify();
    }
    try {
      await _repository.hidePost(postId);
      await _analytics.logEvent(
        'feed_not_interested',
        params: <String, dynamic>{'postId': postId, 'tab': activeTab.name},
      );
    } catch (_) {
      if (!wasHidden) {
        _hiddenPostIds.remove(postId);
        hiddenPostRecords = hiddenPostRecords
            .where((PostModel post) => post.id != postId)
            .toList(growable: false);
        _notify();
      }
      rethrow;
    }
  }

  Future<void> unhidePost(String postId) async {
    final bool wasHidden = _hiddenPostIds.contains(postId);
    final List<PostModel> previousHidden = List<PostModel>.from(
      hiddenPostRecords,
    );
    _hiddenPostIds.remove(postId);
    hiddenPostRecords = hiddenPostRecords
        .where((PostModel post) => post.id != postId)
        .toList(growable: false);
    _notify();
    try {
      await _repository.unhidePost(postId);
    } catch (_) {
      if (wasHidden) {
        _hiddenPostIds.add(postId);
        hiddenPostRecords = previousHidden;
        _notify();
      }
      rethrow;
    }
  }

  Future<void> showLessLikeThis(String postId) async {
    _lessLikeThisPostIds.add(postId);
    await _persistRecommendationPreferences();
    _notify();
  }

  Future<void> hideCreator(String authorId) async {
    _hiddenCreatorIds.add(authorId);
    _hiddenPostIds.addAll(
      posts.where((item) => item.authorId == authorId).map((item) => item.id),
    );
    await _persistRecommendationPreferences();
    _notify();
  }

  Future<void> hideTopic(String topic) async {
    _hiddenTopics.add(topic);
    _hiddenPostIds.addAll(
      posts
          .where(
            (item) => item.tags.any(
              (tag) => tag.toLowerCase() == topic.toLowerCase(),
            ),
          )
          .map((item) => item.id),
    );
    await _persistRecommendationPreferences();
    _notify();
  }

  Future<void> createLocalPost({
    required String caption,
    List<String> mediaPaths = const <String>[],
    bool isVideo = false,
    String audience = 'Everyone',
    String? location,
    List<String> taggedPeople = const <String>[],
    List<String> coAuthors = const <String>[],
    String? altText,
    List<String> editHistory = const <String>[],
  }) async {
    if (caption.trim().isEmpty &&
        mediaPaths.every((item) => item.trim().isEmpty)) {
      return;
    }

    final currentUser = await _repository.currentUserProfile();
    final String authorId = currentUser?.id ?? '';
    if (authorId.trim().isEmpty) {
      loadState = loadState.copyWith(
        hasError: true,
        errorMessage: 'You need to be logged in to create a post.',
      );
      _notify();
      return;
    }

    final PostModel post = HomeFeedPostFactory.buildLocalPost(
      caption: caption,
      mediaPaths: mediaPaths,
      audience: audience,
      authorId: authorId,
      author: currentUser,
      location: location,
      taggedPeople: taggedPeople,
      coAuthors: coAuthors,
      altText: altText,
      editHistory: editHistory,
    );

    posts = <PostModel>[post, ...posts];
    final List<PostModel> localPosts = <PostModel>[
      post,
      ...(await _repository.readLocalCreatedPosts()).where(
        (PostModel item) => item.id != post.id,
      ),
    ];
    await _repository.saveLocalCreatedPosts(localPosts);
    loadState = loadState.copyWith(
      hasError: false,
      isEmpty: posts.isEmpty,
      isSuccess: posts.isNotEmpty,
      errorMessage: null,
    );
    await _analytics.logEvent(
      'post_created_local',
      params: <String, dynamic>{
        'hasMedia': post.media.isNotEmpty,
        'isVideo': isVideo,
      },
    );
    _notify();
  }

  Future<void> createPost({
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
    loadState = loadState.copyWith(
      hasError: false,
      errorMessage: null,
      isLoading: true,
    );
    _notify();
    try {
      final PostModel post = await _repository.createPost(
        caption: caption,
        mediaPaths: mediaPaths,
        isVideo: isVideo,
        audience: audience,
        location: location,
        taggedUserIds: taggedUserIds,
        mentionUsernames: mentionUsernames,
        altText: altText,
        editHistory: editHistory,
      );
      posts = <PostModel>[
        post,
        ...posts.where((PostModel item) => item.id != post.id),
      ];
      final List<PostModel> localPosts = await _repository
          .readLocalCreatedPosts();
      if (localPosts.any((PostModel item) => item.id == post.id)) {
        await _repository.saveLocalCreatedPosts(
          localPosts.where((PostModel item) => item.id != post.id).toList(),
        );
      }
      loadState = loadState.copyWith(
        isLoading: false,
        hasError: false,
        isEmpty: posts.isEmpty,
        isSuccess: posts.isNotEmpty,
        errorMessage: null,
      );
      await _analytics.logEvent(
        'post_created',
        params: <String, dynamic>{
          'hasMedia': post.media.isNotEmpty,
          'isVideo': isVideo,
        },
      );
      _notify();
    } catch (error) {
      loadState = loadState.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
      _notify();
      rethrow;
    }
  }

  Future<void> addLocalStories(List<StoryModel> newStories) async {
    if (newStories.isEmpty) {
      return;
    }

    final currentUser = await _repository.currentUserProfile();
    final List<StoryModel> resolvedStories = newStories
        .map(
          (StoryModel story) =>
              currentUser != null &&
                  story.author == null &&
                  story.userId == currentUser.id
              ? story.copyWith(author: currentUser)
              : story,
        )
        .toList(growable: false);

    stories = _sortStories(<StoryModel>[...resolvedStories, ...stories]);
    await _analytics.logEvent(
      'story_created_local',
      params: <String, dynamic>{
        'count': newStories.length,
        'hasMedia': resolvedStories.any((story) => story.hasMedia),
        'hasText': resolvedStories.any((story) => story.hasText),
      },
    );
    _notify();
  }

  Future<void> createStories(List<StoryModel> draftStories) async {
    if (draftStories.isEmpty) {
      return;
    }

    try {
      final List<StoryModel> created = await _storiesRepository.createStories(
        draftStories,
      );
      List<StoryModel> remoteStories = const <StoryModel>[];
      try {
        remoteStories = await _repository.fetchStories();
      } catch (_) {}
      if (remoteStories.isEmpty && created.isNotEmpty) {
        AppLogger.info(
          '[StorySync] Created story but GET /stories returned empty.',
        );
      }
      stories = AppConfig.useRemoteOnly
          ? remoteStories
          : remoteStories.isEmpty
          ? _sortStories(<StoryModel>[...created, ...stories])
          : remoteStories;
      loadState = loadState.copyWith(
        hasError: false,
        errorMessage: null,
        isSuccess: stories.isNotEmpty || posts.isNotEmpty,
        isEmpty: stories.isEmpty && posts.isEmpty,
      );
      await _analytics.logEvent(
        'story_created',
        params: <String, dynamic>{
          'count': created.length,
          'hasMedia': created.any((StoryModel story) => story.hasMedia),
          'hasText': created.any((StoryModel story) => story.hasText),
        },
      );
      _notify();
    } catch (_) {
      loadState = loadState.copyWith(
        hasError: true,
        errorMessage: 'Unable to create story right now.',
      );
      _notify();
    }
  }

  Future<void> editPostCaption({
    required String postId,
    required String caption,
  }) async {
    final int index = posts.indexWhere((PostModel post) => post.id == postId);
    if (index == -1) {
      throw Exception('Post not found.');
    }
    final PostModel previous = posts[index];
    final String trimmedCaption = caption.trim();
    if (trimmedCaption.isEmpty) {
      throw Exception('Caption cannot be empty.');
    }
    posts[index] = previous.copyWith(
      caption: trimmedCaption,
      editHistory: <String>[
        ...previous.editHistory,
        'Edited ${DateTime.now().toIso8601String()}',
      ],
    );
    _notify();
    try {
      final PostModel updated = await _repository.updatePost(
        postId: postId,
        caption: trimmedCaption,
      );
      posts[index] = updated.author == null && previous.author != null
          ? updated.copyWith(author: previous.author)
          : updated;
      _notify();
    } catch (_) {
      posts[index] = previous;
      _notify();
      rethrow;
    }
  }

  Future<void> deleteOwnedPost(String postId) async {
    final int index = posts.indexWhere((PostModel post) => post.id == postId);
    if (index == -1) {
      return;
    }
    final PostModel removed = posts[index];
    posts.removeAt(index);
    _notify();
    try {
      await _repository.deletePost(postId);
      final List<PostModel> localPosts = await _repository
          .readLocalCreatedPosts();
      await _repository.saveLocalCreatedPosts(
        localPosts.where((PostModel post) => post.id != postId).toList(),
      );
    } catch (_) {
      posts.insert(index, removed);
      _notify();
      rethrow;
    }
  }

  Future<void> markStoriesSeen(List<String> storyIds) async {
    final Set<String> ids = storyIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet();
    if (ids.isEmpty) {
      return;
    }

    bool changed = false;
    stories = stories
        .map((StoryModel story) {
          if (!ids.contains(story.id) || story.seen) {
            return story;
          }
          changed = true;
          return story.copyWith(seen: true);
        })
        .toList(growable: false);

    final Set<String> seenStoryIds = await _repository.readSeenStoryIds();
    final int previousLength = seenStoryIds.length;
    seenStoryIds.addAll(ids);
    await _repository.saveSeenStoryIds(seenStoryIds);
    if (changed || seenStoryIds.length != previousLength) {
      _notify();
    }
  }

  Future<void> deleteStory(String storyId) async {
    final String normalizedId = storyId.trim();
    if (normalizedId.isEmpty) {
      return;
    }

    if (!normalizedId.startsWith('local_story_')) {
      await _storiesRepository.deleteStory(normalizedId);
    }

    stories = stories
        .where((StoryModel story) => story.id != normalizedId)
        .toList(growable: false);
    _notify();
  }

  FeedSegment _segmentForTab(FeedTab tab) {
    switch (tab) {
      case FeedTab.forYou:
        return FeedSegment.forYou;
      case FeedTab.following:
        return FeedSegment.following;
      case FeedTab.trending:
        return FeedSegment.trending;
    }
  }

  Future<void> restore() async {
    if (posts.isEmpty && !loadState.isLoading) {
      await loadInitial();
    }
  }

  void clearLocalState() {
    loadState = const LoadStateModel();
    pagination = const PaginationStateModel();
    posts = <PostModel>[];
    stories = <StoryModel>[];
    hiddenPostRecords = <PostModel>[];
    activeTab = FeedTab.forYou;
    _hiddenPostIds.clear();
    _failedActionPostIds.clear();
    _likedPostIds.clear();
    _lessLikeThisPostIds.clear();
    _hiddenCreatorIds.clear();
    _hiddenTopics.clear();
    _currentUserId = '';
    _notify();
  }

  Future<void> _persistRecommendationPreferences() {
    return _repository.writeRecommendationPreferences(
      HomeFeedPostFactory.buildRecommendationPreferences(
        lessLikeThisPostIds: _lessLikeThisPostIds,
        hiddenCreatorIds: _hiddenCreatorIds,
        hiddenTopics: _hiddenTopics,
      ),
    );
  }

  List<StoryModel> _sortStories(List<StoryModel> input) {
    final List<StoryModel> ordered = List<StoryModel>.from(input);
    ordered.sort((StoryModel a, StoryModel b) {
      final DateTime aTime =
          a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bTime =
          b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return ordered;
  }

  void _notify() => emit(state + 1);
}
