import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../app_route/route_names.dart';
import '../../../../core/data/models/form_state_model.dart';
import '../../../../core/validators/input_validators.dart';
import '../../model/auth_exception.dart';
import '../../repository/auth_repository.dart';

class ResetPasswordController extends Cubit<FormStateModel> {
  ResetPasswordController({
    required this.email,
    required this.otp,
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? AuthRepository(),
       super(const FormStateModel());

  final AuthRepository _authRepository;
  final String email;
  final String otp;

  String newPassword = '';
  String confirmPassword = '';

  Future<void> resetPassword() async {
    if (email.trim().isEmpty || otp.trim().isEmpty) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isValid: false,
          errorMessage: 'Reset code is missing. Please request a new one.',
          successMessage: null,
        ),
      );
      return;
    }

    final String? passwordError = InputValidators.password(newPassword);
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

    if (confirmPassword.trim().isEmpty) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isValid: false,
          errorMessage: 'Please confirm your new password.',
          successMessage: null,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isValid: false,
          errorMessage: 'Passwords do not match.',
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
      final String message = await _authRepository.resetPassword(
        email: email.trim(),
        otp: otp.trim(),
        password: newPassword,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          isValid: true,
          errorMessage: null,
          successMessage: message,
        ),
      );
      AppGet.offAllNamed(RouteNames.login);
      AppGet.snackbar('Password Reset', message);
    } on AuthException catch (error, stackTrace) {
      debugPrint('[ResetPassword] Failed: ${error.message}');
      debugPrint('$stackTrace');
      emit(
        state.copyWith(
          isSubmitting: false,
          isValid: false,
          errorMessage: error.message,
          successMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('[ResetPassword] Failed: $error');
      debugPrint('$stackTrace');
      emit(
        state.copyWith(
          isSubmitting: false,
          isValid: false,
          errorMessage: 'Unable to reset your password right now.',
          successMessage: null,
        ),
      );
    }
  }

  void updateNewPassword(String value) {
    newPassword = value;
    _resetValidationState();
  }

  void updateConfirmPassword(String value) {
    confirmPassword = value;
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
