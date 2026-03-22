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
      });
    }
    return user;
  }
}
