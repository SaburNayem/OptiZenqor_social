import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../model/follow_state_model.dart';

class FollowRepository {
  FollowRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;
  final String _currentUserId = 'u1';
  static const Map<String, List<String>> _seedFollowing =
      <String, List<String>>{
        'u1': <String>['u2', 'u4'],
        'u2': <String>['u1', 'u4'],
        'u3': <String>['u1'],
        'u4': <String>['u1', 'u2'],
        'u5': <String>['u1', 'u2'],
      };

  Future<Map<String, FollowStateModel>> readFollowState() async {
    final raw = await _storage.readJsonList(StorageKeys.followState);
    final map = <String, FollowStateModel>{};
    for (final item in raw) {
      final state = FollowStateModel.fromMap(item);
      map[state.targetUserId] = state;
    }
    return map;
  }

  Future<void> persistFollowState(Map<String, FollowStateModel> state) async {
    await _storage.writeJsonList(
      StorageKeys.followState,
      state.values.map((item) => item.toMap()).toList(),
    );
  }

  String currentUserId() => _currentUserId;

  List<UserModel> followersFor(String userId, Map<String, FollowStateModel> state) {
    final followerIds = _seedFollowing.entries
        .where((entry) => entry.value.contains(userId))
        .map((entry) => entry.key)
        .toSet();

    final relation = state[userId];
    if (relation != null) {
      if (relation.isFollowing) {
        followerIds.add(_currentUserId);
      } else {
        followerIds.remove(_currentUserId);
      }
    }

    return MockData.users
        .where((user) => followerIds.contains(user.id))
        .toList(growable: false);
  }

  List<UserModel> followingFor(String userId, Map<String, FollowStateModel> state) {
    final followedIds = <String>{...?_seedFollowing[userId]};
    if (userId == _currentUserId) {
      for (final user in MockData.users) {
        if (user.id == _currentUserId) {
          continue;
        }
        final relation = state[user.id];
        if (relation == null) {
          continue;
        }
        if (relation.isFollowing) {
          followedIds.add(user.id);
        } else {
          followedIds.remove(user.id);
        }
      }
    }
    return MockData.users
        .where((user) => followedIds.contains(user.id))
        .toList(growable: false);
  }

  List<UserModel> mutualConnections(String targetUserId, Map<String, FollowStateModel> state) {
    final following = followingFor(_currentUserId, state).map((u) => u.id).toSet();
    final followers = followersFor(targetUserId, state).map((u) => u.id).toSet();
    final mutualIds = following.intersection(followers);
    return MockData.users.where((u) => mutualIds.contains(u.id)).toList();
  }

  bool isCurrentUserFollowing(String targetUserId) {
    return (_seedFollowing[_currentUserId] ?? const <String>[])
        .contains(targetUserId);
  }
}
