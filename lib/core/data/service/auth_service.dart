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
  }) : _apiClient = apiClient ?? const ApiClientService(),
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
          'role': role.name,
          'email': email ?? '',
          'password': password ?? '',
        });
    _loggedIn = true;
    _role = role;
    await _persistSession(
      endpoint: ApiEndPoints.authLogin,
      payload: <String, dynamic>{
        'isLoggedIn': true,
        'role': role.name,
        'email': email ?? '',
      },
    );
    return response;
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> signup({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) {
    return _apiClient.post(ApiEndPoints.authSignup, <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'password': password,
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
    required String newPassword,
  }) {
    return _apiClient.post(ApiEndPoints.authResetPassword, <String, dynamic>{
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> sendOtp({
    required String email,
    String purpose = 'signup',
  }) {
    return _apiClient.post(ApiEndPoints.authSendOtp, <String, dynamic>{
      'email': email,
      'purpose': purpose,
    });
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> resendOtp({
    required String email,
    String purpose = 'signup',
  }) {
    return _apiClient.post(ApiEndPoints.authResendOtp, <String, dynamic>{
      'email': email,
      'purpose': purpose,
    });
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> verifyOtp({
    required String email,
    required String otp,
    String purpose = 'signup',
  }) {
    return _apiClient.post(ApiEndPoints.authVerifyOtp, <String, dynamic>{
      'email': email,
      'otp': otp,
      'purpose': purpose,
    });
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> confirmEmailVerification({
    required String email,
    required String otp,
  }) {
    return _apiClient.post(
      ApiEndPoints.authVerifyEmailConfirm,
      <String, dynamic>{
        'email': email,
        'otp': otp,
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
}
