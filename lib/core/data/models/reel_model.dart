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

  factory ReelModel.fromApiJson(Map<String, dynamic> json) {
    return ReelModel(
      id: (json['id'] as Object? ?? '').toString(),
      authorId:
          (json['authorId'] as Object? ?? json['userId'] as Object? ?? '')
              .toString(),
      caption: (json['caption'] as String? ?? '').trim(),
      audioName: (json['audioName'] as String? ?? json['audio'] as String? ?? '')
          .trim(),
      thumbnail:
          (json['thumbnail'] as String? ??
                  json['thumbnailUrl'] as String? ??
                  json['coverUrl'] as String? ??
                  '')
              .trim(),
      videoUrl: (json['videoUrl'] as String? ?? json['video'] as String?)
          ?.trim(),
      likes: _readInt(json['likes']),
      comments: _readInt(json['comments']),
      shares: _readInt(json['shares']),
      viewCount: _readInt(json['viewCount'] ?? json['views']),
      coverUrl:
          (json['coverUrl'] as String? ?? json['coverImageUrl'] as String?)
              ?.trim(),
      textOverlays: _readStringList(json['textOverlays']),
      subtitleEnabled: json['subtitleEnabled'] as bool? ?? false,
      trimInfo: (json['trimInfo'] as String?)?.trim(),
      remixEnabled: json['remixEnabled'] as bool? ?? false,
      isDraft: json['isDraft'] as bool? ?? false,
    );
  }

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

  static int _readInt(Object? value) {
    if (value is List) {
      return value.length;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _readStringList(Object? value) {
    if (value is List) {
      return value
          .map((Object? item) => item?.toString() ?? '')
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }
}
