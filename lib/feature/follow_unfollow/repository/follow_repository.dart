import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service/api_client_service.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../model/follow_state_model.dart';

class FollowRepository {
  FollowRepository({LocalStorageService? storage, ApiClientService? apiClient})
    : _storage = storage ?? LocalStorageService(),
      _apiClient = apiClient ?? ApiClientService();

  final LocalStorageService _storage;
  final ApiClientService _apiClient;

  Future<Map<String, FollowStateModel>> readFollowState() async {
    final raw = await _storage.readJsonList(StorageKeys.followState);
    final Map<String, FollowStateModel> map = <String, FollowStateModel>{};
    for (final Map<String, dynamic> item in raw) {
      final FollowStateModel state = FollowStateModel.fromMap(item);
      map[state.targetUserId] = state;
    }
    return map;
  }

  Future<void> persistFollowState(Map<String, FollowStateModel> state) async {
    await _storage.writeJsonList(
      StorageKeys.followState,
      state.values.map((FollowStateModel item) => item.toMap()).toList(),
    );
  }

  Future<String> currentUserId() async {
    final Map<String, dynamic>? authSession = await _storage.readJson(
      StorageKeys.authSession,
    );
    final Object? user = authSession?['user'];
    if (user is Map<String, dynamic>) {
      return (user['id'] as Object? ?? '').toString().trim();
    }
    if (user is Map) {
      return (user['id'] as Object? ?? '').toString().trim();
    }
    return '';
  }

  Future<List<UserModel>> followersFor(
    String userId,
    Map<String, FollowStateModel> state,
  ) async {
    final List<UserModel> remoteUsers = await _fetchUserList(
      ApiEndPoints.userFollowers(userId),
    );
    if (remoteUsers.isNotEmpty) {
      return remoteUsers;
    }
    final List<UserModel> aliasUsers = await _fetchUserList(
      ApiEndPoints.followUnfollowFollowers(userId),
    );
    return aliasUsers;
  }

  Future<List<UserModel>> followingFor(
    String userId,
    Map<String, FollowStateModel> state,
  ) async {
    final List<UserModel> remoteUsers = await _fetchUserList(
      ApiEndPoints.userFollowing(userId),
    );
    if (remoteUsers.isNotEmpty) {
      return remoteUsers;
    }
    final List<UserModel> aliasUsers = await _fetchUserList(
      ApiEndPoints.followUnfollowFollowing(userId),
    );
    return aliasUsers;
  }

  Future<List<UserModel>> mutualConnections(
    String targetUserId,
    Map<String, FollowStateModel> state,
  ) async {
    return _fetchUserList(ApiEndPoints.followUnfollowMutuals(targetUserId));
  }

  Future<bool> isCurrentUserFollowing(String targetUserId) async {
    try {
      final response = await _apiClient.get(
        ApiEndPoints.userFollowState(targetUserId),
      );
      if (!response.isSuccess || response.data['success'] == false) {
        return false;
      }
      return _extractBoolean(response.data, const <String>[
            'isFollowing',
            'following',
            'followed',
          ]) ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<List<UserModel>> _fetchUserList(String endpoint) async {
    try {
      final response = await _apiClient.get(endpoint);
      if (!response.isSuccess || response.data['success'] == false) {
        return const <UserModel>[];
      }
      return _readMapList(response.data)
          .map(UserModel.fromApiJson)
          .where((UserModel user) => user.id.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const <UserModel>[];
    }
  }

  List<Map<String, dynamic>> _readMapList(Map<String, dynamic> payload) {
    for (final Object? raw in <Object?>[
      payload['data'],
      payload['items'],
      payload['results'],
      payload['followers'],
      payload['following'],
      payload['mutuals'],
      _readMap(payload['data'])?['followers'],
      _readMap(payload['data'])?['following'],
      _readMap(payload['data'])?['mutuals'],
    ]) {
      if (raw is! List) {
        continue;
      }
      return raw
          .whereType<Object>()
          .map(
            (Object item) => item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item as Map),
          )
          .toList(growable: false);
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  bool? _extractBoolean(Map<String, dynamic> payload, List<String> keys) {
    for (final String key in keys) {
      final Object? value = payload[key];
      if (value is bool) {
        return value;
      }
      if (value is String) {
        final String normalized = value.trim().toLowerCase();
        if (normalized == 'true') {
          return true;
        }
        if (normalized == 'false') {
          return false;
        }
      }
    }
    final Map<String, dynamic>? nestedData = _readMap(payload['data']);
    if (nestedData != null) {
      return _extractBoolean(nestedData, keys);
    }
    return null;
  }
}
