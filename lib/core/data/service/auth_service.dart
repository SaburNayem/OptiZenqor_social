import '../../constants/storage_keys.dart';
import '../../enums/user_role.dart';
import '../../data/shared_preference/app_shared_preferences.dart';
import '../api/api_end_points.dart';
import '../service_model/service_response_model.dart';
import 'api_client_service.dart';

class AuthService {
  AuthService({
    ApiClientService? apiClient,
    AppSharedPreferences? storage,
  }) : _apiClient = apiClient ?? ApiClientService(),
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
    final Map<String, dynamic>? session =
        response.data['data'] as Map<String, dynamic>?;
    final String resolvedRole =
        ((session?['user'] as Map<String, dynamic>?)?['role'] as String?)
            ?.toLowerCase() ??
        role.name;
    _loggedIn = true;
    _role = _parseRole(resolvedRole);
    await _persistSession(
      endpoint: ApiEndPoints.authLogin,
      payload: <String, dynamic>{
        'isLoggedIn': true,
        'role': _role.name,
        'email': email ?? '',
        'accessToken': session?['token'],
        'refreshToken': session?['refreshToken'],
        'sessionId': session?['sessionId'],
        'tokenType': session?['tokenType'] ?? 'Bearer',
        'user': session?['user'],
      },
    );
    return response;
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> signup({
    required String name,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
  }) {
    return _apiClient.post(ApiEndPoints.authSignup, <String, dynamic>{
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'role': role,
    });
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
  }) {
    return _apiClient.post(
      ApiEndPoints.authVerifyEmailConfirm,
      <String, dynamic>{
        'email': email,
        'code': code,
      },
    );
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
}
