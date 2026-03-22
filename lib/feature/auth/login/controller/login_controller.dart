import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common_models/form_state_model.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../route/route_names.dart';

class LoginController extends ChangeNotifier {
  LoginController();

  FormStateModel formState = const FormStateModel();
  UserRole selectedRole = UserRole.user;

  Future<void> login() async {
    formState = formState.copyWith(isSubmitting: true, errorMessage: null);
    notifyListeners();
    try {
      formState = formState.copyWith(
        isSubmitting: false,
        successMessage: 'Login successful',
      );
      notifyListeners();
      Get.offNamed(RouteNames.shell);
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
