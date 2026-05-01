import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/load_state_model.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/reel_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service/analytics_service.dart';
import '../../../core/enums/user_role.dart';
import '../repository/user_profile_repository.dart';

class UserProfileController extends ChangeNotifier {
  UserProfileController({
    UserProfileRepository? repository,
    AnalyticsService? analytics,
  }) : _repository = repository ?? UserProfileRepository(),
       _analytics = analytics ?? AnalyticsService();

  final UserProfileRepository _repository;
  final AnalyticsService _analytics;

  LoadStateModel state = const LoadStateModel();
  UserModel? user;
  UserModel? _currentViewer;
  String _currentUserId = '';
  int selectedTabIndex = 0;
  bool isFollowing = false;
  bool followRequestPending = false;
  String accountExportMessage = 'No export requested yet';

  List<PostModel> _posts = <PostModel>[];
  List<ReelModel> _reels = <ReelModel>[];
  List<UserModel> _followers = <UserModel>[];
  List<UserModel> _following = <UserModel>[];
  List<UserModel> _suggestedContacts = <UserModel>[];
  List<UserModel> _mutualConnections = <UserModel>[];
  List<PostTagSummary> _taggedPosts = <PostTagSummary>[];
  List<String> _mentionHistory = <String>[];

  bool get isOwnProfile =>
      _currentUserId.isNotEmpty && user != null && user!.id == _currentUserId;

  List<PostModel> get posts => List<PostModel>.unmodifiable(_posts);

  List<ReelModel> get reels => List<ReelModel>.unmodifiable(_reels);

  List<UserModel> get followersList => List<UserModel>.unmodifiable(_followers);

  List<UserModel> get followingList => List<UserModel>.unmodifiable(_following);

  List<UserModel> get mutualConnections {
    return List<UserModel>.unmodifiable(_mutualConnections);
  }

  int get postCount => _posts.length;

  int get reelCount => _reels.length;

  int get followerCount =>
      _followers.isNotEmpty ? _followers.length : user?.followers ?? 0;

  int get followingCount =>
      _following.isNotEmpty ? _following.length : user?.following ?? 0;

  PostModel? get pinnedPost => _posts.isEmpty ? null : _posts.first;

  List<PostModel> get featuredPosts => _posts.take(2).toList(growable: false);

  List<PostTagSummary> get taggedPosts =>
      List<PostTagSummary>.unmodifiable(_taggedPosts);

  List<PostTagSummary> get taggedMedia =>
      taggedPosts.where((item) => item.mediaCount > 0).toList(growable: false);

  List<String> get mentionHistory => List<String>.unmodifiable(_mentionHistory);

  List<String> get highlights => <String>[
    'Travel',
    'Workspace',
    'Behind The Scenes',
    'Collabs',
  ];

  List<String> quickActions() {
    final UserModel? current = user;
    if (current == null) {
      return <String>['Share Profile'];
    }
    switch (current.role) {
      case UserRole.creator:
        return <String>['Insights', 'Brand Deals', 'Draft Studio'];
      case UserRole.business:
        return <String>['Promotions', 'Campaigns', 'Lead Inbox'];
      case UserRole.seller:
        return <String>['Products', 'Orders', 'Store Insights'];
      case UserRole.recruiter:
        return <String>['Open Roles', 'Candidates', 'Hiring Pipeline'];
      case UserRole.user:
        return <String>['Saved', 'Activity', 'Friends'];
      case UserRole.guest:
        return <String>['Explore', 'Follow', 'Share Profile'];
    }
  }

  void selectTab(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> load({String? userId}) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      isEmpty: false,
      hasError: false,
      errorMessage: null,
    );
    notifyListeners();

    try {
      _currentUserId = await _repository.getCurrentUserId();
      final String trimmedUserId = userId?.trim() ?? '';
      final bool viewingCurrentUser =
          trimmedUserId.isEmpty || trimmedUserId == _currentUserId;
      final Future<UserModel?> currentProfileFuture = _repository
          .getCurrentProfile();

      final Future<UserModel?> viewedProfileFuture = viewingCurrentUser
          ? currentProfileFuture
          : _repository.getProfileById(trimmedUserId);
      final Future<UserModel?> currentViewerFuture = _currentUserId.isEmpty
          ? Future<UserModel?>.value(null)
          : currentProfileFuture;

      final List<Object?> basics = await Future.wait<Object?>(<Future<Object?>>[
        viewedProfileFuture,
        currentViewerFuture,
      ]);

      user = basics[0] as UserModel?;
      _currentViewer = basics[1] as UserModel?;

      if (user == null) {
        _posts = <PostModel>[];
        _reels = <ReelModel>[];
        _followers = <UserModel>[];
        _following = <UserModel>[];
        _suggestedContacts = <UserModel>[];
        _mutualConnections = <UserModel>[];
        _taggedPosts = <PostTagSummary>[];
        _mentionHistory = <String>[];
        isFollowing = false;
        followRequestPending = false;
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          isEmpty: true,
        );
        notifyListeners();
        return;
      }

