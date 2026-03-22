import 'package:flutter/foundation.dart';

import '../model/account_identity_model.dart';

class AccountSwitchingController extends ChangeNotifier {
  final List<AccountIdentityModel> identities = const [
    AccountIdentityModel(name: 'Maya Quinn', handle: '@mayaquinn'),
    AccountIdentityModel(name: 'Nexa Studio', handle: '@nexa.studio'),
  ];

  int current = 0;

  void switchTo(int index) {
    current = index;
    notifyListeners();
  }
}
