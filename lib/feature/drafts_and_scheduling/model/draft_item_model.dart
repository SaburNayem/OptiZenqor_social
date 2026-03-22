enum PublishType { post, reel, story }

class DraftItemModel {
  const DraftItemModel({
    required this.id,
    required this.title,
    required this.type,
    this.scheduledAt,
  });

  final String id;
  final String title;
  final PublishType type;
  final DateTime? scheduledAt;
}
