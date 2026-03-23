import '../enums/user_role.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.bio,
    required this.role,
    required this.followers,
    required this.following,
    this.isPrivate = false,
    this.verified = false,
  });

  final String id;
  final String name;
  final String username;
  final String avatar;
  final String bio;
  final UserRole role;
  final int followers;
  final int following;
  final bool isPrivate;
  final bool verified;
}