      final List<Object> resources = await Future.wait<Object>(<Future<Object>>[
        _repository.getPostsByUser(user!.id),
        _repository.getReelsByUser(user!.id),
        _repository.getFollowers(user!.id),
        _repository.getFollowing(user!.id),
        _repository.suggestedContacts(excludeUserId: user!.id),
        _repository.taggedPostSummaries(user!.id),
        _repository.mentionHistory(user!.id),
        isOwnProfile
            ? Future<List<UserModel>>.value(const <UserModel>[])
            : _repository.getMutualConnections(user!.id),
        isOwnProfile
            ? Future<FollowRemoteState>.value(const FollowRemoteState())
            : _repository.getFollowState(user!.id),
      ]);

      _posts = resources[0] as List<PostModel>;
      _reels = resources[1] as List<ReelModel>;
      _followers = resources[2] as List<UserModel>;
      _following = resources[3] as List<UserModel>;
      _suggestedContacts = resources[4] as List<UserModel>;
      _taggedPosts = resources[5] as List<PostTagSummary>;
      _mentionHistory = resources[6] as List<String>;
      _mutualConnections = resources[7] as List<UserModel>;
      final FollowRemoteState followState = resources[8] as FollowRemoteState;

      isFollowing = isOwnProfile ? false : followState.isFollowing;
      followRequestPending = isOwnProfile
          ? false
          : followState.hasPendingRequest;

      state = state.copyWith(isLoading: false, isSuccess: true, isEmpty: false);
      await _analytics.profileViewed();
      notifyListeners();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        isEmpty: false,
        hasError: true,
        errorMessage: 'Unable to load profile',
      );
      notifyListeners();
    }
  }

  Future<void> toggleFollow() async {
    final UserModel? current = user;
    if (current == null || isOwnProfile) {
      return;
    }

    final bool previousFollowing = isFollowing;
    final bool previousPending = followRequestPending;

    final FollowToggleResult result = await _repository.toggleFollow(
      current,
      isCurrentlyFollowing: previousFollowing,
      hasPendingRequest: previousPending,
    );

    isFollowing = result.isFollowing;
    followRequestPending = result.hasPendingRequest;

    if (_currentViewer != null) {
      if (isFollowing) {
        final bool alreadyInFollowers = _followers.any(
          (UserModel item) => item.id == _currentViewer!.id,
        );
        if (!alreadyInFollowers) {
          _followers = <UserModel>[_currentViewer!, ..._followers];
        }
      } else if (!followRequestPending) {
        _followers = _followers
            .where((UserModel item) => item.id != _currentViewer!.id)
            .toList(growable: false);
      }
    }

    if (user != null) {
      user = user!.copyWith(followers: _followers.length);
    }
    notifyListeners();
  }

  Future<void> requestDataExport() async {
    final UserModel? current = user;
    if (current == null) {
      return;
    }
    final Map<String, dynamic> export = await _repository.buildDataExport(
      current,
    );
    accountExportMessage =
        'Export requested at ${export['requestedAt']} for @${current.username}';
    notifyListeners();
  }

  List<UserModel> suggestedContacts() =>
      List<UserModel>.unmodifiable(_suggestedContacts);

  Future<void> applyUpdatedProfile(UserModel updatedUser) async {
    if (user == null) {
      return;
    }
    user = updatedUser;
    notifyListeners();
  }

  String verificationLabel() {
    final UserModel? current = user;
    if (current == null) {
      return 'Verification unavailable';
    }
    final String reason = current.verificationReason?.trim().isNotEmpty == true
        ? current.verificationReason!.trim()
        : 'No reason provided';
    return '${current.verificationStatus.toUpperCase()} - $reason';
  }

  Color badgeColor() {
    final UserModel? current = user;
    switch (current?.badgeStyle) {
      case 'creator':
        return AppColors.hexFFEAB308;
      case 'business':
        return AppColors.hexFF2563EB;
      case 'seller':
        return AppColors.hexFF059669;
      case 'recruiter':
        return AppColors.hexFF7C3AED;
      default:
        return AppColors.hexFF6B7280;
    }
  }

  List<String> roleSections() {
    final UserModel? current = user;
    if (current == null) {
      return <String>['Posts', 'Reels', 'Saved'];
    }
    switch (current.role) {
      case UserRole.user:
        return <String>['Posts', 'Reels', 'Saved', 'Tagged', 'About'];
      case UserRole.creator:
        return <String>['Posts', 'Reels', 'Collaborations', 'Insights'];
      case UserRole.business:
        return <String>['Catalog', 'Posts', 'Campaigns', 'Insights'];
      case UserRole.seller:
        return <String>['Catalog', 'Posts', 'Orders', 'Reviews'];
      case UserRole.recruiter:
        return <String>['Open Roles', 'Company Posts', 'Talent Pipeline'];
      case UserRole.guest:
        return <String>['Posts', 'Reels', 'About'];
    }
  }
}
