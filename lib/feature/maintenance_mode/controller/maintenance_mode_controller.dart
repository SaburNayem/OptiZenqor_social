import 'package:flutter/foundation.dart';

import '../model/maintenance_mode_model.dart';

class MaintenanceModeController extends ChangeNotifier {
  final MaintenanceModeModel state = const MaintenanceModeModel(
    title: 'Scheduled Maintenance',
    message: 'We are improving your experience. Please retry shortly.',
    isActive: false,
  );

  bool isRetrying = false;

  Future<void> retry() async {
    isRetrying = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    isRetrying = false;
    notifyListeners();
  }
}
