import 'user_model.dart';
import '../../helpers/media_url_resolver.dart';
import '../../utils/app_id.dart';

class PostModel {
  const PostModel({
    required this.id,
    required this.authorId,
    required this.caption,
    required this.tags,
    required this.media,
    required this.likes,
    required this.comments,
    required this.createdAt,
    this.liked = false,
    this.viewCount = 0,
    this.shareCount = 0,
    this.taggedUserIds = const <String>[],
    this.mentionUsernames = const <String>[],
    this.location,
    this.audience = 'Everyone',
    this.altText,
    this.editHistory = const <String>[],
    this.isSponsored = false,
    this.brandCollaborationLabel,
    this.repostHistory = const <String>[],
    this.author,
  });

  factory PostModel.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? authorJson = _readMap(json['author']);
    final String resolvedId =
        (json['id'] as Object? ?? json['_id'] as Object? ?? '').toString();
    AppId.warnIfNotProductionId(resolvedId, entity: 'post');
    return PostModel(
      id: resolvedId,
      authorId:
          (json['authorId'] as Object? ??
                  json['author_id'] as Object? ??
                  authorJson?['id'] ??
                  authorJson?['_id'] ??
                  '')
          .toString(),
      caption: (json['caption'] as String? ?? '').trim(),
      tags: _readStringList(json['tags']),
      media: _readStringList(
        json['media'] ?? json['mediaItems'] ?? json['media_items'],
      ).map(MediaUrlResolver.resolve).toList(growable: false),
      likes: _readCount(
        json['likes'] ?? json['likesCount'] ?? json['likes_count'],
      ),
      comments: _readCount(
        json['comments'] ?? json['commentsCount'] ?? json['comments_count'],
      ),
      createdAt: _readDateTime(json['createdAt'] ?? json['created_at']),
      liked:
          json['liked'] as bool? ??
          json['isLiked'] as bool? ??
          json['isLikedByMe'] as bool? ??
          false,
      viewCount: _readCount(
        json['views'] ?? json['viewCount'] ?? json['viewsCount'] ?? json['views_count'],
      ),
      shareCount: _readCount(
        json['shares'] ??
            json['shareCount'] ??
            json['sharesCount'] ??
            json['shares_count'],
      ),
      taggedUserIds: _readStringList(json['taggedUserIds']),
      mentionUsernames: _readStringList(json['mentionUsernames']),
      location: json['location'] as String?,
      audience: (json['audience'] as String? ?? 'Everyone').trim(),
      altText: json['altText'] as String?,
      editHistory: _readStringList(json['editHistory']),
      isSponsored: json['isSponsored'] as bool? ?? false,
      brandCollaborationLabel: json['brandCollaborationLabel'] as String?,
      repostHistory: _readStringList(json['repostHistory']),
      author: authorJson == null ? null : UserModel.fromApiJson(authorJson),
    );
  }

  final String id;
  final String authorId;
  final String caption;
  final List<String> tags;
  final List<String> media;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final bool liked;
  final int viewCount;
  final int shareCount;
  final List<String> taggedUserIds;
  final List<String> mentionUsernames;
  final String? location;
  final String audience;
  final String? altText;
  final List<String> editHistory;
  final bool isSponsored;
  final String? brandCollaborationLabel;
  final List<String> repostHistory;
  final UserModel? author;

  PostModel copyWith({
    bool? liked,
    String? caption,
    List<String>? media,
    int? likes,
    int? comments,
    int? viewCount,
    int? shareCount,
    List<String>? editHistory,
    UserModel? author,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      caption: caption ?? this.caption,
      tags: tags,
      media: media ?? this.media,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt,
      liked: liked ?? this.liked,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      taggedUserIds: taggedUserIds,
      mentionUsernames: mentionUsernames,
      location: location,
      audience: audience,
      altText: altText,
      editHistory: editHistory ?? this.editHistory,
      isSponsored: isSponsored,
      brandCollaborationLabel: brandCollaborationLabel,
      repostHistory: repostHistory,
      author: author ?? this.author,
    );
  }

  Map<String, dynamic> toCacheJson() {
    return <String, dynamic>{
      'id': id,
      'authorId': authorId,
      'caption': caption,
      'tags': tags,
      'media': media,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt.toIso8601String(),
      'liked': liked,
      'viewCount': viewCount,
      'shareCount': shareCount,
      'taggedUserIds': taggedUserIds,
      'mentionUsernames': mentionUsernames,
      'location': location,
      'audience': audience,
      'altText': altText,
      'editHistory': editHistory,
      'isSponsored': isSponsored,
      'brandCollaborationLabel': brandCollaborationLabel,
      'repostHistory': repostHistory,
      if (author != null) 'author': author!.toJson(),
    };
  }

  static List<String> _readStringList(Object? value) {
    if (value is List) {
      return value
          .map((Object? item) {
            if (item is Map<String, dynamic>) {
              return (item['url'] ??
                          item['mediaUrl'] ??
                          item['imageUrl'] ??
                          item['fileUrl'] ??
                          item['path'] ??
                          item['src'] ??
                          '')
                      .toString();
            }
            if (item is Map) {
              return (item['url'] ??
                          item['mediaUrl'] ??
                          item['imageUrl'] ??
                          item['fileUrl'] ??
                          item['path'] ??
                          item['src'] ??
                          '')
                      .toString();
            }
            return item?.toString() ?? '';
          })
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }

  static int _readCount(Object? value) {
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

  static DateTime _readDateTime(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
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
}
