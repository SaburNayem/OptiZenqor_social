import 'package:flutter/foundation.dart';

import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/user_model.dart';
import '../model/follow_state_model.dart';
import '../repository/follow_repository.dart';

class FollowController extends ChangeNotifier {
  FollowController({FollowRepository? repository})
      : _repository = repository ?? FollowRepository();

  final FollowRepository _repository;
  Map<String, FollowStateModel> _states = <String, FollowStateModel>{};

  Future<void> init() async {
    _states = await _repository.readFollowState();
    notifyListeners();
  }

  FollowStateModel stateFor(UserModel user) {
    return _states[user.id] ?? FollowStateModel(
      targetUserId: user.id,
      isPrivateAccount: user.isPrivate,
    );
  }

  Future<void> toggleFollow(UserModel user) async {
    final current = stateFor(user);
    if (current.isPrivateAccount && !current.isFollowing) {
      _states[user.id] = current.copyWith(hasPendingRequest: !current.hasPendingRequest);
    } else {
      _states[user.id] = current.copyWith(
        isFollowing: !current.isFollowing,
        hasPendingRequest: false,
      );
    }
    await _repository.persistFollowState(_states);
    notifyListeners();
  }

  List<UserModel> followers(String userId) => _repository.followersFor(userId, _states);

  List<UserModel> following(String userId) => _repository.followingFor(userId, _states);

  List<UserModel> mutualConnections(String userId) =>
      _repository.mutualConnections(userId, _states);

  UserModel currentUser() {
    return MockData.users.firstWhere((u) => u.id == _repository.currentUserId());
  }
}
