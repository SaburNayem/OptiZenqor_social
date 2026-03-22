class StoryModel {
  const StoryModel({
    required this.id,
    required this.userId,
    required this.media,
    required this.seen,
  });

  final String id;
  final String userId;
  final String media;
  final bool seen;
}
