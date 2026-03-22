class PostDetailModel {
  const PostDetailModel({
    required this.id,
    required this.caption,
    required this.likes,
    required this.comments,
  });

  final String id;
  final String caption;
  final int likes;
  final int comments;
}
