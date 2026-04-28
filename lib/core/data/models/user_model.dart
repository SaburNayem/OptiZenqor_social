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
    this.website = '',
    this.location = '',
    this.coverImageUrl = '',
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
    final String username =
        (json['username'] as String? ??
                json['handle'] as String? ??
                json['userName'] as String? ??
                '')
            .trim()
            .replaceFirst('@', '');
    final String verificationStatus =
        ((json['verificationStatus'] ?? json['verification']) as String? ??
                'not_requested')
            .trim()
            .toLowerCase()
            .replaceAll(' ', '_');

    return UserModel(
      id: (json['id'] as Object? ?? json['_id'] as Object? ?? '').toString(),
      name:
          (json['name'] as String? ??
                  json['displayName'] as String? ??
                  json['fullName'] as String? ??
                  json['authorName'] as String? ??
                  json['username'] as String? ??
                  'Unknown user')
              .trim()
              .replaceFirst('@', ''),
      username: username,
      avatar: _sanitizeImageUrl(
        (json['avatar'] as String? ??
                json['avatarUrl'] as String? ??
                json['profileImage'] as String? ??
                json['profileImageUrl'] as String? ??
                json['photoUrl'] as String? ??
                '')
            .trim(),
      ),
      bio: (json['bio'] as String? ?? '').trim(),
      role: _parseRole(json['role']),
      followers: _readInt(json['followers']),
      following: _readInt(json['following']),
      website: (json['website'] as String? ?? '').trim(),
      location: (json['location'] as String? ?? '').trim(),
      coverImageUrl:
          (json['coverImageUrl'] as String? ??
                  json['coverUrl'] as String? ??
                  json['coverPhotoUrl'] as String? ??
                  '')
              .trim(),
      isPrivate: json['isPrivate'] as bool? ?? false,
      verified:
          json['verified'] as bool? ?? verificationStatus.contains('verified'),
      verificationStatus: verificationStatus,
      verificationReason: json['verificationReason'] as String?,
      badgeStyle: (json['badgeStyle'] as String? ?? 'standard').trim(),
      publicProfileUrl:
          (json['publicProfileUrl'] as String? ??
                  (username.isEmpty ? '' : 'https://optizenqor.app/@$username'))
              .trim(),
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
  final String website;
  final String location;
  final String coverImageUrl;
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

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? avatar,
    String? bio,
    UserRole? role,
    int? followers,
    int? following,
    String? website,
    String? location,
    String? coverImageUrl,
    bool? isPrivate,
    bool? verified,
    String? verificationStatus,
    String? verificationReason,
    String? badgeStyle,
    String? publicProfileUrl,
    String? profilePreview,
    String? note,
    String? notePrivacy,
    bool? supporterBadge,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      website: website ?? this.website,
      location: location ?? this.location,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      verified: verified ?? this.verified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationReason: verificationReason ?? this.verificationReason,
      badgeStyle: badgeStyle ?? this.badgeStyle,
      publicProfileUrl: publicProfileUrl ?? this.publicProfileUrl,
      profilePreview: profilePreview ?? this.profilePreview,
      note: note ?? this.note,
      notePrivacy: notePrivacy ?? this.notePrivacy,
      supporterBadge: supporterBadge ?? this.supporterBadge,
    );
  }

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
      'website': website,
      'location': location,
      'coverImageUrl': coverImageUrl,
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
    if (value is List) {
      return value.length;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _sanitizeImageUrl(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final Uri? uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return trimmed;
    }
    if (uri.host.toLowerCase() != 'placehold.co') {
      return trimmed;
    }
    final String path = uri.path.toLowerCase();
    if (path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp')) {
      return trimmed;
    }
    return '$trimmed/png';
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
