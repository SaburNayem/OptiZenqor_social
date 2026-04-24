import 'package:flutter/foundation.dart';

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

  Future<FollowStateModel> stateFor(UserModel user) async {
    final stored = _states[user.id];
    final bool remoteFollowing = await _repository.isCurrentUserFollowing(user.id);
    return FollowStateModel(
      targetUserId: user.id,
      isPrivateAccount: user.isPrivate,
      isFollowing: stored?.isFollowing ?? remoteFollowing,
      hasPendingRequest: stored?.hasPendingRequest ?? false,
    );
  }

  Future<void> toggleFollow(UserModel user) async {
    final FollowStateModel current = await stateFor(user);
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

  Future<List<UserModel>> followers(String userId) =>
      _repository.followersFor(userId, _states);

  Future<List<UserModel>> following(String userId) =>
      _repository.followingFor(userId, _states);

  Future<List<UserModel>> mutualConnections(String userId) =>
      _repository.mutualConnections(userId, _states);

  Future<String> currentUserId() => _repository.currentUserId();
}
