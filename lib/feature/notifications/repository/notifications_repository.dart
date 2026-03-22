import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/notification_model.dart';

class NotificationsRepository {
  Future<List<NotificationModel>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    return MockData.notifications;
  }

  Future<List<NotificationModel>> fetchByCategory(String category) async {
    final all = await fetchNotifications();
    return all.where((item) => item.title.toLowerCase().contains(category)).toList();
  }
}
