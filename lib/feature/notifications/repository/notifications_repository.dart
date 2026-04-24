import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/models/notification_model.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../service/notifications_service.dart';

class NotificationsRepository {
  NotificationsRepository({NotificationsService? service})
    : _service = service ?? NotificationsService();

  final NotificationsService _service;

  Future<List<NotificationModel>> fetchNotifications() async {
    for (final String key in <String>['inbox', 'notifications', 'campaigns']) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }
        final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['notifications', 'items'],
        );
        if (items.isNotEmpty) {
          return items
              .map(NotificationModel.fromApiJson)
              .where((NotificationModel item) => item.id.isNotEmpty)
              .toList(growable: false);
        }
      } catch (_) {}
    }
    return const <NotificationModel>[];
  }

  Future<List<NotificationModel>> fetchByCategory(String category) async {
    final all = await fetchNotifications();
    final term = category.trim().toLowerCase();
    return all.where((item) => item.payload.type.name == term).toList();
  }

  Future<void> markRead(String notificationId) async {
    try {
      await _service.apiClient.patch(
        ApiEndPoints.notificationRead(notificationId),
        const <String, dynamic>{},
      );
    } catch (_) {}
  }
}
