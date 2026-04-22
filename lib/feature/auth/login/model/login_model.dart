import '../../../../core/enums/user_role.dart';

class LoginModel {
  const LoginModel({
    required this.email,
    required this.password,
    required this.role,
  });

  final String email;
  final String password;
  final UserRole role;
}
