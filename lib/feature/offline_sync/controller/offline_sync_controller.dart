import 'package:flutter/foundation.dart';

import '../model/offline_action_model.dart';

class OfflineSyncController extends ChangeNotifier {
  bool isOffline = true;

  List<OfflineActionModel> queue = const [
    OfflineActionModel(title: 'Like on post #923', pending: true),
    OfflineActionModel(title: 'Draft save', pending: true),
  ];

  void markOnlineAndSync() {
    isOffline = false;
    queue = queue
        .map(
          (action) => OfflineActionModel(title: action.title, pending: false),
        )
        .toList();
    notifyListeners();
  }
}
