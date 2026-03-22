import 'package:flutter/foundation.dart';

import '../model/restricted_account_model.dart';

class BlockedMutedAccountsController extends ChangeNotifier {
  List<RestrictedAccountModel> blocked = const [
    RestrictedAccountModel(
      name: 'Sample User',
      handle: '@sample.user',
      status: 'blocked',
    ),
  ];

  List<RestrictedAccountModel> muted = const [
    RestrictedAccountModel(
      name: 'Muted Creator',
      handle: '@muted.creator',
      status: 'muted',
    ),
  ];

  final List<RestrictedAccountModel> restricted = const [
    RestrictedAccountModel(
      name: 'Restricted Account',
      handle: '@restricted.account',
      status: 'restricted',
    ),
  ];

  void unblock(String handle) {
    blocked = blocked.where((item) => item.handle != handle).toList();
    notifyListeners();
  }

  void unmute(String handle) {
    muted = muted.where((item) => item.handle != handle).toList();
    notifyListeners();
  }
}
