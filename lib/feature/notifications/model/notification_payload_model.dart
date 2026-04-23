import '../../../core/data/api/api_payload_reader.dart';

enum NotificationType {
  social,
  commerce,
  security,
  system,
}

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
    final rawType = ApiPayloadReader.readString(
      map['type'],
      fallback: 'system',
    ).toLowerCase();
    final type = NotificationType.values.firstWhere(
      (value) => value.name == rawType,
      orElse: () => NotificationType.system,
    );
    final Map<String, dynamic> metadata = Map<String, dynamic>.from(
      ApiPayloadReader.readMap(map['metadata']) ?? const <String, dynamic>{},
    );
    return NotificationPayloadModel(
      type: type,
      routeName: ApiPayloadReader.readString(
        map['routeName'] ?? map['route'] ?? map['path'],
        fallback: '/',
      ),
      entityId: ApiPayloadReader.readString(
        map['entityId'] ?? map['targetId'],
      ),
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
