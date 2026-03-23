import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  String? _lastFailedAction;

  bool get isOnline => _isOnline;
  String? get lastFailedAction => _lastFailedAction;

  void setOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  void markFailedAction(String actionKey) {
    _lastFailedAction = actionKey;
    notifyListeners();
  }

  void clearFailedAction() {
    _lastFailedAction = null;
    notifyListeners();
  }

  Future<bool> retryFailedAction(Future<void> Function(String actionKey) retry) async {
    final action = _lastFailedAction;
    if (!_isOnline || action == null) {
      return false;
    }
    await retry(action);
    _lastFailedAction = null;
    notifyListeners();
    return true;
  }
}
