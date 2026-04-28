import '../../../core/constants/storage_keys.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service/auth_service.dart';
import '../../../core/data/service/auth_session_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../../../core/data/shared_preference/app_shared_preferences.dart';
import '../../../core/enums/user_role.dart';
import 'package:flutter/foundation.dart';

import '../model/auth_exception.dart';
import '../signup/model/signup_model.dart';

class AuthRepository {
  AuthRepository({
    AuthService? authService,
    AppSharedPreferences? storage,
    AuthSessionService? sessionService,
  })
    : _authService = authService ?? AuthService(),
      _storage = storage ?? AppSharedPreferences(),
      _sessionService =
          sessionService ??
          AuthSessionService(storage: storage ?? AppSharedPreferences());

  final AuthService _authService;
  final AppSharedPreferences _storage;
  final AuthSessionService _sessionService;

  Future<void> login({
    required UserRole role,
    required String email,
    required String password,
  }) async {
    debugPrint('[AuthRepository] login start role=${role.name}');
    final response = await _authService.login(
      role: role,
      email: email,
      password: password,
    );
    final Map<String, dynamic>? session = _extractSessionPayload(response.data);
    final String accessToken =
        (session?['token'] ?? session?['accessToken'] ?? '').toString();
    if (!response.isSuccess ||
        response.data['success'] == false ||
        accessToken.isEmpty) {
      throw AuthException(
        _resolveLoginErrorMessage(
          statusCode: response.statusCode,
          payload: response.data,
          fallbackMessage: response.message,
          hasSession: accessToken.isNotEmpty,
        ),
        statusCode: response.statusCode,
      );
    }
    debugPrint('[AuthRepository] AuthService.login success');
    await _hydrateSessionUserIfNeeded(fallbackEmail: email, fallbackRole: role);
    debugPrint(
      '[AuthRepository] Session persisted key=${StorageKeys.authSession}',
    );
  }

  Future<void> signup({required SignupModel signup}) async {
    debugPrint('[AuthRepository] signup start email=${signup.email}');
    final response = await _authService.signup(
      name: signup.name,
      username: signup.username,
      email: signup.email,
      password: signup.password,
      confirmPassword: signup.confirmPassword,
      role: signup.role,
      avatarUrl: signup.avatarUrl,
      bio: signup.bio,
      interests: signup.interests,
    );

    if (!_isSuccessfulResponse(response)) {
      throw AuthException(
        _resolveSignupErrorMessage(
          statusCode: response.statusCode,
          payload: response.data,
          fallbackMessage: response.message,
        ),
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> confirmEmailVerification({
    required String email,
    required String code,
  }) async {
    debugPrint('[AuthRepository] confirmEmailVerification start email=$email');
    final response = await _authService.confirmEmailVerification(
      email: email,
      code: code,
    );

    if (!_isSuccessfulResponse(response)) {
      throw AuthException(
        _resolveVerificationErrorMessage(
          statusCode: response.statusCode,
          payload: response.data,
          fallbackMessage: response.message,
        ),
        statusCode: response.statusCode,
      );
    }
  }

  Future<String> forgotPassword({required String email}) async {
    debugPrint('[AuthRepository] forgotPassword start email=$email');
    final response = await _authService.forgotPassword(email: email);

    if (!_isSuccessfulResponse(response)) {
      throw AuthException(
        _resolveForgotPasswordErrorMessage(
          statusCode: response.statusCode,
          payload: response.data,
          fallbackMessage: response.message,
        ),
        statusCode: response.statusCode,
      );
    }

    return _extractApiMessage(response.data) ??
        response.message ??
        'We sent a 6-digit reset code to your email.';
  }

  Future<String> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    debugPrint('[AuthRepository] resetPassword start email=$email');
    final response = await _authService.resetPassword(
      email: email,
      otp: otp,
      password: password,
    );

    if (!_isSuccessfulResponse(response)) {
      throw AuthException(
        _resolveResetPasswordErrorMessage(
          statusCode: response.statusCode,
          payload: response.data,
          fallbackMessage: response.message,
        ),
        statusCode: response.statusCode,
      );
    }

    return _extractApiMessage(response.data) ??
        response.message ??
        'Your password has been reset successfully.';
  }

  Future<String> resendEmailVerificationCode({required String email}) async {
    debugPrint(
      '[AuthRepository] resendEmailVerificationCode start email=$email',
    );
    final response = await _authService.resendOtp(destination: email);

    if (!_isSuccessfulResponse(response)) {
      throw AuthException(
        _resolveResendCodeErrorMessage(
          statusCode: response.statusCode,
          payload: response.data,
          fallbackMessage: response.message,
        ),
        statusCode: response.statusCode,
      );
    }

    return _extractApiMessage(response.data) ??
        response.message ??
        'A new 6-digit verification code has been sent to your email.';
  }

  Future<void> logout() async {
    await _authService.logout();
    await _sessionService.clear();
  }

  Future<bool> hasSession() async {
    final session = await _sessionService.readSession();
    if (session == null || !session.isUsable) {
      final Map<String, dynamic>? stored = await _storage.readJson(
        StorageKeys.authSession,
      );
      if (stored != null && stored.isNotEmpty) {
        await _sessionService.clear();
      }
      return false;
    }
    final Map<String, dynamic> rawSession = session.toJson();
    if (!_isUsableSession(rawSession)) {
      await _sessionService.clear();
      return false;
    }
    return true;
  }

  Future<UserModel?> currentUser() async {
    final session = await _sessionService.readSession();
    if (session == null || !session.isUsable) {
      return null;
    }
    if (session.user != null) {
      return session.user;
    }
    final Map<String, dynamic>? user = _extractUserPayload(session.toJson());
    if (user == null || user.isEmpty) {
      return null;
    }

    final UserModel resolved = UserModel.fromApiJson(user);
    return resolved.id.isEmpty && resolved.name.trim().isEmpty
        ? null
        : resolved;
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
    ]) {
      final Map<String, dynamic>? user = _readMap(candidate);
      if (user != null && user.isNotEmpty) {
        return user;
      }
    }
    return null;
  }

