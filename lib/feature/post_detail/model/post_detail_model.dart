import '../../../core/data/models/user_model.dart';

class PostDetailModel {
  const PostDetailModel({
    required this.id,
    required this.authorId,
    required this.caption,
    required this.media,
    required this.likes,
    required this.comments,
    required this.createdAt,
    this.shareCount = 0,
    this.viewCount = 0,
    this.bookmarkCount = 0,
    this.audience = 'Everyone',
    this.author,
  });

  factory PostDetailModel.fromApiJson(
    Map<String, dynamic> json, {
    int? liveCommentCount,
  }) {
    final Map<String, dynamic> detailJson = _readMap(json['detail']) ?? json;
    final Map<String, dynamic> engagementSummary =
        _readMap(detailJson['engagementSummary']) ?? const <String, dynamic>{};

    return PostDetailModel(
      id:
          (detailJson['id'] as Object? ??
                  json['id'] as Object? ??
                  '')
              .toString(),
      authorId:
          (detailJson['authorId'] as Object? ??
                  json['authorId'] as Object? ??
                  '')
              .toString(),
      caption:
          (detailJson['caption'] as String? ??
                  json['caption'] as String? ??
                  '')
              .trim(),
      media: _readStringList(detailJson['media'] ?? json['media']),
      likes: _readInt(
        engagementSummary['likes'] ?? detailJson['likes'] ?? json['likes'],
      ),
      comments:
          liveCommentCount ??
          _readInt(
            engagementSummary['comments'] ??
                detailJson['comments'] ??
                json['comments'],
          ),
      createdAt: _readDateTime(detailJson['createdAt'] ?? json['createdAt']),
      shareCount: _readInt(
        engagementSummary['shares'] ?? detailJson['shares'] ?? json['shares'],
      ),
      viewCount: _readInt(detailJson['views'] ?? json['views']),
      bookmarkCount: _readInt(engagementSummary['bookmarks']),
      audience: (detailJson['audience'] as String? ?? 'Everyone').trim(),
      author: _readMap(json['author']) == null
          ? null
          : UserModel.fromApiJson(_readMap(json['author'])!),
    );
  }

  final String id;
  final String authorId;
  final String caption;
  final List<String> media;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final int shareCount;
  final int viewCount;
  final int bookmarkCount;
  final String audience;
  final UserModel? author;

  PostDetailModel copyWith({
    int? likes,
    int? comments,
    int? shareCount,
    int? viewCount,
    int? bookmarkCount,
    UserModel? author,
  }) {
    return PostDetailModel(
      id: id,
      authorId: authorId,
      caption: caption,
      media: media,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt,
      shareCount: shareCount ?? this.shareCount,
      viewCount: viewCount ?? this.viewCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      audience: audience,
      author: author ?? this.author,
    );
  }

  static Map<String, dynamic>? _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
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

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is List) {
      return value.length;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _readDateTime(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
