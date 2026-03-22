import '../../../core/constants/storage_keys.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/local_storage_service.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  AuthRepository({
    AuthService? authService,
    LocalStorageService? storage,
  })  : _authService = authService ?? AuthService(),
        _storage = storage ?? LocalStorageService();

  final AuthService _authService;
  final LocalStorageService _storage;

  Future<void> login(UserRole role) async {
    debugPrint('[AuthRepository] login start role=${role.name}');
    await _authService.login(role: role);
    debugPrint('[AuthRepository] AuthService.login success');
    await _storage.writeJson(StorageKeys.authSession, {
      'isLoggedIn': true,
      'role': role.name,
    });
    debugPrint('[AuthRepository] Session persisted key=${StorageKeys.authSession}');
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
