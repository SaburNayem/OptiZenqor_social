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
    final rawType = (map['type'] as String? ?? 'system').toLowerCase();
    final type = NotificationType.values.firstWhere(
      (value) => value.name == rawType,
      orElse: () => NotificationType.system,
    );
    return NotificationPayloadModel(
      type: type,
      routeName: map['routeName'] as String? ?? '/',
      entityId: map['entityId'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? const <String, dynamic>{}),
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
