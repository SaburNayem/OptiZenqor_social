import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';

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

  static bool _isVideoPath(String value) {
    final String lower = value.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm');
  }
}
