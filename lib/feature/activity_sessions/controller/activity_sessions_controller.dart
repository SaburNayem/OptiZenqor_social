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
    } else {
      sessions = sessions
          .map(
            (item) => item.isCurrent
                ? item
                : item.copyWith(
                    active: false,
                    lastActive: 'Signed out remotely',
                  ),
          )
          .toList();
      await _repository.saveSessions(sessions);
    }
    loggingOutOthers = false;
    notifyListeners();
  }
}
