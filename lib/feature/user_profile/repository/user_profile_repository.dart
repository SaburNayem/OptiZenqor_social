import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/reel_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/profile_update_model.dart';
import '../service/user_profile_service.dart';

class UserProfileRepository {
  UserProfileRepository({
    LocalStorageService? storage,
    UserProfileService? service,
  }) : _storage = storage ?? LocalStorageService(),
       _service = service ?? UserProfileService();

  final LocalStorageService _storage;
  final UserProfileService _service;

  static const Map<String, List<String>> _seedFollowing =
      <String, List<String>>{
        'u1': <String>['u2', 'u4'],
        'u2': <String>['u1', 'u4'],
        'u3': <String>['u1'],
        'u4': <String>['u1', 'u2'],
        'u5': <String>['u1', 'u2'],
      };

  Future<UserModel?> getCurrentProfile() async {
    final UserModel? apiUser = await _fetchCurrentProfileFromApi();
    if (apiUser != null) {
      await _cacheProfile(apiUser);
      await _persistUserInSession(apiUser);
      return apiUser;
    }

    final UserModel? cached = await readCachedProfile();
    if (cached != null) {
      return cached;
    }

    await Future<void>.delayed(const Duration(milliseconds: 180));
    final UserModel? user = MockData.users.firstOrNull;
    if (user != null) {
      await _cacheProfile(user);
    }
    return user;
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

    await Future<void>.delayed(const Duration(milliseconds: 160));
    return MockData.users.where((item) => item.id == trimmedUserId).firstOrNull;
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
    final String cachedProfileId =
        (cachedProfile?['id'] as Object? ?? '').toString().trim();
    if (cachedProfileId.isNotEmpty) {
      return cachedProfileId;
    }

    return MockData.users.firstOrNull?.id ?? '';
  }

  Future<List<UserModel>> suggestedContacts({String? excludeUserId}) async {
    final List<UserModel>? remoteUsers = await _fetchUserList(
      ApiEndPoints.users,
      allowEmptyResult: true,
    );
    if (remoteUsers != null) {
      return remoteUsers
          .where((item) => item.id != excludeUserId)
          .take(4)
          .toList(growable: false);
    }

    await Future<void>.delayed(const Duration(milliseconds: 120));
    return MockData.users
        .where((item) => item.id != excludeUserId)
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
    if (remotePosts != null) {
      return remotePosts;
    }

    return MockData.posts
        .where((PostModel post) => post.authorId == trimmedUserId)
        .toList(growable: false);
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
    if (remoteReels != null) {
      return remoteReels;
    }

    return MockData.reels
        .where((ReelModel reel) => reel.authorId == trimmedUserId)
        .toList(growable: false);
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

    return _localFollowersFor(trimmedUserId);
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

    return _localFollowingFor(trimmedUserId);
  }

  Future<bool> isCurrentUserFollowing(String targetUserId) async {
    final String currentUserId = await getCurrentUserId();
    if (currentUserId.isEmpty || currentUserId == targetUserId) {
      return false;
    }

    final List<UserModel> following = await getFollowing(currentUserId);
    return following.any((UserModel user) => user.id == targetUserId);
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
              const <String>[
                'isFollowing',
                'following',
                'followed',
              ],
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

    if (wantsPendingRequest) {
      return FollowToggleResult(
        isFollowing: false,
        hasPendingRequest: true,
        syncedRemotely: false,
      );
    }

    return FollowToggleResult(
      isFollowing: !isCurrentlyFollowing,
      hasPendingRequest: false,
      syncedRemotely: false,
    );
  }

