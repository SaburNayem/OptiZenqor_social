import '../../../core/data/api/api_payload_reader.dart';

enum NotificationType { social, commerce, security, system }

class NotificationPayloadModel {
  const NotificationPayloadModel({
    required this.type,
    required this.routeName,
    this.entityId,
    this.metadata = const <String, dynamic>{},
  });

  final NotificationType type;
  final String routeName;
  final String? entityId;
  final Map<String, dynamic> metadata;

  factory NotificationPayloadModel.fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic> metadata = <String, dynamic>{
      ...map,
      ...Map<String, dynamic>.from(
        ApiPayloadReader.readMap(map['metadata']) ?? const <String, dynamic>{},
      ),
    };
    final rawType = ApiPayloadReader.readString(
      map['type'] ?? metadata['notificationType'],
      fallback: 'system',
    ).toLowerCase();
    final type = NotificationType.values.firstWhere(
      (value) => value.name == rawType,
      orElse: () => NotificationType.system,
    );
    final String entityId = ApiPayloadReader.readString(
      map['entityId'] ??
          map['targetId'] ??
          metadata['entityId'] ??
          metadata['targetId'] ??
          metadata['postId'] ??
          metadata['userId'] ??
          metadata['profileId'] ??
          metadata['productId'] ??
          metadata['jobId'] ??
          metadata['eventId'] ??
          metadata['threadId'] ??
          metadata['messageId'] ??
          metadata['callSessionId'] ??
          metadata['sessionId'],
    );
    return NotificationPayloadModel(
      type: type,
      routeName: ApiPayloadReader.readString(
        map['routeName'] ??
            map['route'] ??
            map['path'] ??
            map['deepLink'] ??
            map['url'] ??
            metadata['routeName'] ??
            metadata['route'] ??
            metadata['path'] ??
            metadata['deepLink'] ??
            metadata['url'],
        fallback: '/',
      ),
      entityId: entityId.isEmpty ? null : entityId,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type.name,
      'routeName': routeName,
      'entityId': entityId,
      'metadata': metadata,
    };
  }
}
