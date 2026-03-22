class PostCommentModel {
  const PostCommentModel({
    required this.id,
    required this.author,
    required this.message,
    this.replyTo,
    this.createdAt = '',
  });

  final String id;
  final String author;
  final String message;
  final String? replyTo;
  final String createdAt;
}
