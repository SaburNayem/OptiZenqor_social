import 'package:flutter/material.dart';

import '../../../../core/common_models/form_state_model.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../route/route_names.dart';
import '../../../auth/repository/auth_repository.dart';

class LoginController extends ChangeNotifier {
  LoginController({
    AuthRepository? repository,
    AnalyticsService? analytics,
  })  : _repository = repository ?? AuthRepository(),
        _analytics = analytics ?? AnalyticsService();

  final AuthRepository _repository;
  final AnalyticsService _analytics;

  FormStateModel formState = const FormStateModel();
  UserRole selectedRole = UserRole.user;

  Future<void> login(BuildContext context) async {
    debugPrint('[Login] Start login with role=${selectedRole.name}');
    formState = formState.copyWith(isSubmitting: true, errorMessage: null);
    notifyListeners();
    try {
      debugPrint('[Login] Calling AuthRepository.login');
      await _repository.login(selectedRole);
      debugPrint('[Login] AuthRepository.login success');
      debugPrint('[Login] Logging analytics event');
      await _analytics.signupCompleted();
      debugPrint('[Login] Analytics success');
      formState = formState.copyWith(
        isSubmitting: false,
        successMessage: 'Login successful',
      );
      notifyListeners();
      if (context.mounted) {
        debugPrint('[Login] Navigating to shell route');
        Navigator.of(context).pushReplacementNamed(RouteNames.shell);
      } else {
        debugPrint('[Login] Context unmounted, navigation skipped');
      }
    } catch (e, st) {
      debugPrint('[Login] Failed: $e');
      debugPrint('$st');
      formState = formState.copyWith(
        isSubmitting: false,
        isValid: false,
        errorMessage: 'Unable to login. Please try again. Check console logs.',
      );
      notifyListeners();
    }
  }

  void updateRole(UserRole role) {
    selectedRole = role;
    notifyListeners();
  }
}
