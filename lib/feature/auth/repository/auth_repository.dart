import '../../../core/constants/storage_keys.dart';
import '../../../core/data/shared_preference/app_shared_preferences.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/data/service/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  AuthRepository({AuthService? authService, AppSharedPreferences? storage})
    : _authService = authService ?? AuthService(),
      _storage = storage ?? AppSharedPreferences();

  final AuthService _authService;
  final AppSharedPreferences _storage;

  Future<void> login({
    required UserRole role,
    required String email,
    required String password,
  }) async {
    debugPrint('[AuthRepository] login start role=${role.name}');
    final response = await _authService.login(
      role: role,
      email: email,
      password: password,
    );
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Login failed.');
    }
    debugPrint('[AuthRepository] AuthService.login success');
    debugPrint(
      '[AuthRepository] Session persisted key=${StorageKeys.authSession}',
    );
  }

  Future<void> logout() async {
    await _authService.logout();
    await _storage.remove(StorageKeys.authSession);
  }

  Future<bool> hasSession() async {
    final session = await _storage.readJson(StorageKeys.authSession);
    return (session?['isLoggedIn'] as bool?) ?? false;
  }
}
