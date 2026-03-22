import 'package:flutter/foundation.dart';

import '../../../core/common_models/load_state_model.dart';
import '../../../core/common_models/pagination_state_model.dart';
import '../../../core/common_models/post_model.dart';
import '../../../core/common_models/story_model.dart';
import '../../../core/services/analytics_service.dart';
import '../repository/home_feed_repository.dart';

enum FeedTab { forYou, following, trending }

class HomeFeedController extends ChangeNotifier {
  HomeFeedController({
    HomeFeedRepository? repository,
    AnalyticsService? analytics,
  })  : _repository = repository ?? HomeFeedRepository(),
        _analytics = analytics ?? AnalyticsService();

  final HomeFeedRepository _repository;
  final AnalyticsService _analytics;

  LoadStateModel state = const LoadStateModel();
  PaginationStateModel pagination = const PaginationStateModel();
  List<PostModel> posts = <PostModel>[];
  List<StoryModel> stories = <StoryModel>[];
  FeedTab activeTab = FeedTab.forYou;
  final Set<String> _hiddenPostIds = <String>{};
  final Set<String> _failedActionPostIds = <String>{};
  final Set<String> _likedPostIds = <String>{};
  final List<String> suggestedUsers = <String>['Maya', 'Rohan', 'Liam'];
  final List<String> suggestedGroups = <String>['Flutter Builders', 'Photo Club'];
  final List<String> suggestedPages = <String>['Travel Daily', 'Fitness Bites'];

  bool get hasError => state.hasError;
  bool get isLoading => state.isLoading;
  bool get isLoadingMore => state.isLoadingMore;
  List<PostModel> get visiblePosts =>
      posts.where((PostModel post) => !_hiddenPostIds.contains(post.id)).toList();
  bool isPostActionFailed(String postId) => _failedActionPostIds.contains(postId);
  bool isLiked(String postId) => _likedPostIds.contains(postId);

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();
    try {
      stories = await _repository.fetchStories();
      final FeedSegment segment = _segmentForTab(activeTab);
      posts = await _repository.fetchFeed(segment: segment, page: 1);
      pagination = pagination.copyWith(page: 1, hasMore: true);
      state = state.copyWith(
        isLoading: false,
        isEmpty: posts.isEmpty,
        isSuccess: posts.isNotEmpty,
      );
      notifyListeners();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Unable to load feed right now.',
      );
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _analytics.logEvent('feed_refresh', params: <String, dynamic>{
      'tab': activeTab.name,
    });
    await loadInitial();
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !pagination.hasMore) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, hasError: false, errorMessage: null);
    notifyListeners();
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
      state = state.copyWith(isLoadingMore: false);
      notifyListeners();
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        hasError: true,
        errorMessage: 'Failed to load more posts',
      );
      notifyListeners();
    }
  }

  Future<void> setTab(FeedTab tab) async {
    if (activeTab == tab) {
      return;
    }
    activeTab = tab;
    await _analytics.logEvent('feed_tab_switched', params: <String, dynamic>{
      'tab': tab.name,
    });
    await loadInitial();
  }

  Future<void> likePost(String postId) async {
    final bool wasLiked = _likedPostIds.contains(postId);
    if (wasLiked) {
      _likedPostIds.remove(postId);
    } else {
      _likedPostIds.add(postId);
    }
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      _failedActionPostIds.remove(postId);
      await _analytics.logEvent('post_like_toggle', params: <String, dynamic>{
        'postId': postId,
        'liked': !wasLiked,
      });
      notifyListeners();
    } catch (_) {
      if (wasLiked) {
        _likedPostIds.add(postId);
      } else {
        _likedPostIds.remove(postId);
      }
      _failedActionPostIds.add(postId);
      notifyListeners();
    }
  }

  int displayLikeCount(PostModel post) {
    if (_likedPostIds.contains(post.id)) {
      return post.likes + 1;
    }
    return post.likes;
  }

  bool canRetryPostAction(String postId) {
    return _failedActionPostIds.contains(postId);
  }

  void retryPostAction(String postId) {
    _failedActionPostIds.remove(postId);
    notifyListeners();
  }

  void notInterested(String postId) {
    _hiddenPostIds.add(postId);
    _analytics.logEvent('feed_not_interested', params: <String, dynamic>{
      'postId': postId,
      'tab': activeTab.name,
    });
    notifyListeners();
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

  // Legacy compatibility method used by existing UI and shell lifecycle.
  Future<void> restore() async {
    if (posts.isEmpty && !state.isLoading) {
      await loadInitial();
    }
  }
}
