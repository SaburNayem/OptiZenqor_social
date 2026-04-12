import 'package:flutter/foundation.dart';

import '../../../../core/enums/view_state.dart';

class ResetPasswordController extends ChangeNotifier {
  ViewState state = ViewState.idle;

  Future<void> resetPassword() async {
    state = ViewState.loading;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    state = ViewState.success;
    notifyListeners();
  }
}
