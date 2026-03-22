import '../enums/user_role.dart';

class AuthService {
  bool _loggedIn = false;
  UserRole _role = UserRole.guest;

  bool get isLoggedIn => _loggedIn;
  UserRole get role => _role;

  Future<void> login({required UserRole role}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _loggedIn = true;
    _role = role;
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _loggedIn = false;
    _role = UserRole.guest;
  }
}
