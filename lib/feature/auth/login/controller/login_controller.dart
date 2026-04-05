import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../core/data/models/form_state_model.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/data/service/analytics_service.dart';
import '../../../../route/route_names.dart';
import '../../repository/auth_repository.dart';

class LoginController extends ChangeNotifier {
  LoginController({
    AuthRepository? authRepository,
    AnalyticsService? analyticsService,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _analyticsService = analyticsService ?? AnalyticsService();

  final AuthRepository _authRepository;
  final AnalyticsService _analyticsService;

  FormStateModel formState = const FormStateModel();
  UserRole selectedRole = UserRole.user;

  Future<void> login() async {
    formState = formState.copyWith(isSubmitting: true, errorMessage: null);
    notifyListeners();
    try {
      await _authRepository.login(selectedRole);
      await _analyticsService.logEvent(
        'login_success',
        params: <String, dynamic>{'role': selectedRole.name},
      );
      formState = formState.copyWith(
        isSubmitting: false,
        successMessage: 'Login successful',
      );
      notifyListeners();
      AppGet.offNamed(RouteNames.shell);
    } catch (e, st) {
      debugPrint('[Login] Failed: $e');
      debugPrint('$st');
      formState = formState.copyWith(
        isSubmitting: false,
        isValid: false,
        errorMessage: 'Unable to continue. Please try again.',
      );
      notifyListeners();
    }
  }

  void updateRole(UserRole role) {
    selectedRole = role;
    notifyListeners();
  }
}
