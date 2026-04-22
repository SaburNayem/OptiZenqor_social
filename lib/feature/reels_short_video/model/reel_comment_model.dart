class ReelCommentModel {
  const ReelCommentModel({
    required this.id,
    required this.reelId,
    required this.userId,
    required this.comment,
  });

  final String id;
  final String reelId;
  final String userId;
  final String comment;
}
