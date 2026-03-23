import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/user_model.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';

class UserProfileRepository {
  UserProfileRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  Future<UserModel?> getCurrentProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final user = MockData.users.firstOrNull;
    if (user != null) {
      await _cacheProfile(user);
    }
    return user;
  }

  Future<UserModel?> getProfileById(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final user = MockData.users.where((item) => item.id == userId).firstOrNull;
    if (user != null) {
      await _cacheProfile(user);
    }
    return user;
  }

  String getCurrentUserId() {
    return MockData.users.firstOrNull?.id ?? '';
  }

  Future<List<UserModel>> suggestedContacts({String? excludeUserId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return MockData.users
        .where((item) => item.id != excludeUserId)
        .take(4)
        .toList();
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
        .toList();
  }

  List<String> mentionHistory(String userId) {
    final username = MockData.users
        .where((item) => item.id == userId)
        .firstOrNull
        ?.username;
    if (username == null) {
      return const <String>[];
    }
    return MockData.posts
        .where((post) => post.mentionUsernames.contains(username))
        .map((post) => '@$username mentioned in "${post.caption}"')
        .toList();
  }

  Future<Map<String, dynamic>> buildDataExport(UserModel user) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final export = <String, dynamic>{
      'userId': user.id,
      'username': user.username,
      'requestedAt': DateTime.now().toIso8601String(),
      'posts': MockData.posts.where((item) => item.authorId == user.id).length,
      'reels': MockData.reels.where((item) => item.authorId == user.id).length,
      'followers': user.followers,
      'following': user.following,
      'verificationStatus': user.verificationStatus,
    };
    final requests = await _storage.readJsonList(StorageKeys.dataExportRequests);
    await _storage.writeJsonList(
      StorageKeys.dataExportRequests,
      <Map<String, dynamic>>[export, ...requests],
    );
    return export;
  }

  Future<void> _cacheProfile(UserModel user) async {
    await _storage.writeJson(StorageKeys.cachedProfile, {
      'id': user.id,
      'name': user.name,
      'username': user.username,
      'avatar': user.avatar,
      'bio': user.bio,
      'role': user.role.name,
      'followers': user.followers,
      'following': user.following,
      'verified': user.verified,
      'verificationStatus': user.verificationStatus,
      'verificationReason': user.verificationReason,
      'badgeStyle': user.badgeStyle,
      'publicProfileUrl': user.publicProfileUrl,
      'profilePreview': user.profilePreview,
      'note': user.note,
      'notePrivacy': user.notePrivacy,
      'supporterBadge': user.supporterBadge,
    });
  }
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
