import '../../../../core/enums/user_role.dart';

class SignupModel {
  const SignupModel({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.interests = const <String>[],
  });

  final String name;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final UserRole role;
  final String? avatarUrl;
  final String? bio;
  final List<String> interests;
}
