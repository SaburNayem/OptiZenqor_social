import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../core/data/models/form_state_model.dart';
import '../../../../core/data/service/analytics_service.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../app_route/route_names.dart';
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
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _authRepository.login(
        role: selectedRole,
        email: email.trim(),
        password: password,
      );
      await _analyticsService.logEvent(
        'login_success',
        params: <String, dynamic>{'role': selectedRole.name},
      );
      emit(
        state.copyWith(isSubmitting: false, successMessage: 'Login successful'),
      );
      AppGet.offNamed(RouteNames.shell);
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
  }

  void updatePassword(String value) {
    password = value;
  }
}
