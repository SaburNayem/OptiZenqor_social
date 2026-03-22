import 'package:flutter/foundation.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/notification_model.dart';

class NotificationsController extends ChangeNotifier {
  List<NotificationModel> notifications = <NotificationModel>[];

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    notifications = MockData.notifications;
    notifyListeners();
  }
}
