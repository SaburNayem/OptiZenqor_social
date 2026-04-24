import 'package:flutter/foundation.dart';

import '../model/session_item_model.dart';
import '../repository/activity_sessions_repository.dart';

class ActivitySessionsController extends ChangeNotifier {
  ActivitySessionsController({ActivitySessionsRepository? repository})
    : _repository = repository ?? ActivitySessionsRepository();

  final ActivitySessionsRepository _repository;
  bool isLoading = true;
  bool loggingOutOthers = false;
  List<SessionItemModel> sessions = <SessionItemModel>[];
  List<String> activities = <String>[];

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    sessions = await _repository.loadSessions();
    activities = await _repository.loadLoginHistory();
    isLoading = false;
    notifyListeners();
  }

  List<SessionItemModel> get activeSessions =>
      sessions.where((item) => item.active).toList();

  Future<void> logoutOtherDevices() async {
    loggingOutOthers = true;
    notifyListeners();
    final bool syncedRemotely = await _repository.logoutOtherDevices();
    if (syncedRemotely) {
      sessions = await _repository.loadSessions();
    }
    loggingOutOthers = false;
    notifyListeners();
  }
}
