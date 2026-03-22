import 'package:flutter/foundation.dart';

import '../../../core/common_models/load_state_model.dart';
import '../../../core/common_models/post_model.dart';
import '../../../core/common_models/reel_model.dart';
import '../../../core/common_models/user_model.dart';
import '../../../core/common_data/mock_data.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/services/analytics_service.dart';
import '../repository/user_profile_repository.dart';

class UserProfileController extends ChangeNotifier {
  UserProfileController({
    UserProfileRepository? repository,
    AnalyticsService? analytics,
  })  : _repository = repository ?? UserProfileRepository(),
        _analytics = analytics ?? AnalyticsService();

  final UserProfileRepository _repository;
  final AnalyticsService _analytics;

  LoadStateModel state = const LoadStateModel();
  UserModel? user;
  String _viewedUserId = '';
  int selectedTabIndex = 0;

  bool get isOwnProfile {
    final currentUserId = _repository.getCurrentUserId();
    return currentUserId.isNotEmpty && _viewedUserId == currentUserId;
  }

  List<String> get profileTabs {
    return <String>['Posts', 'Reels', ...roleSections()];
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
