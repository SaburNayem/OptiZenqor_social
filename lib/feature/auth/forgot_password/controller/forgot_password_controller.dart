import 'package:flutter/foundation.dart';

import '../../../../core/enums/view_state.dart';

class ForgotPasswordController extends ChangeNotifier {
  ViewState state = ViewState.idle;

  Future<void> sendResetLink() async {
    state = ViewState.loading;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 450));
    state = ViewState.success;
    notifyListeners();
  }
}
