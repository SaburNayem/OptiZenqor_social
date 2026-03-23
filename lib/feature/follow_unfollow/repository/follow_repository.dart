import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/user_model.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../model/follow_state_model.dart';

class FollowRepository {
  FollowRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;
  final String _currentUserId = 'u1';

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
    return MockData.users.where((user) {
      if (user.id == _currentUserId) {
        return false;
      }
      final relation = state[userId];
      return relation?.isFollowing == true;
    }).toList();
  }

  List<UserModel> followingFor(String userId, Map<String, FollowStateModel> state) {
    if (userId != _currentUserId) {
      return const <UserModel>[];
    }
    return MockData.users.where((u) => state[u.id]?.isFollowing == true).toList();
  }

  List<UserModel> mutualConnections(String targetUserId, Map<String, FollowStateModel> state) {
    final following = followingFor(_currentUserId, state).map((u) => u.id).toSet();
    final followers = followersFor(targetUserId, state).map((u) => u.id).toSet();
    final mutualIds = following.intersection(followers);
    return MockData.users.where((u) => mutualIds.contains(u.id)).toList();
  }
}
