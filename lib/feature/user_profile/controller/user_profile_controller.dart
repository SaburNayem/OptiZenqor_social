import 'package:flutter/foundation.dart';

import '../../../core/common_models/load_state_model.dart';
import '../../../core/common_models/user_model.dart';
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

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();
    try {
      user = await _repository.getCurrentProfile();
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
