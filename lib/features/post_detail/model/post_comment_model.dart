class PostCommentModel {
  const PostCommentModel({
    required this.id,
    required this.author,
    required this.message,
    this.replyTo,
    this.createdAt = '',
    this.likeCount = 0,
    this.isLikedByMe = false,
    this.isReported = false,
    this.isEdited = false,
    this.reactions = const <String, int>{},
    this.mentions = const <String>[],
  });

  final String id;
  final String author;
  final String message;
  final String? replyTo;
  final String createdAt;
  final int likeCount;
  final bool isLikedByMe;
  final bool isReported;
  final bool isEdited;
  final Map<String, int> reactions;
  final List<String> mentions;

  PostCommentModel copyWith({
    String? message,
    int? likeCount,
    bool? isLikedByMe,
    bool? isReported,
    bool? isEdited,
    Map<String, int>? reactions,
    List<String>? mentions,
  }) {
    return PostCommentModel(
      id: id,
      author: author,
      message: message ?? this.message,
      replyTo: replyTo,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isReported: isReported ?? this.isReported,
      isEdited: isEdited ?? this.isEdited,
      reactions: reactions ?? this.reactions,
      mentions: mentions ?? this.mentions,
    );
  }
}
