import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models/load_state_model.dart';
import '../../../core/data/models/pagination_state_model.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/story_model.dart';
import '../../../core/data/service/analytics_service.dart';
import '../helper/home_feed_post_factory.dart';
import '../repository/home_feed_repository.dart';

enum FeedTab { forYou, following, trending }

class HomeFeedController extends Cubit<int> {
  HomeFeedController({
    HomeFeedRepository? repository,
    AnalyticsService? analytics,
  }) : _repository = repository ?? HomeFeedRepository(),
       _analytics = analytics ?? AnalyticsService(),
       super(0);

  final HomeFeedRepository _repository;
  final AnalyticsService _analytics;

  LoadStateModel loadState = const LoadStateModel();
  PaginationStateModel pagination = const PaginationStateModel();
  List<PostModel> posts = <PostModel>[];
  List<StoryModel> stories = <StoryModel>[];
  FeedTab activeTab = FeedTab.forYou;
  final Set<String> _hiddenPostIds = <String>{};
  final Set<String> _failedActionPostIds = <String>{};
  final Set<String> _likedPostIds = <String>{};
  final Set<String> _lessLikeThisPostIds = <String>{};
  final Set<String> _hiddenCreatorIds = <String>{};
  final Set<String> _hiddenTopics = <String>{};
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
  List<PostModel> get hiddenPosts => posts
      .where((PostModel post) => _hiddenPostIds.contains(post.id))
      .toList();
  bool isPostActionFailed(String postId) =>
      _failedActionPostIds.contains(postId);
  bool isLiked(String postId) => _likedPostIds.contains(postId);

  Future<void> loadInitial() async {
    loadState = loadState.copyWith(isLoading: true, errorMessage: null);
    _notify();
    try {
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
      posts = await _repository.fetchFeed(segment: segment, page: 1);
      pagination = pagination.copyWith(page: 1, hasMore: true);
      loadState = loadState.copyWith(
        isLoading: false,
        isEmpty: posts.isEmpty,
        isSuccess: posts.isNotEmpty,
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
    final bool wasLiked = _likedPostIds.contains(postId);
    if (wasLiked) {
      _likedPostIds.remove(postId);
    } else {
      _likedPostIds.add(postId);
    }
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
      if (wasLiked) {
        _likedPostIds.add(postId);
      } else {
        _likedPostIds.remove(postId);
      }
      _failedActionPostIds.add(postId);
      _notify();
    }
  }

  int displayLikeCount(PostModel post) =>
      _likedPostIds.contains(post.id) ? post.likes + 1 : post.likes;

  bool canRetryPostAction(String postId) {
    return _failedActionPostIds.contains(postId);
  }

  void retryPostAction(String postId) {
    _failedActionPostIds.remove(postId);
    _notify();
  }

  void notInterested(String postId) {
    _hiddenPostIds.add(postId);
    _analytics.logEvent(
      'feed_not_interested',
      params: <String, dynamic>{'postId': postId, 'tab': activeTab.name},
    );
    _notify();
  }

  void unhidePost(String postId) {
    if (_hiddenPostIds.remove(postId)) {
      _notify();
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
      isEmpty: posts.isEmpty,
      isSuccess: posts.isNotEmpty,
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
      final List<PostModel> localPosts = await _repository.readLocalCreatedPosts();
      if (localPosts.any((PostModel item) => item.id == post.id)) {
        await _repository.saveLocalCreatedPosts(
          localPosts.where((PostModel item) => item.id != post.id).toList(),
        );
      }
      loadState = loadState.copyWith(
        isLoading: false,
        isEmpty: posts.isEmpty,
        isSuccess: posts.isNotEmpty,
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
    await _repository.saveLocalStories(
      stories.where((story) => story.id.startsWith('local_story_')).toList(),
    );
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

  Future<void> markStoriesSeen(List<String> storyIds) async {
    final Set<String> ids = storyIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet();
    if (ids.isEmpty) {
      return;
    }

    bool changed = false;
    stories = stories.map((StoryModel story) {
      if (!ids.contains(story.id) || story.seen) {
        return story;
      }
      changed = true;
      return story.copyWith(seen: true);
    }).toList(growable: false);

    final Set<String> seenStoryIds = await _repository.readSeenStoryIds();
    final int previousLength = seenStoryIds.length;
    seenStoryIds.addAll(ids);
    await _repository.saveSeenStoryIds(seenStoryIds);
    await _repository.saveLocalStories(
      stories.where((StoryModel story) => story.id.startsWith('local_story_')).toList(),
    );
    if (changed || seenStoryIds.length != previousLength) {
      _notify();
    }
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
