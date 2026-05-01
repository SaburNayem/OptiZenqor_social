import '../../../feature/notifications/model/notification_payload_model.dart';
import '../api/api_payload_reader.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.payload,
    this.unread = true,
    this.actorName,
    this.entityType = 'generic',
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final NotificationPayloadModel payload;
  final bool unread;
  final String? actorName;
  final String entityType;

  factory NotificationModel.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(json['payload']) ??
        <String, dynamic>{
          'type': json['type'],
          'routeName': json['routeName'] ?? json['route'] ?? '/',
          'entityId': json['entityId'] ?? json['targetId'],
          'metadata':
              ApiPayloadReader.readMap(json['metadata']) ??
              const <String, dynamic>{},
        };

    return NotificationModel(
      id: ApiPayloadReader.readString(json['id']),
      title: ApiPayloadReader.readString(
        json['title'],
        fallback: 'Notification',
      ),
      body: ApiPayloadReader.readString(json['body'] ?? json['message']),
      createdAt:
          ApiPayloadReader.readDateTime(
            json['createdAt'] ?? json['timestamp'],
          ) ??
          DateTime.now(),
      payload: NotificationPayloadModel.fromMap(payload),
      unread:
          ApiPayloadReader.readBool(json['unread'] ?? json['isUnread']) ?? true,
      actorName: ApiPayloadReader.readString(
        json['actorName'] ?? json['senderName'],
      ),
      entityType: ApiPayloadReader.readString(
        json['entityType'],
        fallback: 'generic',
      ),
    );
  }
}
