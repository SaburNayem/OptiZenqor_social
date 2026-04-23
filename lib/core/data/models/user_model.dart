import '../../enums/user_role.dart';

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

  factory UserModel.fromApiJson(Map<String, dynamic> json) {
    final String username = (json['username'] as String? ?? '').trim();
    final String verificationStatus =
        ((json['verificationStatus'] ?? json['verification']) as String? ??
                'not_requested')
            .trim()
            .toLowerCase()
            .replaceAll(' ', '_');

    return UserModel(
      id: (json['id'] as Object? ?? '').toString(),
      name: (json['name'] as String? ?? 'Unknown user').trim(),
      username: username,
      avatar:
          (json['avatar'] as String? ??
                  json['avatarUrl'] as String? ??
                  'https://placehold.co/120x120')
              .trim(),
      bio: (json['bio'] as String? ?? '').trim(),
      role: _parseRole(json['role']),
      followers: _readInt(json['followers']),
      following: _readInt(json['following']),
      isPrivate: json['isPrivate'] as bool? ?? false,
      verified:
          json['verified'] as bool? ??
          verificationStatus.contains('verified'),
      verificationStatus: verificationStatus,
      verificationReason: json['verificationReason'] as String?,
      badgeStyle: (json['badgeStyle'] as String? ?? 'standard').trim(),
      publicProfileUrl: username.isEmpty ? '' : 'https://optizenqor.app/@$username',
      profilePreview: (json['profilePreview'] as String? ?? '').trim(),
      note: json['note'] as String?,
      notePrivacy: (json['notePrivacy'] as String? ?? 'followers').trim(),
      supporterBadge: json['supporterBadge'] as bool? ?? false,
    );
  }

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'avatar': avatar,
      'bio': bio,
      'role': role.name,
      'followers': followers,
      'following': following,
      'isPrivate': isPrivate,
      'verified': verified,
      'verificationStatus': verificationStatus,
      'verificationReason': verificationReason,
      'badgeStyle': badgeStyle,
      'publicProfileUrl': publicProfileUrl,
      'profilePreview': profilePreview,
      'note': note,
      'notePrivacy': notePrivacy,
      'supporterBadge': supporterBadge,
    };
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static UserRole _parseRole(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'user':
        return UserRole.user;
      case 'creator':
        return UserRole.creator;
      case 'business':
        return UserRole.business;
      case 'seller':
        return UserRole.seller;
      case 'recruiter':
        return UserRole.recruiter;
      default:
        return UserRole.guest;
    }
  }
}
