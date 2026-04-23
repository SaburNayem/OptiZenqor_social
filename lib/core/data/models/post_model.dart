import 'user_model.dart';

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
    return PostModel(
      id: (json['id'] as Object? ?? '').toString(),
      authorId:
          (json['authorId'] as Object? ?? authorJson?['id'] ?? '').toString(),
      caption: (json['caption'] as String? ?? '').trim(),
      tags: _readStringList(json['tags']),
      media: _readStringList(json['media']),
      likes: _readCount(json['likes']),
      comments: _readCount(json['comments']),
      createdAt: _readDateTime(json['createdAt']),
      viewCount: _readCount(json['views'] ?? json['viewCount']),
      shareCount: _readCount(json['shares'] ?? json['shareCount']),
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
    int? likes,
    int? comments,
    int? viewCount,
    int? shareCount,
    UserModel? author,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      caption: caption,
      tags: tags,
      media: media,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      taggedUserIds: taggedUserIds,
      mentionUsernames: mentionUsernames,
      location: location,
      audience: audience,
      altText: altText,
      editHistory: editHistory,
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
          .map((Object? item) => item?.toString() ?? '')
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
