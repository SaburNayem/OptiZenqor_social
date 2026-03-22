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
  });

  final NotificationType type;
  final String routeName;
  final String? entityId;
}
