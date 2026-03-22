class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.unread = true,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool unread;
}
