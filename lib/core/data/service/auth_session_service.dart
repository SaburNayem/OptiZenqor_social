import '../../constants/storage_keys.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';
import '../shared_preference/app_shared_preferences.dart';

class AuthSessionService {
  AuthSessionService({AppSharedPreferences? storage})
    : _storage = storage ?? AppSharedPreferences();

  final AppSharedPreferences _storage;

  Future<AuthSessionModel?> readSession() async {
    final Map<String, dynamic>? sessionJson = await _storage.readJson(
      StorageKeys.authSession,
    );
    if (sessionJson == null || sessionJson.isEmpty) {
      return null;
    }
    final AuthSessionModel session = AuthSessionModel.fromJson(sessionJson);
    if (session.isUsable) {
      return session;
    }

    final String accessToken =
        (await _storage.read<String>(StorageKeys.accessToken) ?? '').trim();
    if (accessToken.isEmpty) {
      return session;
    }

    final String refreshToken =
        (await _storage.read<String>(StorageKeys.refreshToken) ?? '').trim();
    final Map<String, dynamic>? userJson = await _storage.readJson(
      StorageKeys.currentUser,
    );
    return session.copyWith(
      isLoggedIn: true,
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: userJson == null || userJson.isEmpty
          ? session.user
          : UserModel.fromApiJson(userJson),
    );
  }

  Future<void> persistSession(AuthSessionModel session) async {
    await Future.wait<void>(<Future<void>>[
      _storage.writeJson(StorageKeys.authSession, session.toJson()),
      _storage.write(StorageKeys.accessToken, session.accessToken),
      _storage.write(StorageKeys.refreshToken, session.refreshToken),
      if (session.user != null)
        _storage.writeJson(StorageKeys.currentUser, session.user!.toJson()),
    ]);
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
    String? tokenType,
  }) async {
    final AuthSessionModel? existing = await readSession();
    if (existing == null) {
      return;
    }
    await persistSession(
      existing.copyWith(
        isLoggedIn: true,
        accessToken: accessToken.trim(),
        refreshToken: refreshToken.trim(),
        tokenType: (tokenType ?? existing.tokenType).trim(),
      ),
    );
  }

  Future<void> updateUser(UserModel user, {String? role, String? email}) async {
    final AuthSessionModel? existing = await readSession();
    if (existing == null) {
      await _storage.writeJson(StorageKeys.currentUser, user.toJson());
      return;
    }
    await persistSession(
      existing.copyWith(
        user: user,
        role: (role ?? existing.role).trim(),
        email: (email ?? existing.email).trim(),
      ),
    );
  }

  Future<void> clear() async {
    await Future.wait<void>(<Future<void>>[
      _storage.remove(StorageKeys.authSession),
      _storage.remove(StorageKeys.accessToken),
      _storage.remove(StorageKeys.refreshToken),
      _storage.remove(StorageKeys.currentUser),
    ]);
  }
}
