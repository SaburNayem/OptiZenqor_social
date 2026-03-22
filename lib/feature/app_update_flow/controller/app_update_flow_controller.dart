import 'package:flutter/foundation.dart';

import '../model/app_update_model.dart';

class AppUpdateFlowController extends ChangeNotifier {
  final AppUpdateModel update = const AppUpdateModel(
    type: UpdateType.optional,
    message: 'Version 2.1 has performance improvements and chat upgrades.',
  );

  bool isUpdating = false;

  Future<void> startUpdate() async {
    isUpdating = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    isUpdating = false;
    notifyListeners();
  }
}
