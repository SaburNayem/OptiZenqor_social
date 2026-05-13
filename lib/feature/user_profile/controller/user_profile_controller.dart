import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/load_state_model.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/reel_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service/analytics_service.dart';
import '../../../core/enums/user_role.dart';
import '../../stories/model/buddy_relationship_model.dart';
import '../../stories/repository/buddy_repository.dart';
import '../repository/user_profile_repository.dart';

class UserProfileController extends ChangeNotifier {
  UserProfileController({
    UserProfileRepository? repository,
    AnalyticsService? analytics,
    BuddyRepository? buddyRepository,
  }) : _repository = repository ?? UserProfileRepository(),
       _analytics = analytics ?? AnalyticsService(),
       _buddyRepository = buddyRepository ?? BuddyRepository();

  final UserProfileRepository _repository;
  final AnalyticsService _analytics;
  final BuddyRepository _buddyRepository;
  bool _isDisposed = false;

  LoadStateModel state = const LoadStateModel();
  UserModel? user;
  UserModel? _currentViewer;
  String _currentUserId = '';
  int selectedTabIndex = 0;
  bool isFollowing = false;
  bool followRequestPending = false;
  bool isBuddy = false;
  bool buddyRequestSent = false;
  bool buddyRequestReceived = false;
  bool buddyActionInProgress = false;
  String? buddyRequestId;
  String? buddyReceivedRequestId;
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
      case UserRole.superadmin:
        return <String>['Admin Staff', 'Audit Logs', 'Platform Control'];
      case UserRole.admin:
        return <String>['Moderation', 'Reports', 'Platform Control'];
      case UserRole.creator:
        return <String>['Insights', 'Brand Deals', 'Draft Studio'];
      case UserRole.business:
        return <String>['Promotions', 'Catalog', 'Lead Inbox'];
      case UserRole.user:
        return <String>['Saved', 'Activity', 'Friends'];
      case UserRole.guest:
        return <String>['Explore', 'Follow', 'Share Profile'];
    }
  }

  void selectTab(int index) {
    selectedTabIndex = index;
    _notifySafely();
  }

  Future<void> load({String? userId}) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      isEmpty: false,
      hasError: false,
      errorMessage: null,
    );
    _notifySafely();

    try {
      _currentUserId = await _repository.getCurrentUserId();
      if (_isDisposed) {
        return;
      }
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
      if (_isDisposed) {
        return;
      }

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
        isBuddy = false;
        buddyRequestSent = false;
        buddyRequestReceived = false;
        buddyRequestId = null;
        buddyReceivedRequestId = null;
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          isEmpty: true,
        );
        _notifySafely();
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
        isOwnProfile
            ? Future<List<BuddyRelationshipModel>>.value(
                const <BuddyRelationshipModel>[],
              )
            : _buddyRepository.fetchBuddies(),
        isOwnProfile
            ? Future<List<BuddyRelationshipModel>>.value(
                const <BuddyRelationshipModel>[],
              )
            : _buddyRepository.fetchSentRequests(),
        isOwnProfile
            ? Future<List<BuddyRelationshipModel>>.value(
                const <BuddyRelationshipModel>[],
              )
            : _buddyRepository.fetchReceivedRequests(),
      ]);
      if (_isDisposed) {
        return;
      }

      _posts = resources[0] as List<PostModel>;
      _reels = resources[1] as List<ReelModel>;
      _followers = resources[2] as List<UserModel>;
      _following = resources[3] as List<UserModel>;
      _suggestedContacts = resources[4] as List<UserModel>;
      _taggedPosts = resources[5] as List<PostTagSummary>;
      _mentionHistory = resources[6] as List<String>;
      _mutualConnections = resources[7] as List<UserModel>;
      final FollowRemoteState followState = resources[8] as FollowRemoteState;
      final List<BuddyRelationshipModel> buddies =
          resources[9] as List<BuddyRelationshipModel>;
      final List<BuddyRelationshipModel> sentRequests =
          resources[10] as List<BuddyRelationshipModel>;
      final List<BuddyRelationshipModel> receivedRequests =
          resources[11] as List<BuddyRelationshipModel>;

      isFollowing = isOwnProfile ? false : followState.isFollowing;
      followRequestPending = isOwnProfile
          ? false
          : followState.hasPendingRequest;
      isBuddy = !isOwnProfile &&
          buddies.any((BuddyRelationshipModel item) => item.user.id == user!.id);
      BuddyRelationshipModel? sentRequest;
      if (!isOwnProfile) {
        for (final BuddyRelationshipModel item in sentRequests) {
          if (item.user.id == user!.id) {
            sentRequest = item;
            break;
          }
        }
      }
      buddyRequestSent = sentRequest != null;
      buddyRequestId = sentRequest?.id;
      BuddyRelationshipModel? receivedRequest;
      if (!isOwnProfile) {
        for (final BuddyRelationshipModel item in receivedRequests) {
          if (item.user.id == user!.id) {
            receivedRequest = item;
            break;
          }
        }
      }
      buddyRequestReceived = receivedRequest != null;
      buddyReceivedRequestId = receivedRequest?.id;

      state = state.copyWith(isLoading: false, isSuccess: true, isEmpty: false);
      await _analytics.profileViewed();
      _notifySafely();
    } catch (_) {
      if (_isDisposed) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        isEmpty: false,
        hasError: true,
        errorMessage: 'Unable to load profile',
      );
      _notifySafely();
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
    _notifySafely();
  }

  Future<String> toggleBuddyRequest() async {
    final UserModel? current = user;
    if (current == null || isOwnProfile || buddyActionInProgress) {
      return '';
    }

    buddyActionInProgress = true;
    _notifySafely();
    try {
      if (buddyRequestSent && buddyRequestId != null) {
        await _buddyRepository.cancelRequest(buddyRequestId!);
        buddyRequestSent = false;
        buddyRequestId = null;
        return 'Buddy request cancelled';
      }

      if (isBuddy) {
        await _buddyRepository.removeBuddy(current.id);
        isBuddy = false;
        buddyRequestSent = false;
        buddyRequestReceived = false;
        buddyRequestId = null;
        buddyReceivedRequestId = null;
        return 'Buddy removed';
      }

      final BuddyRelationshipModel request = await _buddyRepository.createRequest(
        current.id,
      );
      if (request.status.toLowerCase() == 'accepted') {
        isBuddy = true;
        buddyRequestSent = false;
        buddyRequestReceived = false;
        buddyRequestId = null;
        buddyReceivedRequestId = null;
        return 'Buddy added';
      }

      buddyRequestSent = true;
      buddyRequestReceived = false;
      buddyRequestId = request.id;
      buddyReceivedRequestId = null;
      return 'Buddy request sent';
    } finally {
      buddyActionInProgress = false;
      _notifySafely();
    }
  }

  Future<String> acceptBuddyRequest() async {
    final String requestId = buddyReceivedRequestId?.trim() ?? '';
    if (requestId.isEmpty || buddyActionInProgress) {
      return '';
    }

    buddyActionInProgress = true;
    _notifySafely();
    try {
      await _buddyRepository.acceptRequest(requestId);
      isBuddy = true;
      buddyRequestReceived = false;
      buddyRequestSent = false;
      buddyReceivedRequestId = null;
      buddyRequestId = null;
      return 'Buddy request accepted';
    } finally {
      buddyActionInProgress = false;
      _notifySafely();
    }
  }

  Future<String> rejectBuddyRequest() async {
    final String requestId = buddyReceivedRequestId?.trim() ?? '';
    if (requestId.isEmpty || buddyActionInProgress) {
      return '';
    }

    buddyActionInProgress = true;
    _notifySafely();
    try {
      await _buddyRepository.rejectRequest(requestId);
      isBuddy = false;
      buddyRequestReceived = false;
      buddyReceivedRequestId = null;
      return 'Buddy request rejected';
    } finally {
      buddyActionInProgress = false;
      _notifySafely();
    }
  }

  Future<String> removeBuddy() async {
    final UserModel? current = user;
    if (current == null || !isBuddy || buddyActionInProgress) {
      return '';
    }

    buddyActionInProgress = true;
    _notifySafely();
    try {
      await _buddyRepository.removeBuddy(current.id);
      isBuddy = false;
      buddyRequestSent = false;
      buddyRequestReceived = false;
      buddyRequestId = null;
      buddyReceivedRequestId = null;
      return 'Buddy removed';
    } finally {
      buddyActionInProgress = false;
      _notifySafely();
    }
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
    _notifySafely();
  }

  List<UserModel> suggestedContacts() =>
      List<UserModel>.unmodifiable(_suggestedContacts);

  Future<void> applyUpdatedProfile(UserModel updatedUser) async {
    if (user == null) {
      return;
    }
    user = updatedUser;
    _notifySafely();
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
        return AppColors.hexFF059669;
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
      case UserRole.superadmin:
      case UserRole.admin:
        return <String>['Posts', 'Reports', 'Insights', 'About'];
      case UserRole.creator:
        return <String>['Posts', 'Reels', 'Collaborations', 'Insights'];
      case UserRole.business:
        return <String>['Catalog', 'Posts', 'Campaigns', 'Insights'];
      case UserRole.guest:
        return <String>['Posts', 'Reels', 'About'];
    }
  }

  void _notifySafely() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
