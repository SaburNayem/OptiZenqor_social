class PostDetailModel {
  const PostDetailModel({
    required this.id,
    required this.authorId,
    required this.caption,
    required this.media,
    required this.likes,
    required this.comments,
  });

  final String id;
  final String authorId;
  final String caption;
  final List<String> media;
  final int likes;
  final int comments;
}