  Future<ProfileSaveResult> updateCurrentProfile(ProfileUpdateModel update) async {
    final UserModel? currentUser = await getCurrentProfile();
    final UserModel mergedUser = (currentUser ?? MockData.users.first).copyWith(
      name: update.name.trim(),
      username: update.username.trim(),
      bio: update.bio.trim(),
      website: update.website?.trim() ?? '',
      location: update.location?.trim() ?? '',
      avatar: update.avatarUrl?.trim().isNotEmpty == true
          ? update.avatarUrl!.trim()
          : currentUser?.avatar ?? MockData.users.first.avatar,
      coverImageUrl: update.coverImageUrl?.trim().isNotEmpty == true
          ? update.coverImageUrl!.trim()
          : currentUser?.coverImageUrl ?? '',
      publicProfileUrl: update.username.trim().isEmpty
          ? currentUser?.publicProfileUrl ?? ''
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
      message: 'Profile changes saved locally.',
    );
  }

  List<PostTagSummary> taggedPostSummaries(String userId) {
    return MockData.posts
        .where((post) => post.taggedUserIds.contains(userId))
        .map(
          (post) => PostTagSummary(
            id: post.id,
            title: post.caption,
            location: post.location,
            mediaCount: post.media.length,
          ),
        )
        .toList(growable: false);
  }

  List<String> mentionHistory(String userId) {
    final String? username = MockData.users
        .where((item) => item.id == userId)
        .firstOrNull
        ?.username;
    if (username == null) {
      return const <String>[];
    }
    return MockData.posts
        .where((post) => post.mentionUsernames.contains(username))
        .map((post) => '@$username mentioned in "${post.caption}"')
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> buildDataExport(UserModel user) async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.apiClient.post(
            ApiEndPoints.legalDataExport,
            <String, dynamic>{'userId': user.id},
          );
      if (response.isSuccess && response.data['success'] != false) {
        return response.data;
      }
    } catch (_) {}

    await Future<void>.delayed(const Duration(milliseconds: 220));
    final Map<String, dynamic> export = <String, dynamic>{
      'userId': user.id,
      'username': user.username,
      'requestedAt': DateTime.now().toIso8601String(),
      'posts': MockData.posts.where((item) => item.authorId == user.id).length,
      'reels': MockData.reels.where((item) => item.authorId == user.id).length,
      'followers': user.followers,
      'following': user.following,
      'verificationStatus': user.verificationStatus,
    };
    final List<Map<String, dynamic>> requests = await _storage.readJsonList(
      StorageKeys.dataExportRequests,
    );
    await _storage.writeJsonList(
      StorageKeys.dataExportRequests,
      <Map<String, dynamic>>[export, ...requests],
    );
    return export;
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
    final Object? raw =
        payload['data'] ??
        payload['items'] ??
        payload['results'] ??
        payload['value'];
    if (raw is List) {
      return raw
          .whereType<Object>()
          .map(
            (Object item) => item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item as Map),
          )
          .toList(growable: false);
    }

    final Map<String, dynamic>? nestedData = _readMap(payload['data']);
    final Object? nestedList =
        nestedData?['items'] ?? nestedData?['results'] ?? nestedData?['users'];
    if (nestedList is List) {
      return nestedList
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

  bool? _extractBoolean(
    Map<String, dynamic> payload,
    List<String> keys,
  ) {
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

  List<UserModel> _localFollowersFor(String userId) {
    final Set<String> followerIds = _seedFollowing.entries
        .where((entry) => entry.value.contains(userId))
        .map((entry) => entry.key)
        .toSet();
    return MockData.users
        .where((UserModel user) => followerIds.contains(user.id))
        .toList(growable: false);
  }

  List<UserModel> _localFollowingFor(String userId) {
    final Set<String> followedIds = <String>{...?_seedFollowing[userId]};
    return MockData.users
        .where((UserModel user) => followedIds.contains(user.id))
        .toList(growable: false);
  }

  Future<void> _cacheProfile(UserModel user) async {
    await _storage.writeJson(StorageKeys.cachedProfile, user.toJson());
  }

  Future<void> _persistUserInSession(UserModel user) async {
    final Map<String, dynamic>? authSession = await _storage.readJson(
      StorageKeys.authSession,
    );
    if (authSession == null || authSession.isEmpty) {
      return;
    }
    await _storage.writeJson(StorageKeys.authSession, <String, dynamic>{
      ...authSession,
      'role': user.role.name,
      'user': user.toJson(),
    });
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
