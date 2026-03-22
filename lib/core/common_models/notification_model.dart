import '../../feature/notifications/model/notification_payload_model.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.payload,
    this.unread = true,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final NotificationPayloadModel payload;
  final bool unread;
}
