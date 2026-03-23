class ReelModel {
  const ReelModel({
    required this.id,
    required this.authorId,
    required this.caption,
    required this.audioName,
    required this.thumbnail,
    this.videoUrl,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  final String id;
  final String authorId;
  final String caption;
  final String audioName;
  final String thumbnail;
  final String? videoUrl;
  final int likes;
  final int comments;
  final int shares;
}
