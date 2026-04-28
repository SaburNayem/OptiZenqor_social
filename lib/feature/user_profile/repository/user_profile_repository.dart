import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/reel_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service/auth_session_service.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../../../core/enums/user_role.dart';
import '../model/profile_update_model.dart';
import '../service/user_profile_service.dart';

class UserProfileRepository {
  UserProfileRepository({
    LocalStorageService? storage,
    UserProfileService? service,
    AuthSessionService? sessionService,
  }) : _storage = storage ?? LocalStorageService(),
       _service = service ?? UserProfileService(),
       _sessionService = sessionService ?? AuthSessionService();

  final LocalStorageService _storage;
  final UserProfileService _service;
  final AuthSessionService _sessionService;

  Future<UserModel?> getCurrentProfile() async {
    final UserModel? apiUser = await _fetchCurrentProfileFromApi();
    if (apiUser != null) {
      await _cacheProfile(apiUser);
      await _persistUserInSession(apiUser);
      return apiUser;
    }
    return readCachedProfile();
  }

  Future<UserModel?> getProfileById(String userId) async {
    final String trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      return getCurrentProfile();
    }

    final UserModel? apiUser = await _fetchProfileByIdFromApi(trimmedUserId);
    if (apiUser != null) {
      final String currentUserId = await getCurrentUserId();
      if (currentUserId.isNotEmpty && currentUserId == apiUser.id) {
        await _cacheProfile(apiUser);
        await _persistUserInSession(apiUser);
      }
      return apiUser;
    }

