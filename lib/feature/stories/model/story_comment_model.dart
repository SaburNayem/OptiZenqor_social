class StoryCommentModel {
  const StoryCommentModel({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.comment,
  });

  final String id;
  final String storyId;
  final String userId;
  final String comment;
}
