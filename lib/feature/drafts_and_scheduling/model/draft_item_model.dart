enum PublishType { post, reel, story }

class DraftItemModel {
  const DraftItemModel({
    required this.id,
    required this.title,
    required this.type,
    this.scheduledAt,
    this.audience = 'Everyone',
    this.location,
    this.taggedPeople = const <String>[],
    this.coAuthors = const <String>[],
    this.altText,
    this.versionHistory = const <String>[],
    this.editHistory = const <String>[],
  });

  final String id;
  final String title;
  final PublishType type;
  final DateTime? scheduledAt;
  final String audience;
  final String? location;
  final List<String> taggedPeople;
  final List<String> coAuthors;
  final String? altText;
  final List<String> versionHistory;
  final List<String> editHistory;

  DraftItemModel copyWith({
    DateTime? scheduledAt,
    String? audience,
    String? location,
    List<String>? taggedPeople,
    List<String>? coAuthors,
    String? altText,
    List<String>? versionHistory,
    List<String>? editHistory,
  }) {
    return DraftItemModel(
      id: id,
      title: title,
      type: type,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      audience: audience ?? this.audience,
      location: location ?? this.location,
      taggedPeople: taggedPeople ?? this.taggedPeople,
      coAuthors: coAuthors ?? this.coAuthors,
      altText: altText ?? this.altText,
      versionHistory: versionHistory ?? this.versionHistory,
      editHistory: editHistory ?? this.editHistory,
    );
  }
}
