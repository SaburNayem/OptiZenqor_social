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
    this.viewCount = 0,
    this.coverUrl,
    this.textOverlays = const <String>[],
    this.subtitleEnabled = false,
    this.trimInfo,
    this.remixEnabled = false,
    this.isDraft = false,
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
  final int viewCount;
  final String? coverUrl;
  final List<String> textOverlays;
  final bool subtitleEnabled;
  final String? trimInfo;
  final bool remixEnabled;
  final bool isDraft;
}
