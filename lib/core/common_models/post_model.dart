class PostModel {
  const PostModel({
    required this.id,
    required this.authorId,
    required this.caption,
    required this.tags,
    required this.media,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String caption;
  final List<String> tags;
  final List<String> media;
  final int likes;
  final int comments;
  final DateTime createdAt;
}
