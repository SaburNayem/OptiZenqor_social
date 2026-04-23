import '../../constants/storage_keys.dart';
import '../../enums/user_role.dart';
import '../../data/shared_preference/app_shared_preferences.dart';
import '../api/api_end_points.dart';
import '../service_model/service_response_model.dart';
import 'api_client_service.dart';

class AuthService {
  AuthService({ApiClientService? apiClient, AppSharedPreferences? storage})
    : _apiClient = apiClient ?? ApiClientService(),
      _storage = storage ?? AppSharedPreferences();

  final ApiClientService _apiClient;
  final AppSharedPreferences _storage;

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
    await _storage.remove(StorageKeys.authSession);
  }

  Future<void> _persistSession({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) {
    return _storage.writeJson(StorageKeys.authSession, <String, dynamic>{
      'endpoint': endpoint,
      ...payload,
    });
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
    final String accessToken =
        (session?['token'] ?? session?['accessToken'] ?? '').toString();
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
    await _persistSession(
      endpoint: endpoint,
      payload: <String, dynamic>{
        'isLoggedIn': true,
        'role': _role.name,
        'email': resolvedEmail,
        'accessToken': accessToken,
        'refreshToken': session?['refreshToken'],
        'sessionId': session?['sessionId'],
        'tokenType': session?['tokenType'] ?? 'Bearer',
        'user': user ?? session?['user'],
      },
    );
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
    final dynamic nestedData = payload['data'];
    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }
    if (nestedData is Map) {
      return Map<String, dynamic>.from(nestedData);
    }
    if (_looksLikeSessionPayload(payload)) {
      return payload;
    }
    return null;
  }

  bool _looksLikeSessionPayload(Map<String, dynamic> payload) {
    return payload.containsKey('token') ||
        payload.containsKey('accessToken') ||
        payload.containsKey('refreshToken') ||
        payload.containsKey('user');
  }

  Map<String, dynamic>? _extractUserPayload(Map<String, dynamic>? session) {
    final dynamic user = session?['user'];
    if (user is Map<String, dynamic>) {
      return user;
    }
    if (user is Map) {
      return Map<String, dynamic>.from(user);
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
