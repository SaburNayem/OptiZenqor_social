import 'package:flutter/material.dart';

import '../../../core/common_models/load_state_model.dart';
import '../../../core/common_models/post_model.dart';
import '../../../core/common_models/reel_model.dart';
import '../../../core/common_models/user_model.dart';
import '../../../core/common_data/mock_data.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/services/analytics_service.dart';
import '../../follow_unfollow/controller/follow_controller.dart';
import '../repository/user_profile_repository.dart';

class UserProfileController extends ChangeNotifier {
  UserProfileController({
    UserProfileRepository? repository,
    AnalyticsService? analytics,
    FollowController? followController,
  })  : _repository = repository ?? UserProfileRepository(),
        _analytics = analytics ?? AnalyticsService(),
        _followController = followController ?? FollowController() {
    _followController.addListener(notifyListeners);
  }

  final UserProfileRepository _repository;
  final AnalyticsService _analytics;
  final FollowController _followController;

  LoadStateModel state = const LoadStateModel();
  UserModel? user;
  String _viewedUserId = '';
  int selectedTabIndex = 0;
  bool _followInitialized = false;
  bool showTaggedMedia = false;
  String accountExportMessage = 'No export requested yet';

  bool get isOwnProfile {
    final currentUserId = _repository.getCurrentUserId();
    return currentUserId.isNotEmpty && _viewedUserId == currentUserId;
  }

  List<String> get profileTabs {
    return <String>['Posts', 'Reels', 'Tagged Posts', 'Tagged Media', 'Mentions'];
  }

  bool get isFollowing {
    final current = user;
    if (current == null || isOwnProfile) {
      return false;
    }
    return _followController.stateFor(current).isFollowing;
  }

  bool get followRequestPending {
    final current = user;
    if (current == null || isOwnProfile) {
      return false;
    }
    return _followController.stateFor(current).hasPendingRequest;
  }

  List<UserModel> get followersList {
    final current = user;
    if (current == null) {
      return const <UserModel>[];
    }
    return _followController.followers(current.id);
  }

  List<UserModel> get followingList {
    final current = user;
    if (current == null) {
      return const <UserModel>[];
    }
    return _followController.following(current.id);
  }

  List<UserModel> get mutualConnections {
    final current = user;
    if (current == null || isOwnProfile) {
      return const <UserModel>[];
    }
    return _followController.mutualConnections(current.id);
  }

  List<PostModel> get posts {
    final current = user;
    if (current == null) {
      return <PostModel>[];
    }
    return MockData.posts.where((PostModel p) => p.authorId == current.id).toList();
  }

  List<ReelModel> get reels {
    final current = user;
    if (current == null) {
      return <ReelModel>[];
    }
    return MockData.reels.where((ReelModel r) => r.authorId == current.id).toList();
  }

  int get postCount => posts.length;
  int get reelCount => reels.length;
  PostModel? get pinnedPost => posts.isEmpty ? null : posts.first;
  List<PostModel> get featuredPosts => posts.take(2).toList();
  List<PostTagSummary> get taggedPosts => user == null
      ? const <PostTagSummary>[]
      : _repository.taggedPostSummaries(user!.id);
  List<PostTagSummary> get taggedMedia => taggedPosts.where((item) => item.mediaCount > 0).toList();
  List<String> get mentionHistory => user == null ? const <String>[] : _repository.mentionHistory(user!.id);

  List<String> get highlights => <String>[
        'Travel',
        'Workspace',
        'Behind The Scenes',
        'Collabs',
      ];

  List<String> quickActions() {
    final current = user;
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
    if (!_followInitialized) {
      _followInitialized = true;
      await _followController.init();
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();
    try {
      if (userId != null && userId.trim().isNotEmpty) {
        user = await _repository.getProfileById(userId);
      } else {
        user = await _repository.getCurrentProfile();
      }
      _viewedUserId = user?.id ?? '';
      state = state.copyWith(
        isLoading: false,
        isSuccess: user != null,
        isEmpty: user == null,
      );
      await _analytics.profileViewed();
      notifyListeners();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Unable to load profile',
      );
      notifyListeners();
    }
  }

  Future<void> toggleFollow() async {
    final current = user;
    if (current == null || isOwnProfile) {
      return;
    }
    await _followController.toggleFollow(current);
    notifyListeners();
  }

  Future<void> requestDataExport() async {
    final current = user;
    if (current == null) {
      return;
    }
    final export = await _repository.buildDataExport(current);
    accountExportMessage =
        'Export requested at ${export['requestedAt']} for @${current.username}';
    notifyListeners();
  }

  List<UserModel> suggestedContacts() {
    final current = user;
    return MockData.users
        .where((item) => current == null || item.id != current.id)
        .take(3)
        .toList();
  }

  String verificationLabel() {
    final current = user;
    if (current == null) {
      return 'Verification unavailable';
    }
    return '${current.verificationStatus.toUpperCase()} • ${current.verificationReason ?? 'No reason provided'}';
  }

  Color badgeColor() {
    final current = user;
    switch (current?.badgeStyle) {
      case 'creator':
        return const Color(0xFFEAB308);
      case 'business':
        return const Color(0xFF2563EB);
      case 'seller':
        return const Color(0xFF059669);
      case 'recruiter':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF6B7280);
    }
  }

  List<String> roleSections() {
    final current = user;
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
