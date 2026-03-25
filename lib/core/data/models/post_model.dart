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
    this.viewCount = 0,
    this.shareCount = 0,
    this.taggedUserIds = const <String>[],
    this.mentionUsernames = const <String>[],
    this.location,
    this.audience = 'Everyone',
    this.altText,
    this.editHistory = const <String>[],
    this.isSponsored = false,
    this.brandCollaborationLabel,
    this.repostHistory = const <String>[],
  });

  final String id;
  final String authorId;
  final String caption;
  final List<String> tags;
  final List<String> media;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final int viewCount;
  final int shareCount;
  final List<String> taggedUserIds;
  final List<String> mentionUsernames;
  final String? location;
  final String audience;
  final String? altText;
  final List<String> editHistory;
  final bool isSponsored;
  final String? brandCollaborationLabel;
  final List<String> repostHistory;
}
