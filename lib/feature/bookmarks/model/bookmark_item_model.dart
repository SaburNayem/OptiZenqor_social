import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/api/api_payload_reader.dart';

enum BookmarkType { post, reel, product }

class BookmarkItemModel {
  const BookmarkItemModel({
    required this.id,
    required this.title,
    required this.type,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.caption,
    required this.thumbnail,
    required this.savedAt,
    this.isVideo = false,
  });

  final String id;
  final String title;
  final BookmarkType type;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String caption;
  final String thumbnail;
  final DateTime savedAt;
  final bool isVideo;

  String get displayTitle => title.isEmpty ? caption : title;

  BookmarkItemModel copyWith({
    String? title,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? caption,
    String? thumbnail,
    DateTime? savedAt,
    bool? isVideo,
  }) {
    return BookmarkItemModel(
      id: id,
      title: title ?? this.title,
      type: type,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      caption: caption ?? this.caption,
      thumbnail: thumbnail ?? this.thumbnail,
      savedAt: savedAt ?? this.savedAt,
      isVideo: isVideo ?? this.isVideo,
    );
  }

  factory BookmarkItemModel.fromPost({
    required PostModel post,
    required UserModel author,
  }) {
    final String thumbnail = post.media.isEmpty ? '' : post.media.first;
    final String caption = post.caption.trim();

    return BookmarkItemModel(
      id: post.id,
      title: caption,
      type: BookmarkType.post,
      authorId: author.id,
      authorName: author.name,
      authorAvatar: author.avatar,
      caption: caption,
      thumbnail: thumbnail,
      savedAt: DateTime.now(),
      isVideo: _isVideoPath(thumbnail),
    );
  }

  factory BookmarkItemModel.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? author = ApiPayloadReader.readMap(
      json['author'],
    );
    final Map<String, dynamic>? post = ApiPayloadReader.readMap(json['post']);
    final String title = ApiPayloadReader.readString(
      json['title'] ?? json['caption'] ?? post?['caption'],
      fallback: 'Saved item',
    );
    final String thumbnail = ApiPayloadReader.readString(
      json['thumbnail'] ??
          json['thumbnailUrl'] ??
          post?['thumbnail'] ??
          (post?['media'] is List && (post?['media'] as List).isNotEmpty
              ? (post?['media'] as List).first
              : null),
    );
    final String typeValue = ApiPayloadReader.readString(
      json['type'] ?? json['entityType'],
      fallback: 'post',
    );

    return BookmarkItemModel(
      id: ApiPayloadReader.readString(
        json['id'] ?? json['postId'] ?? post?['id'],
      ),
      title: title,
      type: BookmarkType.values.firstWhere(
        (BookmarkType value) => value.name == typeValue.toLowerCase(),
        orElse: () => BookmarkType.post,
      ),
      authorId: ApiPayloadReader.readString(
        json['authorId'] ?? author?['id'] ?? post?['authorId'],
      ),
      authorName: ApiPayloadReader.readString(
        json['authorName'] ?? author?['name'],
        fallback: 'Unknown creator',
      ),
      authorAvatar: ApiPayloadReader.readString(
        json['authorAvatar'] ?? author?['avatar'] ?? author?['avatarUrl'],
      ),
      caption: ApiPayloadReader.readString(
        json['caption'] ?? post?['caption'],
        fallback: title,
      ),
      thumbnail: thumbnail,
      savedAt:
          ApiPayloadReader.readDateTime(
            json['savedAt'] ?? json['createdAt'],
          ) ??
          DateTime.now(),
      isVideo:
          ApiPayloadReader.readBool(json['isVideo']) ?? _isVideoPath(thumbnail),
    );
  }

  static bool _isVideoPath(String value) {
    final String lower = value.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm');
  }
}
