import '../../constants/storage_keys.dart';
import '../../enums/user_role.dart';
import '../../socket/socket_service.dart';
import '../../data/shared_preference/app_shared_preferences.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';
import '../api/api_end_points.dart';
import '../service_model/service_response_model.dart';
import 'api_client_service.dart';
import 'auth_session_service.dart';
import 'user_data_cleanup_service.dart';

class AuthService {
  AuthService({
    ApiClientService? apiClient,
    AppSharedPreferences? storage,
    UserDataCleanupService? cleanupService,
    AuthSessionService? sessionService,
  }) : _apiClient = apiClient ?? ApiClientService(),
       _storage = storage ?? AppSharedPreferences(),
       _sessionService =
           sessionService ??
           AuthSessionService(storage: storage ?? AppSharedPreferences()),
       _cleanupService =
           cleanupService ?? UserDataCleanupService(storage: storage);

  final ApiClientService _apiClient;
  final AppSharedPreferences _storage;
  final AuthSessionService _sessionService;
  final UserDataCleanupService _cleanupService;

  bool _loggedIn = false;
  UserRole _role = UserRole.guest;

  bool get isLoggedIn => _loggedIn;
  UserRole get role => _role;

  Future<ServiceResponseModel<Map<String, dynamic>>> login({
    required UserRole role,
    String? email,
    String? password,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .post(ApiEndPoints.authLogin, <String, dynamic>{
          'email': email ?? '',
          'password': password ?? '',
        });
    await _persistAuthSessionIfAvailable(
      response,
      endpoint: ApiEndPoints.authLogin,
      fallbackEmail: email,
      fallbackRole: role,
    );
    return response;
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> signup({
    required String name,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required UserRole role,
    String? avatarUrl,
    String? bio,
    List<String>? interests,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'role': _formatSignupRole(role),
      if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
        'avatarUrl': avatarUrl.trim(),
      if (bio != null && bio.trim().isNotEmpty) 'bio': bio.trim(),
      if (interests != null && interests.isNotEmpty) 'interests': interests,
    };
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .post(ApiEndPoints.authSignup, payload);
    await _persistAuthSessionIfAvailable(
      response,
      endpoint: ApiEndPoints.authSignup,
      fallbackEmail: email,
      fallbackRole: role,
    );
    return response;
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) {
    return _apiClient.post(ApiEndPoints.authForgotPassword, <String, dynamic>{
      'email': email,
    });
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) {
    return _apiClient.post(ApiEndPoints.authResetPassword, <String, dynamic>{
      'email': email,
      'otp': otp,
      'password': password,
    });
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> sendOtp({
    required String destination,
    String channel = 'email',
  }) {
    return _apiClient.post(ApiEndPoints.authSendOtp, <String, dynamic>{
      'destination': destination,
      'channel': channel,
    });
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> resendOtp({
    required String destination,
  }) {
    return _apiClient.post(ApiEndPoints.authResendOtp, <String, dynamic>{
      'destination': destination,
    });
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> verifyOtp({
    required String code,
  }) {
    return _apiClient.post(ApiEndPoints.authVerifyOtp, <String, dynamic>{
      'code': code,
    });
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> confirmEmailVerification({
    required String email,
    required String code,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .post(ApiEndPoints.authVerifyEmailConfirm, <String, dynamic>{
          'email': email,
          'code': code,
        });
    await _persistAuthSessionIfAvailable(
      response,
      endpoint: ApiEndPoints.authVerifyEmailConfirm,
      fallbackEmail: email,
    );
    return response;
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> demoAccounts() {
    return _apiClient.get(ApiEndPoints.authDemoAccounts);
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> me() {
    return _apiClient.get(ApiEndPoints.authMe);
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> logoutAllDevices() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .post(ApiEndPoints.securityLogoutAll, const <String, dynamic>{});
    await logout();
    return response;
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _loggedIn = false;
    _role = UserRole.guest;
    await SocketService.instance.disconnect(manual: true);
    await _sessionService.clear();
    await _cleanupService.clearUserData();
  }

  Future<void> _persistSession({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) {
    return _storage.writeJson(
      StorageKeys.authSession,
      <String, dynamic>{'endpoint': endpoint, ...payload},
    );
  }

  Future<void> _persistAuthSessionIfAvailable(
    ServiceResponseModel<Map<String, dynamic>> response, {
    required String endpoint,
    String? fallbackEmail,
    UserRole? fallbackRole,
  }) async {
    if (!_shouldPersistAuthSession(response)) {
      return;
    }

    final Map<String, dynamic>? session = _extractSessionPayload(response.data);
    final Map<String, dynamic>? tokens = _readMap(session?['tokens']);
    final String accessToken =
        (session?['token'] ??
                session?['accessToken'] ??
                tokens?['accessToken'] ??
                '')
            .toString();
    if (accessToken.isEmpty) {
      return;
    }

    final Map<String, dynamic>? user = _extractUserPayload(session);
    final String resolvedRole =
        (user?['role'] as String?)?.toLowerCase() ??
        fallbackRole?.name ??
        _role.name;
    final String resolvedEmail = _resolveSessionEmail(
      user,
      fallbackEmail: fallbackEmail,
    );

    _loggedIn = true;
    _role = _parseRole(resolvedRole);
    final AuthSessionModel authSession = AuthSessionModel(
      isLoggedIn: true,
      accessToken: accessToken.trim(),
      refreshToken:
          (session?['refreshToken'] ?? tokens?['refreshToken'] ?? '')
              .toString()
              .trim(),
      tokenType: (session?['tokenType'] as String? ?? 'Bearer').trim(),
      role: _role.name,
      email: resolvedEmail,
      sessionId: (session?['sessionId'] as String?)?.trim(),
      user: _looksLikeUserPayload(user ?? session?['user'])
          ? UserModel.fromApiJson(
              _readMap(user ?? session?['user']) ?? const <String, dynamic>{},
            )
          : null,
      endpoint: endpoint,
    );
    await _sessionService.persistSession(authSession);
    await _persistSession(endpoint: endpoint, payload: authSession.toJson());
  }

  bool _shouldPersistAuthSession(
    ServiceResponseModel<Map<String, dynamic>> response,
  ) {
    if (!response.isSuccess) {
      return false;
    }

    final dynamic success = response.data['success'];
    if (success is bool && !success) {
      return false;
    }

    return true;
  }

  Map<String, dynamic>? _extractSessionPayload(Map<String, dynamic> payload) {
    for (final Object? candidate in <Object?>[
      payload['data'],
      payload['result'],
      payload['session'],
      payload,
    ]) {
      final Map<String, dynamic>? map = _readMap(candidate);
      if (map != null && _looksLikeSessionPayload(map)) {
        return map;
      }
    }
    return null;
  }

  bool _looksLikeSessionPayload(Map<String, dynamic> payload) {
    return payload.containsKey('token') ||
        payload.containsKey('accessToken') ||
        payload.containsKey('tokens') ||
        payload.containsKey('refreshToken') ||
        payload.containsKey('user');
  }

  Map<String, dynamic>? _extractUserPayload(Map<String, dynamic>? session) {
    for (final Object? candidate in <Object?>[
      session?['user'],
      session?['profile'],
      session?['account'],
      session?['active'],
      session?['data'],
      session?['result'],
      session,
    ]) {
      final Map<String, dynamic>? user = _readMap(candidate);
      if (_looksLikeUserPayload(user)) {
        return user;
      }
      final Map<String, dynamic>? nestedUser = _readMap(user?['user']);
      if (_looksLikeUserPayload(nestedUser)) {
        return nestedUser;
      }
      final Map<String, dynamic>? nestedProfile = _readMap(user?['profile']);
      if (_looksLikeUserPayload(nestedProfile)) {
        return nestedProfile;
      }
      final Map<String, dynamic>? nestedAccount = _readMap(user?['account']);
      if (_looksLikeUserPayload(nestedAccount)) {
        return nestedAccount;
      }
    }
    return null;
  }

  bool _looksLikeUserPayload(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) {
      return false;
    }
    return payload.containsKey('id') ||
        payload.containsKey('_id') ||
        payload.containsKey('name') ||
        payload.containsKey('username') ||
        payload.containsKey('email');
  }

  Map<String, dynamic>? _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  String _resolveSessionEmail(
    Map<String, dynamic>? user, {
    String? fallbackEmail,
  }) {
    final String userEmail = (user?['email'] as String? ?? '').trim();
    if (userEmail.isNotEmpty) {
      return userEmail;
    }
    return fallbackEmail ?? '';
  }

  UserRole _parseRole(String value) {
    switch (value.trim().toLowerCase()) {
      case 'creator':
        return UserRole.creator;
      case 'business':
        return UserRole.business;
      case 'seller':
        return UserRole.seller;
      case 'recruiter':
        return UserRole.recruiter;
      case 'user':
        return UserRole.user;
      default:
        return UserRole.guest;
    }
  }

  String _formatSignupRole(UserRole role) {
    switch (role) {
      case UserRole.user:
        return 'User';
      case UserRole.creator:
        return 'Creator';
      case UserRole.business:
        return 'Business';
      case UserRole.seller:
        return 'Seller';
      case UserRole.recruiter:
        return 'Recruiter';
      case UserRole.guest:
        return 'Guest';
    }
  }
}
