class FeedPostModel {
  const FeedPostModel({
    required this.id,
    required this.authorName,
    required this.caption,
    this.liked = false,
    this.saved = false,
  });

  final String id;
  final String authorName;
  final String caption;
  final bool liked;
  final bool saved;
}
