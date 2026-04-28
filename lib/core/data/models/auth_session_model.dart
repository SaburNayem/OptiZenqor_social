import 'user_model.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.isLoggedIn,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.role,
    required this.email,
    this.sessionId,
    this.user,
    this.endpoint,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? userJson = _readMap(
      json['user'] ?? json['currentUser'],
    );
    return AuthSessionModel(
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
      accessToken: (json['accessToken'] as String? ?? '').trim(),
      refreshToken: (json['refreshToken'] as String? ?? '').trim(),
      tokenType: (json['tokenType'] as String? ?? 'Bearer').trim(),
      role: (json['role'] as String? ?? '').trim(),
      email: (json['email'] as String? ?? '').trim(),
      sessionId: (json['sessionId'] as String?)?.trim(),
      user: userJson == null || userJson.isEmpty
          ? null
          : UserModel.fromApiJson(userJson),
      endpoint: (json['endpoint'] as String?)?.trim(),
    );
  }

  final bool isLoggedIn;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String role;
  final String email;
  final String? sessionId;
  final UserModel? user;
  final String? endpoint;

  bool get hasAccessToken => accessToken.isNotEmpty;
  bool get hasRefreshToken => refreshToken.isNotEmpty;
  bool get isUsable => isLoggedIn && hasAccessToken;

  AuthSessionModel copyWith({
    bool? isLoggedIn,
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    String? role,
    String? email,
    String? sessionId,
    UserModel? user,
    String? endpoint,
  }) {
    return AuthSessionModel(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      role: role ?? this.role,
      email: email ?? this.email,
      sessionId: sessionId ?? this.sessionId,
      user: user ?? this.user,
      endpoint: endpoint ?? this.endpoint,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isLoggedIn': isLoggedIn,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'role': role,
      'email': email,
      'sessionId': sessionId,
      'user': user?.toJson(),
      'endpoint': endpoint,
    };
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
}
