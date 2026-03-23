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
    this.verificationStatus = 'not_requested',
    this.verificationReason,
    this.badgeStyle = 'standard',
    this.publicProfileUrl = '',
    this.profilePreview = '',
    this.note,
    this.notePrivacy = 'followers',
    this.supporterBadge = false,
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
  final String verificationStatus;
  final String? verificationReason;
  final String badgeStyle;
  final String publicProfileUrl;
  final String profilePreview;
  final String? note;
  final String notePrivacy;
  final bool supporterBadge;
}
