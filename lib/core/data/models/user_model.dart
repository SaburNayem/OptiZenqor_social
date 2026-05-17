import '../../enums/user_role.dart';
import '../../helpers/media_url_resolver.dart';

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
    this.isOnline,
    this.lastSeen,
    this.status = 'Active',
    this.blocked = false,
    this.adminModeration = const <String, dynamic>{},
    this.restrictionActive = false,
    this.restrictionScope = const <String>[],
  });

  factory UserModel.fromApiJson(Map<String, dynamic> json) {
    final String username =
        _readString(json['username']) ??
        _readString(json['handle']) ??
        _readString(json['userName']) ??
        '';
    final String verificationStatus =
        (_readString(json['verificationStatus']) ??
                _readString(json['verification']) ??
                'not_requested')
            .toLowerCase()
            .replaceAll(' ', '_');
    final Map<String, dynamic> profileSetup =
        _readMap(json['profileSetup']) ?? const <String, dynamic>{};
    final Map<String, dynamic> adminModeration =
        _readMap(json['adminModeration']) ??
        _readMap(profileSetup['adminModeration']) ??
        const <String, dynamic>{};

    return UserModel(
      id: (json['id'] as Object? ?? json['_id'] as Object? ?? '').toString(),
      name:
          (_readString(json['name']) ??
                  _readString(json['displayName']) ??
                  _readString(json['fullName']) ??
                  _readString(json['authorName']) ??
                  _readString(json['username']) ??
                  'Unknown user')
              .replaceFirst('@', ''),
      username: username,
      avatar: MediaUrlResolver.resolve(
        _readString(json['avatar']) ??
            _readString(json['avatarUrl']) ??
            _readString(json['profileImage']) ??
            _readString(json['profileImageUrl']) ??
            _readString(json['photoUrl']) ??
            '',
      ),
      bio: _readString(json['bio']) ?? '',
      role: _parseRole(json['role']),
      followers: _readInt(json['followers']),
      following: _readInt(json['following']),
      website: _readString(json['website']) ?? '',
      location: _readString(json['location']) ?? '',
      coverImageUrl: MediaUrlResolver.resolve(
        _readString(json['coverImageUrl']) ??
            _readString(json['coverUrl']) ??
            _readString(json['coverPhotoUrl']) ??
            '',
      ),
      isPrivate: json['isPrivate'] as bool? ?? false,
      verified:
          json['verified'] as bool? ?? verificationStatus.contains('verified'),
      verificationStatus: verificationStatus,
      verificationReason: _readString(json['verificationReason']),
      badgeStyle: _readString(json['badgeStyle']) ?? 'standard',
      publicProfileUrl:
          _readString(json['publicProfileUrl']) ??
          (username.isEmpty ? '' : 'https://optizenqor.app/@$username'),
      profilePreview: _readString(json['profilePreview']) ?? '',
      note: _readString(json['note']),
      notePrivacy: _readString(json['notePrivacy']) ?? 'followers',
      supporterBadge: json['supporterBadge'] as bool? ?? false,
      isOnline: _readBool(
        json['isOnline'] ??
            json['online'] ??
            json['isActive'] ??
            json['active'] ??
            json['presence'],
      ),
      lastSeen: _readDateTime(
        json['lastSeen'] ??
            json['lastActiveAt'] ??
            json['lastSeenAt'] ??
            json['lastOnlineAt'],
      ),
      status: _readString(json['status']) ?? 'Active',
      blocked: _readBool(json['blocked']) ?? false,
      adminModeration: adminModeration,
      restrictionActive:
          _readBool(json['restrictionActive'] ?? adminModeration['active']) ??
          false,
      restrictionScope: _readStringList(
        json['restrictionScope'] ?? adminModeration['restrictionScope'],
      ),
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
  final bool? isOnline;
  final DateTime? lastSeen;
  final String status;
  final bool blocked;
  final Map<String, dynamic> adminModeration;
  final bool restrictionActive;
  final List<String> restrictionScope;

  bool get isAccountSuspended {
    final String action = (_readString(adminModeration['action']) ?? '')
        .toLowerCase();
    final bool active = _readBool(adminModeration['active']) ?? false;
    final bool activeSuspension =
        _readBool(adminModeration['activeSuspension']) ?? false;
    return action == 'suspend' &&
        (active ||
            activeSuspension ||
            blocked ||
            status.toLowerCase() == 'suspended');
  }

  String? get suspensionReason =>
      _readString(adminModeration['reason']) ??
      _readString(adminModeration['restrictionReason']);

  DateTime? get suspendedUntil =>
      _readDateTime(adminModeration['suspendedUntil']);

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
    bool? isOnline,
    DateTime? lastSeen,
    String? status,
    bool? blocked,
    Map<String, dynamic>? adminModeration,
    bool? restrictionActive,
    List<String>? restrictionScope,
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
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
      blocked: blocked ?? this.blocked,
      adminModeration: adminModeration ?? this.adminModeration,
      restrictionActive: restrictionActive ?? this.restrictionActive,
      restrictionScope: restrictionScope ?? this.restrictionScope,
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
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'status': status,
      'blocked': blocked,
      'adminModeration': adminModeration,
      'restrictionActive': restrictionActive,
      'restrictionScope': restrictionScope,
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

  static UserRole _parseRole(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'user':
        return UserRole.user;
      case 'creator':
        return UserRole.creator;
      case 'business':
      case 'seller':
      case 'recruiter':
        return UserRole.business;
      case 'admin':
        return UserRole.admin;
      case 'superadmin':
      case 'super admin':
        return UserRole.superadmin;
      default:
        return UserRole.guest;
    }
  }

  static bool? _readBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final String normalized = (value?.toString() ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    if (<String>{
      'true',
      '1',
      'yes',
      'online',
      'active',
      'available',
    }.contains(normalized)) {
      return true;
    }
    if (<String>{
      'false',
      '0',
      'no',
      'offline',
      'inactive',
      'away',
    }.contains(normalized)) {
      return false;
    }
    return null;
  }

  static DateTime? _readDateTime(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static Map<String, dynamic>? _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static List<String> _readStringList(Object? value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    final String normalized = value?.toString().trim() ?? '';
    if (normalized.isEmpty) {
      return const <String>[];
    }
    return normalized
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static String? _readString(Object? value) {
    if (value == null) {
      return null;
    }
    final String normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }
}
