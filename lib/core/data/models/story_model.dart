import '../../data/api/api_payload_reader.dart';
import '../../helpers/media_url_resolver.dart';
import '../../utils/app_id.dart';
import 'user_model.dart';

class StoryMediaTransform {
  const StoryMediaTransform({
    this.offsetDx = 0,
    this.offsetDy = 0,
    this.scale = 1,
    this.zIndex = 0,
    this.widthFactor = 0.68,
    this.heightFactor = 0.44,
    this.borderRadius = 24,
  });

  final double offsetDx;
  final double offsetDy;
  final double scale;
  final int zIndex;
  final double widthFactor;
  final double heightFactor;
  final double borderRadius;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'offsetDx': offsetDx,
      'offsetDy': offsetDy,
      'scale': scale,
      'zIndex': zIndex,
      'widthFactor': widthFactor,
      'heightFactor': heightFactor,
      'borderRadius': borderRadius,
    };
  }

  factory StoryMediaTransform.fromJson(Map<String, dynamic> json) {
    return StoryMediaTransform(
      offsetDx: ApiPayloadReader.readDouble(json['offsetDx']),
      offsetDy: ApiPayloadReader.readDouble(json['offsetDy']),
      scale: ApiPayloadReader.readDouble(json['scale']) == 0
          ? 1
          : ApiPayloadReader.readDouble(json['scale']),
      zIndex: ApiPayloadReader.readInt(json['zIndex']),
      widthFactor: ApiPayloadReader.readDouble(json['widthFactor']) == 0
          ? 0.68
          : ApiPayloadReader.readDouble(json['widthFactor']),
      heightFactor: ApiPayloadReader.readDouble(json['heightFactor']) == 0
          ? 0.44
          : ApiPayloadReader.readDouble(json['heightFactor']),
      borderRadius: ApiPayloadReader.readDouble(json['borderRadius']) == 0
          ? 24
          : ApiPayloadReader.readDouble(json['borderRadius']),
    );
  }

  StoryMediaTransform copyWith({
    double? offsetDx,
    double? offsetDy,
    double? scale,
    int? zIndex,
    double? widthFactor,
    double? heightFactor,
    double? borderRadius,
  }) {
    return StoryMediaTransform(
      offsetDx: offsetDx ?? this.offsetDx,
      offsetDy: offsetDy ?? this.offsetDy,
      scale: scale ?? this.scale,
      zIndex: zIndex ?? this.zIndex,
      widthFactor: widthFactor ?? this.widthFactor,
      heightFactor: heightFactor ?? this.heightFactor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

class StoryModel {
  static const Duration visibleDuration = Duration(hours: 24);

  const StoryModel({
    required this.id,
    required this.userId,
    this.media = '',
    this.mediaItems = const <String>[],
    this.seen = false,
    this.isLocalFile = false,
    this.text,
    this.music,
    this.backgroundColors = const <int>[0xFF1E40AF, 0xFF2BB0A1],
    this.textColorValue = 0xFFFFFFFF,
    this.createdAt,
    this.expiresAt,
    this.author,
    this.sticker,
    this.effectName,
    this.mentionUsername,
    this.linkLabel,
    this.linkUrl,
    this.privacy = 'Everyone',
    this.collageLayout = 'grid',
    this.textOffsetDx = 0,
    this.textOffsetDy = 0,
    this.textScale = 1,
    this.mediaTransforms = const <StoryMediaTransform>[],
  });

  final String id;
  final String userId;
  final String media;
  final List<String> mediaItems;
  final bool seen;
  final bool isLocalFile;
  final String? text;
  final String? music;
  final List<int> backgroundColors;
  final int textColorValue;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final UserModel? author;
  final String? sticker;
  final String? effectName;
  final String? mentionUsername;
  final String? linkLabel;
  final String? linkUrl;
  final String privacy;
  final String collageLayout;
  final double textOffsetDx;
  final double textOffsetDy;
  final double textScale;
  final List<StoryMediaTransform> mediaTransforms;

  bool get hasMedia => media.trim().isNotEmpty || mediaItems.isNotEmpty;
  bool get hasText => (text ?? '').trim().isNotEmpty;
  String get apiPrivacy => normalizePrivacyForApi(privacy);
  bool get isActive {
    if (expiresAt != null) {
      return DateTime.now().isBefore(expiresAt!);
    }
    final DateTime createdTime = createdAt ?? DateTime.now();
    return DateTime.now().difference(createdTime) < visibleDuration;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'media': media,
      'mediaItems': mediaItems,
      'seen': seen,
      'isLocalFile': isLocalFile,
      'text': text,
      'music': music,
      'backgroundColors': backgroundColors,
      'textColorValue': textColorValue,
      'createdAt': createdAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      if (author != null) 'author': author!.toJson(),
      'sticker': sticker,
      'effectName': effectName,
      'mentionUsername': mentionUsername,
      'linkLabel': linkLabel,
      'linkUrl': linkUrl,
      'privacy': privacy,
      'collageLayout': collageLayout,
      'textOffsetDx': textOffsetDx,
      'textOffsetDy': textOffsetDy,
      'textScale': textScale,
      'mediaTransforms': mediaTransforms
          .map((StoryMediaTransform item) => item.toJson())
          .toList(growable: false),
    };
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? author = _readStoryAuthor(json);
    final List<String> mediaItems = _readStoryMediaItems(json);
    final String resolvedId = ApiPayloadReader.readString(
      json['id'] ?? json['_id'] ?? json['storyId'],
    );
    AppId.warnIfNotProductionId(resolvedId, entity: 'story');
    return StoryModel(
      id: resolvedId,
      userId: ApiPayloadReader.readString(
        json['userId'] ??
            json['authorId'] ??
            json['creatorId'] ??
            json['ownerId'] ??
            author?['id'] ??
            author?['_id'],
      ),
      media: MediaUrlResolver.resolve(
        ApiPayloadReader.readString(
          json['media'] ??
              json['mediaUrl'] ??
              json['image'] ??
              json['imageUrl'] ??
              json['url'] ??
              json['fileUrl'] ??
              (mediaItems.isEmpty ? '' : mediaItems.first),
        ),
      ),
      mediaItems: mediaItems
          .map(MediaUrlResolver.resolve)
          .toList(growable: false),
      seen: ApiPayloadReader.readBool(json['seen'] ?? json['viewed']) ?? false,
      isLocalFile: ApiPayloadReader.readBool(json['isLocalFile']) ?? false,
      text: ApiPayloadReader.readString(json['text']),
      music: ApiPayloadReader.readString(json['music']),
      backgroundColors: _readColorList(json['backgroundColors']),
      textColorValue: ApiPayloadReader.readInt(json['textColorValue']),
      createdAt: ApiPayloadReader.readDateTime(
        json['createdAt'] ?? json['created_at'] ?? json['timestamp'],
      ),
      expiresAt: ApiPayloadReader.readDateTime(
        json['expiresAt'] ?? json['expires_at'],
      ),
      author: author == null ? null : UserModel.fromApiJson(author),
      sticker: ApiPayloadReader.readString(json['sticker']),
      effectName: ApiPayloadReader.readString(json['effectName']),
      mentionUsername: ApiPayloadReader.readString(json['mentionUsername']),
      linkLabel: ApiPayloadReader.readString(json['linkLabel']),
      linkUrl: ApiPayloadReader.readString(json['linkUrl']),
      privacy: ApiPayloadReader.readString(
        json['privacy'],
        fallback: 'public',
      ),
      collageLayout: ApiPayloadReader.readString(
        json['collageLayout'],
        fallback: 'grid',
      ),
      textOffsetDx: ApiPayloadReader.readDouble(json['textOffsetDx']),
      textOffsetDy: ApiPayloadReader.readDouble(json['textOffsetDy']),
      textScale: ApiPayloadReader.readDouble(json['textScale']) == 0
          ? 1
          : ApiPayloadReader.readDouble(json['textScale']),
      mediaTransforms: _readMediaTransformList(json['mediaTransforms']),
    );
  }

  StoryModel copyWith({
    String? id,
    String? userId,
    String? media,
    List<String>? mediaItems,
    bool? seen,
    bool? isLocalFile,
    String? text,
    String? music,
    List<int>? backgroundColors,
    int? textColorValue,
    DateTime? createdAt,
    DateTime? expiresAt,
    UserModel? author,
    String? sticker,
    String? effectName,
    String? mentionUsername,
    String? linkLabel,
    String? linkUrl,
    String? privacy,
    String? collageLayout,
    double? textOffsetDx,
    double? textOffsetDy,
    double? textScale,
    List<StoryMediaTransform>? mediaTransforms,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      media: media ?? this.media,
      mediaItems: mediaItems ?? this.mediaItems,
      seen: seen ?? this.seen,
      isLocalFile: isLocalFile ?? this.isLocalFile,
      text: text ?? this.text,
      music: music ?? this.music,
      backgroundColors: backgroundColors ?? this.backgroundColors,
      textColorValue: textColorValue ?? this.textColorValue,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      author: author ?? this.author,
      sticker: sticker ?? this.sticker,
      effectName: effectName ?? this.effectName,
      mentionUsername: mentionUsername ?? this.mentionUsername,
      linkLabel: linkLabel ?? this.linkLabel,
      linkUrl: linkUrl ?? this.linkUrl,
      privacy: privacy ?? this.privacy,
      collageLayout: collageLayout ?? this.collageLayout,
      textOffsetDx: textOffsetDx ?? this.textOffsetDx,
      textOffsetDy: textOffsetDy ?? this.textOffsetDy,
      textScale: textScale ?? this.textScale,
      mediaTransforms: mediaTransforms ?? this.mediaTransforms,
    );
  }

  static List<String> _readStringList(Object? value) {
    if (value is List) {
      return value
          .map(_readMediaPath)
          .where((String item) => item.trim().isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }

  static String _readMediaPath(Object? value) {
    final Map<String, dynamic>? mediaMap = ApiPayloadReader.readMap(value);
    if (mediaMap != null) {
      return ApiPayloadReader.readString(
        mediaMap['url'] ??
            mediaMap['mediaUrl'] ??
            mediaMap['imageUrl'] ??
            mediaMap['fileUrl'] ??
            mediaMap['path'] ??
            mediaMap['src'],
      );
    }
    return ApiPayloadReader.readString(value);
  }

  static Map<String, dynamic>? _readStoryAuthor(Map<String, dynamic> json) {
    final Object? rawAuthor =
        json['author'] ?? json['user'] ?? json['creator'] ?? json['profile'];
    final Map<String, dynamic>? author = ApiPayloadReader.readMap(rawAuthor);
    final String userId = ApiPayloadReader.readString(
      json['userId'] ??
          json['authorId'] ??
          json['creatorId'] ??
          json['ownerId'] ??
          author?['id'] ??
          author?['_id'],
    );
    final String name = ApiPayloadReader.readString(
      json['authorName'] ??
          json['name'] ??
          json['displayName'] ??
          json['fullName'] ??
          (rawAuthor is String ? rawAuthor : null) ??
          author?['name'] ??
          author?['displayName'] ??
          author?['fullName'],
    );
    final String username = ApiPayloadReader.readString(
      json['authorUsername'] ??
          json['username'] ??
          json['handle'] ??
          author?['username'] ??
          author?['handle'],
    );

    if (author == null) {
      if (name.isEmpty && username.isEmpty && userId.isEmpty) {
        return null;
      }
      return <String, dynamic>{
        if (userId.isNotEmpty) 'id': userId,
        if (name.isNotEmpty) 'name': name,
        if (username.isNotEmpty) 'username': username,
        if (json['avatar'] != null) 'avatar': json['avatar'],
        if (json['avatarUrl'] != null) 'avatarUrl': json['avatarUrl'],
      };
    }

    return <String, dynamic>{
      ...author,
      if (!author.containsKey('id') && userId.isNotEmpty) 'id': userId,
      if (!author.containsKey('name') && name.isNotEmpty) 'name': name,
      if (!author.containsKey('username') && username.isNotEmpty)
        'username': username,
    };
  }

  static List<String> _readStoryMediaItems(Map<String, dynamic> json) {
    final List<String> directItems = _readStringList(
      json['mediaItems'] ??
          json['mediaUrls'] ??
          json['media_files'] ??
          json['files'] ??
          json['attachments'],
    );
    if (directItems.isNotEmpty) {
      return directItems;
    }

    final String singleMedia = ApiPayloadReader.readString(
      json['media'] ??
          json['mediaUrl'] ??
          json['image'] ??
          json['imageUrl'] ??
          json['url'] ??
          json['fileUrl'],
    );
    return singleMedia.isEmpty ? const <String>[] : <String>[singleMedia];
  }

  static List<int> _readColorList(Object? value) {
    if (value is List) {
      final List<int> colors = value
          .map((Object? item) => ApiPayloadReader.readInt(item))
          .where((int item) => item != 0)
          .toList(growable: false);
      if (colors.isNotEmpty) {
        return colors;
      }
    }
    return const <int>[0xFF1E40AF, 0xFF2BB0A1];
  }

  static List<StoryMediaTransform> _readMediaTransformList(Object? value) {
    if (value is List) {
      return value
          .map((Object? item) => ApiPayloadReader.readMap(item))
          .whereType<Map<String, dynamic>>()
          .map(StoryMediaTransform.fromJson)
          .toList(growable: false);
    }
    return const <StoryMediaTransform>[];
  }
}

String normalizePrivacyForApi(String value) {
  switch (value.trim().toLowerCase()) {
    case 'everyone':
    case 'public':
      return 'public';
    case 'followers':
      return 'followers';
    case 'only me':
    case 'only_me':
    case 'private':
      return 'private';
    default:
      return 'public';
  }
}
