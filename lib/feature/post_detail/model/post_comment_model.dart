class PostCommentModel {
  const PostCommentModel({
    required this.id,
    required this.authorId,
    required this.author,
    required this.message,
    this.postId = '',
    this.authorUsername,
    this.authorAvatar,
    this.replyTo,
    this.createdAt = '',
    this.likeCount = 0,
    this.isLikedByMe = false,
    this.isReported = false,
    this.isEdited = false,
    this.reactions = const <String, int>{},
    this.mentions = const <String>[],
    this.replyCount = 0,
  });

  final String id;
  final String postId;
  final String authorId;
  final String author;
  final String? authorUsername;
  final String? authorAvatar;
  final String message;
  final String? replyTo;
  final String createdAt;
  final int likeCount;
  final bool isLikedByMe;
  final bool isReported;
  final bool isEdited;
  final Map<String, int> reactions;
  final List<String> mentions;
  final int replyCount;

  PostCommentModel copyWith({
    String? message,
    int? likeCount,
    bool? isLikedByMe,
    bool? isReported,
    bool? isEdited,
    Map<String, int>? reactions,
    List<String>? mentions,
    String? authorUsername,
    String? authorAvatar,
    int? replyCount,
  }) {
    return PostCommentModel(
      id: id,
      postId: postId,
      authorId: authorId,
      author: author,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      message: message ?? this.message,
      replyTo: replyTo,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isReported: isReported ?? this.isReported,
      isEdited: isEdited ?? this.isEdited,
      reactions: reactions ?? this.reactions,
      mentions: mentions ?? this.mentions,
      replyCount: replyCount ?? this.replyCount,
    );
  }
}
