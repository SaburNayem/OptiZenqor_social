class ScheduledPostModel {
  const ScheduledPostModel({
    required this.id,
    required this.title,
    required this.scheduledAt,
  });

  final String id;
  final String title;
  final DateTime scheduledAt;
}
