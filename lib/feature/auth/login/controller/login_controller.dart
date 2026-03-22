import 'package:flutter/material.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/view_state.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../route/route_names.dart';

class LoginController extends ChangeNotifier {
  LoginController({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  ViewState state = ViewState.idle;
  String? error;
  UserRole selectedRole = UserRole.user;

  Future<void> login(BuildContext context) async {
    state = ViewState.loading;
    notifyListeners();
    try {
      await _authService.login(role: selectedRole);
      state = ViewState.success;
      notifyListeners();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(RouteNames.shell);
      }
    } catch (_) {
      state = ViewState.error;
      error = 'Unable to login. Please try again.';
      notifyListeners();
    }
  }

  void updateRole(UserRole role) {
    selectedRole = role;
    notifyListeners();
  }
}
