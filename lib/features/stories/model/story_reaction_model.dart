class StoryReactionModel {
  const StoryReactionModel({
    required this.storyId,
    required this.userId,
    required this.reaction,
  });

  final String storyId;
  final String userId;
  final String reaction;
}