  bool _isUsableSession(Map<String, dynamic>? session) {
    if (session == null || session.isEmpty) {
      return false;
    }
    if ((session['isLoggedIn'] as bool?) != true) {
      return false;
    }

    final Map<String, dynamic>? payload = _extractSessionPayload(session);
    final Map<String, dynamic>? tokens = _readMap(payload?['tokens']);
    final String accessToken =
        ((payload?['accessToken'] ??
                        payload?['token'] ??
                        tokens?['accessToken'])
                    as Object? ??
                '')
            .toString()
            .trim();
    return accessToken.isNotEmpty;
  }

  Future<void> _hydrateSessionUserIfNeeded({
    required String fallbackEmail,
    required UserRole fallbackRole,
  }) async {
    final Map<String, dynamic>? session = await _storage.readJson(
      StorageKeys.authSession,
    );
    if (!_isUsableSession(session)) {
      return;
    }

    final Map<String, dynamic>? existingUser = _extractUserPayload(session!);
    if (_isUsableUser(existingUser)) {
      return;
    }

    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _authService.me();
      if (!response.isSuccess || response.data['success'] == false) {
        return;
      }
      final Map<String, dynamic>? mePayload = _extractUserFromPayload(
        response.data,
      );
      if (!_isUsableUser(mePayload)) {
        return;
      }

      final String resolvedRole =
          (mePayload!['role'] as String?)?.toLowerCase() ?? fallbackRole.name;
      final Map<String, dynamic> updatedSession = <String, dynamic>{
        ...session,
        'role': resolvedRole,
        'email': _resolveEmail(mePayload, fallbackEmail: fallbackEmail),
        'user': mePayload,
      };
      await _storage.writeJson(StorageKeys.authSession, updatedSession);
      await _sessionService.updateUser(
        UserModel.fromApiJson(mePayload),
        role: resolvedRole,
        email: _resolveEmail(mePayload, fallbackEmail: fallbackEmail),
      );
    } catch (_) {}
  }

  Map<String, dynamic>? _extractUserFromPayload(Map<String, dynamic> payload) {
    for (final Object? candidate in <Object?>[
      payload['user'],
      payload['profile'],
      payload['data'],
      payload['result'],
      payload,
    ]) {
      final Map<String, dynamic>? map = _readMap(candidate);
      if (_isUsableUser(map)) {
        return map;
      }
      final Map<String, dynamic>? nestedUser = _readMap(map?['user']);
      if (_isUsableUser(nestedUser)) {
        return nestedUser;
      }
      final Map<String, dynamic>? nestedProfile = _readMap(map?['profile']);
      if (_isUsableUser(nestedProfile)) {
        return nestedProfile;
      }
    }
    return null;
  }

  bool _isUsableUser(Map<String, dynamic>? user) {
    if (user == null || user.isEmpty) {
      return false;
    }
    final String id = (user['id'] as Object? ?? user['_id'] as Object? ?? '')
        .toString()
        .trim();
    final String name = (user['name'] as String? ?? '').trim();
    final String username = (user['username'] as String? ?? '').trim();
    return id.isNotEmpty || name.isNotEmpty || username.isNotEmpty;
  }

  String _resolveEmail(
    Map<String, dynamic> user, {
    required String fallbackEmail,
  }) {
    final String email = (user['email'] as String? ?? '').trim();
    return email.isEmpty ? fallbackEmail : email;
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

  bool _isSuccessfulResponse(
    ServiceResponseModel<Map<String, dynamic>> response,
  ) {
    return response.isSuccess && response.data['success'] != false;
  }

  String _resolveLoginErrorMessage({
    required int statusCode,
    required Map<String, dynamic> payload,
    required String? fallbackMessage,
    required bool hasSession,
  }) {
    final String? apiMessage = _extractApiMessage(payload) ?? fallbackMessage;

    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return apiMessage ?? 'Invalid email or password.';
    }
    if (statusCode == 404) {
      return 'Login service is unavailable right now.';
    }
    if (statusCode == 408) {
      return apiMessage ??
          'Request timed out. Check your connection and try again.';
    }
    if (statusCode == 429) {
      return 'Too many login attempts. Please wait and try again.';
    }
    if (statusCode == 503) {
      return apiMessage ??
          'Unable to reach the server. Check your connection and try again.';
    }
    if (statusCode >= 500) {
      return 'Server error. Please try again in a moment.';
    }
    if (!hasSession) {
      return apiMessage ?? 'Unable to create your login session.';
    }
    return apiMessage ?? 'Unable to continue. Please try again.';
  }

  String _resolveSignupErrorMessage({
    required int statusCode,
    required Map<String, dynamic> payload,
    required String? fallbackMessage,
  }) {
    final String? apiMessage = _extractApiMessage(payload) ?? fallbackMessage;

    if (statusCode == 400) {
      return apiMessage ?? 'Please review your signup details and try again.';
    }
    if (statusCode == 401 || statusCode == 403) {
      return apiMessage ?? 'You are not allowed to create this account.';
    }
    if (statusCode == 404) {
      return 'Signup service is unavailable right now.';
    }
    if (statusCode == 408) {
      return apiMessage ??
          'Request timed out. Check your connection and try again.';
    }
    if (statusCode == 409) {
      return apiMessage ??
          'An account with this email or username already exists.';
    }
    if (statusCode == 429) {
      return 'Too many signup attempts. Please wait and try again.';
    }
    if (statusCode == 503) {
      return apiMessage ??
          'Unable to reach the server. Check your connection and try again.';
    }
    if (statusCode >= 500) {
      return 'Server error. Please try again in a moment.';
    }

    return apiMessage ?? 'Unable to create your account right now.';
  }

  String _resolveVerificationErrorMessage({
    required int statusCode,
    required Map<String, dynamic> payload,
    required String? fallbackMessage,
  }) {
    final String? apiMessage = _extractApiMessage(payload) ?? fallbackMessage;

    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return apiMessage ?? 'Invalid verification code. Please try again.';
    }
    if (statusCode == 404) {
      return apiMessage ??
          'Verification request was not found. Please request a new code.';
    }
    if (statusCode == 408) {
      return apiMessage ??
          'Request timed out. Check your connection and try again.';
    }
    if (statusCode == 410) {
      return apiMessage ?? 'This verification code has expired.';
    }
    if (statusCode == 429) {
      return 'Too many verification attempts. Please wait and try again.';
    }
    if (statusCode == 503) {
      return apiMessage ??
          'Unable to reach the server. Check your connection and try again.';
    }
    if (statusCode >= 500) {
      return 'Server error. Please try again in a moment.';
    }

    return apiMessage ?? 'Unable to verify your email right now.';
  }

  String _resolveResendCodeErrorMessage({
    required int statusCode,
    required Map<String, dynamic> payload,
    required String? fallbackMessage,
  }) {
    final String? apiMessage = _extractApiMessage(payload) ?? fallbackMessage;

    if (statusCode == 400 || statusCode == 404) {
      return apiMessage ?? 'Unable to resend the verification code.';
    }
    if (statusCode == 408) {
      return apiMessage ??
          'Request timed out. Check your connection and try again.';
    }
    if (statusCode == 429) {
      return 'Please wait a bit before requesting another code.';
    }
    if (statusCode == 503) {
      return apiMessage ??
          'Unable to reach the server. Check your connection and try again.';
    }
    if (statusCode >= 500) {
      return 'Server error. Please try again in a moment.';
    }

    return apiMessage ?? 'Unable to resend the verification code right now.';
  }

  String _resolveForgotPasswordErrorMessage({
    required int statusCode,
    required Map<String, dynamic> payload,
    required String? fallbackMessage,
  }) {
    final String? apiMessage = _extractApiMessage(payload) ?? fallbackMessage;

    if (statusCode == 400) {
      return apiMessage ?? 'Please enter a valid email address.';
    }
    if (statusCode == 404) {
      return apiMessage ?? 'We could not find an account with that email.';
    }
    if (statusCode == 408) {
      return apiMessage ??
          'Request timed out. Check your connection and try again.';
    }
    if (statusCode == 429) {
      return 'Please wait a bit before requesting another reset code.';
    }
    if (statusCode == 503) {
      return apiMessage ??
          'Unable to reach the server. Check your connection and try again.';
    }
    if (statusCode >= 500) {
      return 'Server error. Please try again in a moment.';
    }

    return apiMessage ??
        'Unable to start the password reset process right now.';
  }

  String _resolveResetPasswordErrorMessage({
    required int statusCode,
    required Map<String, dynamic> payload,
    required String? fallbackMessage,
  }) {
    final String? apiMessage = _extractApiMessage(payload) ?? fallbackMessage;

    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return apiMessage ?? 'Invalid reset code or password.';
    }
    if (statusCode == 404) {
      return apiMessage ??
          'Reset request was not found. Please request a new code.';
    }
    if (statusCode == 408) {
      return apiMessage ??
          'Request timed out. Check your connection and try again.';
    }
    if (statusCode == 410) {
      return apiMessage ??
          'This reset code has expired. Please request a new one.';
    }
    if (statusCode == 429) {
      return 'Too many reset attempts. Please wait and try again.';
    }
    if (statusCode == 503) {
      return apiMessage ??
          'Unable to reach the server. Check your connection and try again.';
    }
    if (statusCode >= 500) {
      return 'Server error. Please try again in a moment.';
    }

    return apiMessage ?? 'Unable to reset your password right now.';
  }

  String? _extractApiMessage(Map<String, dynamic> payload) {
    final dynamic directMessage = payload['message'];
    if (directMessage is String && directMessage.trim().isNotEmpty) {
      return directMessage.trim();
    }

    final dynamic error = payload['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }

    final dynamic errors = payload['errors'];
    if (errors is List && errors.isNotEmpty) {
      final String joined = errors
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .join('\n');
      if (joined.isNotEmpty) {
        return joined;
      }
    }

    if (errors is Map) {
      for (final dynamic value in errors.values) {
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
        if (value is List) {
          for (final dynamic item in value) {
            if (item is String && item.trim().isNotEmpty) {
              return item.trim();
            }
          }
        }
      }
    }

    final dynamic nestedData = payload['data'];
    if (nestedData is Map<String, dynamic>) {
      return _extractApiMessage(nestedData);
    }
    if (nestedData is Map) {
      return _extractApiMessage(Map<String, dynamic>.from(nestedData));
    }
    return null;
  }
}
