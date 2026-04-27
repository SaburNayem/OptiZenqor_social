import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../core/data/models/form_state_model.dart';
import '../../../../core/data/service/analytics_service.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../app_route/route_names.dart';
import '../../model/auth_exception.dart';
import '../../repository/auth_repository.dart';

class LoginController extends Cubit<FormStateModel> {
  LoginController({
    AuthRepository? authRepository,
    AnalyticsService? analyticsService,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _analyticsService = analyticsService ?? AnalyticsService(),
       super(const FormStateModel());

  final AuthRepository _authRepository;
  final AnalyticsService _analyticsService;

  UserRole selectedRole = UserRole.user;
  String email = '';
  String password = '';

  Future<void> login() async {
    final String trimmedEmail = email.trim();
    final String? emailError = InputValidators.email(trimmedEmail);
    if (emailError != null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isValid: false,
          errorMessage: emailError,
          successMessage: null,
        ),
      );
      return;
    }

    final String? passwordError = InputValidators.loginPassword(password);
    if (passwordError != null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isValid: false,
          errorMessage: passwordError,
          successMessage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        isValid: true,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      await _authRepository.login(
        role: selectedRole,
        email: trimmedEmail,
        password: password,
      );
      await _analyticsService.logEvent(
        'login_success',
        params: <String, dynamic>{'role': selectedRole.name},
      );
      emit(
        state.copyWith(isSubmitting: false, successMessage: 'Login successful'),
      );
      AppGet.offAllNamed(
        RouteNames.shell,
        arguments: <String, dynamic>{'refreshUser': true},
      );
    } on AuthException catch (e, st) {
      debugPrint('[Login] Auth failed: ${e.message}');
      debugPrint('$st');
      emit(
        state.copyWith(
          isSubmitting: false,
          isValid: false,
          errorMessage: e.message,
          successMessage: null,
        ),
      );
    } catch (e, st) {
      debugPrint('[Login] Failed: $e');
      debugPrint('$st');
      emit(
        state.copyWith(
          isSubmitting: false,
          isValid: false,
          errorMessage: 'Unable to continue. Please try again.',
        ),
      );
    }
  }

  void updateRole(UserRole role) {
    selectedRole = role;
  }

  void updateEmail(String value) {
    email = value;
    _resetValidationState();
  }

  void updatePassword(String value) {
    password = value;
    _resetValidationState();
  }

  void _resetValidationState() {
    if (state.errorMessage == null &&
        state.successMessage == null &&
        state.isValid) {
      return;
    }
    emit(
      state.copyWith(isValid: true, errorMessage: null, successMessage: null),
    );
  }
}
