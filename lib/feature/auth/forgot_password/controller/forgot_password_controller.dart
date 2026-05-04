import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../app_route/route_names.dart';
import '../../../../core/data/models/form_state_model.dart';
import '../../../../core/validators/input_validators.dart';
import '../../model/auth_exception.dart';
import '../../repository/auth_repository.dart';

class ForgotPasswordController extends Cubit<FormStateModel> {
  ForgotPasswordController({
    AuthRepository? authRepository,
    String? initialEmail,
  }) : _authRepository = authRepository ?? AuthRepository(),
       email = initialEmail?.trim() ?? '',
       super(const FormStateModel());

  final AuthRepository _authRepository;

  String email;

  Future<void> sendResetCode() async {
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

    emit(
      state.copyWith(
        isSubmitting: true,
        isValid: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      final String message = await _authRepository.forgotPassword(
        email: trimmedEmail,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          isValid: true,
          errorMessage: null,
          successMessage: message,
        ),
      );
      AppGet.toNamed(
        RouteNames.otpVerification,
        arguments: <String, String>{'email': trimmedEmail},
      );
      AppGet.snackbar('Code Sent', message);
    } on AuthException catch (error, stackTrace) {
      debugPrint('[ForgotPassword] Failed: ${error.message}');
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
      debugPrint('[ForgotPassword] Failed: $error');
      debugPrint('$stackTrace');
      emit(
        state.copyWith(
          isSubmitting: false,
          isValid: false,
          errorMessage: 'Unable to start the password reset process right now.',
          successMessage: null,
        ),
      );
    }
  }

  void updateEmail(String value) {
    email = value;
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