    final UserModel? cached = await readCachedProfile();
    if (cached != null && cached.id == trimmedUserId) {
      return cached;
    }
    return null;
  }

  Future<String> getCurrentUserId() async {
    final Map<String, dynamic>? authSession = await _storage.readJson(
      StorageKeys.authSession,
    );
    final Map<String, dynamic>? sessionUser = _readMap(authSession?['user']);
    final String sessionUserId =
        (sessionUser?['id'] as Object? ?? '').toString().trim();
    if (sessionUserId.isNotEmpty) {
      return sessionUserId;
    }

    final Map<String, dynamic>? cachedProfile = await _storage.readJson(
      StorageKeys.cachedProfile,
    );
    return (cachedProfile?['id'] as Object? ?? '').toString().trim();
  }

  Future<List<UserModel>> suggestedContacts({String? excludeUserId}) async {
    final List<UserModel>? remoteUsers = await _fetchUserList(
      ApiEndPoints.users,
      allowEmptyResult: true,
    );
    if (remoteUsers == null) {
      return const <UserModel>[];
    }
    return remoteUsers
        .where((UserModel item) => item.id != excludeUserId)
        .take(4)
        .toList(growable: false);
  }

  Future<List<PostModel>> getPostsByUser(String userId) async {
    final String trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      return const <PostModel>[];
    }
    final List<PostModel>? remotePosts = await _fetchPostList(
      ApiEndPoints.posts,
      userId: trimmedUserId,
    );
    return remotePosts ?? const <PostModel>[];
  }

  Future<List<ReelModel>> getReelsByUser(String userId) async {
    final String trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      return const <ReelModel>[];
    }
    final List<ReelModel>? remoteReels = await _fetchReelList(
      ApiEndPoints.reels,
      userId: trimmedUserId,
    );
    return remoteReels ?? const <ReelModel>[];
  }

  Future<List<UserModel>> getFollowers(String userId) async {
    final String trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      return const <UserModel>[];
    }

    for (final String endpoint in <String>[
      ApiEndPoints.userFollowers(trimmedUserId),
      ApiEndPoints.followUnfollowFollowers(trimmedUserId),
    ]) {
      final List<UserModel>? users = await _fetchUserList(
        endpoint,
        allowEmptyResult: true,
      );
      if (users != null) {
        return users;
      }
    }

    return const <UserModel>[];
  }

  Future<List<UserModel>> getFollowing(String userId) async {
    final String trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      return const <UserModel>[];
    }

    for (final String endpoint in <String>[
      ApiEndPoints.userFollowing(trimmedUserId),
      ApiEndPoints.followUnfollowFollowing(trimmedUserId),
    ]) {
      final List<UserModel>? users = await _fetchUserList(
        endpoint,
        allowEmptyResult: true,
      );
      if (users != null) {
        return users;
      }
    }

    return const <UserModel>[];
  }

  Future<FollowRemoteState> getFollowState(String targetUserId) async {
    final String trimmedTargetUserId = targetUserId.trim();
    if (trimmedTargetUserId.isEmpty) {
      return const FollowRemoteState();
    }

    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.apiClient.get(ApiEndPoints.userFollowState(trimmedTargetUserId));
      if (!response.isSuccess || response.data['success'] == false) {
        return const FollowRemoteState();
      }
      return FollowRemoteState(
        isFollowing:
            _extractBoolean(
              response.data,
              const <String>['isFollowing', 'following', 'followed'],
            ) ??
            false,
        hasPendingRequest:
            _extractBoolean(
              response.data,
              const <String>[
                'hasPendingRequest',
                'pending',
                'requested',
                'requestPending',
              ],
            ) ??
            false,
      );
    } catch (_) {
      return const FollowRemoteState();
    }
  }

  Future<List<UserModel>> getMutualConnections(String userId) async {
    final String trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      return const <UserModel>[];
    }

    final List<UserModel>? users = await _fetchUserList(
      ApiEndPoints.followUnfollowMutuals(trimmedUserId),
      allowEmptyResult: true,
    );
    return users ?? const <UserModel>[];
  }

  Future<bool> isCurrentUserFollowing(String targetUserId) async {
    final FollowRemoteState state = await getFollowState(targetUserId);
    return state.isFollowing;
  }

  Future<FollowToggleResult> toggleFollow(
    UserModel user, {
    required bool isCurrentlyFollowing,
    required bool hasPendingRequest,
  }) async {
    final bool wantsPendingRequest =
        user.isPrivate && !isCurrentlyFollowing && !hasPendingRequest;
    final String endpoint = isCurrentlyFollowing
        ? ApiEndPoints.userUnfollow(user.id)
        : ApiEndPoints.userFollow(user.id);

    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.apiClient.post(endpoint, const <String, dynamic>{});
      if (response.isSuccess && response.data['success'] != false) {
        final bool resolvedIsFollowing = _extractBoolean(
              response.data,
              const <String>['isFollowing', 'following', 'followed'],
            ) ??
            (wantsPendingRequest ? false : !isCurrentlyFollowing);
        final bool resolvedPending = _extractBoolean(
              response.data,
              const <String>[
                'hasPendingRequest',
                'pending',
                'requested',
                'requestPending',
              ],
            ) ??
            (wantsPendingRequest && !resolvedIsFollowing);
        return FollowToggleResult(
          isFollowing: resolvedIsFollowing,
          hasPendingRequest: resolvedPending,
          syncedRemotely: true,
        );
      }
    } catch (_) {}

    return FollowToggleResult(
      isFollowing: isCurrentlyFollowing,
      hasPendingRequest: hasPendingRequest,
      syncedRemotely: false,
    );
  }

  Future<ProfileSaveResult> updateCurrentProfile(ProfileUpdateModel update) async {
    final UserModel mergedUser =
        (await getCurrentProfile()) ??
        UserModel(
          id: await getCurrentUserId(),
          name: update.name.trim(),
          username: update.username.trim(),
          avatar:
              update.avatarUrl?.trim().isNotEmpty == true
                  ? update.avatarUrl!.trim()
                  : 'https://placehold.co/120x120',
          bio: update.bio.trim(),
          role: UserRole.user,
          followers: 0,
          following: 0,
          website: update.website?.trim() ?? '',
          location: update.location?.trim() ?? '',
          coverImageUrl: update.coverImageUrl?.trim() ?? '',
          publicProfileUrl: update.username.trim().isEmpty
              ? ''
              : 'https://optizenqor.app/@${update.username.trim()}',
        );

    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.patchEndpoint(
            'edit_profile',
            payload: update.toPayload(),
          );
      if (response.isSuccess && response.data['success'] != false) {
        final UserModel savedUser = _extractUserFromPayload(response.data) ?? mergedUser;
        await _cacheProfile(savedUser);
        await _persistUserInSession(savedUser);
        return ProfileSaveResult(
          user: savedUser,
          savedRemotely: true,
          message: response.message ?? 'Profile updated successfully.',
        );
      }
    } catch (_) {}

    await _cacheProfile(mergedUser);
    await _persistUserInSession(mergedUser);
    return ProfileSaveResult(
      user: mergedUser,
      savedRemotely: false,
      message: 'Profile update could not be synced right now.',
    );
  }

  Future<List<PostTagSummary>> taggedPostSummaries(String userId) async {
    final String trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      return const <PostTagSummary>[];
    }

    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.apiClient.get(ApiEndPoints.profileTaggedPosts(trimmedUserId));
      if (!response.isSuccess || response.data['success'] == false) {
        return const <PostTagSummary>[];
      }
      return _readMapList(response.data)
          .map(
            (Map<String, dynamic> item) => PostTagSummary(
              id: (item['id'] as Object? ?? '').toString(),
              title: (item['title'] as Object? ?? '').toString(),
              location: item['location']?.toString(),
              mediaCount: _readInt(item['mediaCount']),
            ),
          )
          .where((PostTagSummary item) => item.id.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const <PostTagSummary>[];
    }
  }

  Future<List<String>> mentionHistory(String userId) async {
    final String trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      return const <String>[];
    }

    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.apiClient.get(ApiEndPoints.profileMentionHistory(trimmedUserId));
      if (!response.isSuccess || response.data['success'] == false) {
        return const <String>[];
      }
      final List<Map<String, dynamic>> items = _readMapList(response.data);
      if (items.isNotEmpty) {
        return items
            .map((Map<String, dynamic> item) => (item['message'] as Object? ?? '').toString().trim())
            .where((String item) => item.isNotEmpty)
            .toList(growable: false);
      }
      final List<String> rawItems = _readStringList(response.data);
      return rawItems.where((String item) => item.trim().isNotEmpty).toList(growable: false);
    } catch (_) {
      return const <String>[];
    }
  }

  Future<Map<String, dynamic>> buildDataExport(UserModel user) async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.apiClient.post(
            ApiEndPoints.legalDataExport,
            <String, dynamic>{'userId': user.id},
          );
      if (response.isSuccess && response.data['success'] != false) {
        final List<Map<String, dynamic>> requests = await _storage.readJsonList(
          StorageKeys.dataExportRequests,
        );
        await _storage.writeJsonList(
          StorageKeys.dataExportRequests,
          <Map<String, dynamic>>[response.data, ...requests],
        );
        return response.data;
      }
    } catch (_) {}

    return <String, dynamic>{
      'userId': user.id,
      'username': user.username,
      'requestedAt': DateTime.now().toIso8601String(),
      'status': 'failed',
      'message': 'Unable to request export right now.',
    };
  }

  Future<UserModel?> readCachedProfile() async {
    final Map<String, dynamic>? cached = await _storage.readJson(
      StorageKeys.cachedProfile,
    );
    if (cached == null || cached.isEmpty) {
      return null;
    }
    return UserModel.fromApiJson(cached);
  }

  Future<UserModel?> _fetchCurrentProfileFromApi() async {
    for (final String endpoint in <String>[
      ApiEndPoints.authMe,
      ApiEndPoints.profile,
      ApiEndPoints.userProfile,
    ]) {
      final UserModel? user = await _fetchUser(endpoint);
      if (user != null) {
        return user;
      }
    }
    return null;
  }

  Future<UserModel?> _fetchProfileByIdFromApi(String userId) async {
    for (final String endpoint in <String>[
      ApiEndPoints.profileById(userId),
      ApiEndPoints.userProfileById(userId),
      ApiEndPoints.userById(userId),
    ]) {
      final UserModel? user = await _fetchUser(endpoint);
      if (user != null) {
        return user;
      }
    }
    return null;
  }

  Future<UserModel?> _fetchUser(String endpoint) async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.apiClient.get(endpoint);
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
      }
      return _extractUserFromPayload(response.data);
    } catch (_) {
      return null;
    }
  }

  Future<List<UserModel>?> _fetchUserList(
    String endpoint, {
    bool allowEmptyResult = false,
  }) async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.apiClient.get(endpoint);
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
      }
      final List<UserModel> users = _readMapList(
        response.data,
      ).map(UserModel.fromApiJson).toList(growable: false);
      if (users.isNotEmpty || allowEmptyResult) {
        return users;
      }
    } catch (_) {}
    return null;
  }

  Future<List<PostModel>?> _fetchPostList(
    String endpoint, {
    required String userId,
  }) async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.apiClient.get(endpoint);
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
      }
      return _readMapList(response.data)
          .map(PostModel.fromApiJson)
          .where((PostModel post) => post.authorId == userId)
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<List<ReelModel>?> _fetchReelList(
    String endpoint, {
    required String userId,
  }) async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.apiClient.get(endpoint);
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
      }
      return _readMapList(response.data)
          .map(ReelModel.fromApiJson)
          .where((ReelModel reel) => reel.authorId == userId)
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  UserModel? _extractUserFromPayload(Map<String, dynamic> payload) {
    final List<Map<String, dynamic>?> candidates = <Map<String, dynamic>?>[
      payload,
      _readMap(payload['user']),
      _readMap(payload['profile']),
      _readMap(payload['data']),
      _readMap(payload['result']),
      _readMap(_readMap(payload['data'])?['user']),
      _readMap(_readMap(payload['data'])?['profile']),
      _readMap(_readMap(payload['result'])?['user']),
      _readMap(_readMap(payload['result'])?['profile']),
    ];

    for (final Map<String, dynamic>? candidate in candidates) {
      if (candidate == null || !_looksLikeUser(candidate)) {
        continue;
      }
      return UserModel.fromApiJson(candidate);
    }
    return null;
  }

  bool _looksLikeUser(Map<String, dynamic> payload) {
    return payload.containsKey('id') ||
        payload.containsKey('username') ||
        payload.containsKey('name') ||
        payload.containsKey('avatar') ||
        payload.containsKey('avatarUrl');
  }

  List<Map<String, dynamic>> _readMapList(Map<String, dynamic> payload) {
    for (final Object? raw in <Object?>[
      payload['data'],
      payload['items'],
      payload['results'],
      payload['value'],
      payload['users'],
      payload['followers'],
      payload['following'],
      payload['mutuals'],
      _readMap(payload['data'])?['items'],
      _readMap(payload['data'])?['results'],
      _readMap(payload['data'])?['users'],
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

  List<String> _readStringList(Map<String, dynamic> payload) {
    for (final Object? raw in <Object?>[
      payload['data'],
      payload['items'],
      payload['results'],
      payload['value'],
      _readMap(payload['data'])?['items'],
      _readMap(payload['data'])?['results'],
      _readMap(payload['data'])?['value'],
    ]) {
      if (raw is! List) {
        continue;
      }
      return raw
          .map((Object? item) => item?.toString() ?? '')
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
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

  int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _cacheProfile(UserModel user) async {
    await _storage.writeJson(StorageKeys.cachedProfile, user.toJson());
  }

  Future<void> _persistUserInSession(UserModel user) async {
    await _sessionService.updateUser(user, role: user.role.name);
  }
}

class ProfileSaveResult {
  const ProfileSaveResult({
    required this.user,
    required this.savedRemotely,
    required this.message,
  });

  final UserModel user;
  final bool savedRemotely;
  final String message;
}

class FollowToggleResult {
  const FollowToggleResult({
    required this.isFollowing,
    required this.hasPendingRequest,
    required this.syncedRemotely,
  });

  final bool isFollowing;
  final bool hasPendingRequest;
  final bool syncedRemotely;
}

class FollowRemoteState {
  const FollowRemoteState({
    this.isFollowing = false,
    this.hasPendingRequest = false,
  });

  final bool isFollowing;
  final bool hasPendingRequest;
}

class PostTagSummary {
  const PostTagSummary({
    required this.id,
    required this.title,
    required this.location,
    required this.mediaCount,
  });

  final String id;
  final String title;
  final String? location;
  final int mediaCount;
}
