import 'package:flutter/foundation.dart';

import '../../../../core/enums/view_state.dart';

class SignupController extends ChangeNotifier {
  ViewState state = ViewState.idle;

  Future<void> createAccount() async {
    state = ViewState.loading;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = ViewState.success;
    notifyListeners();
  }
}
