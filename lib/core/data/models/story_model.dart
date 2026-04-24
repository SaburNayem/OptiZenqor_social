import '../../data/api/api_payload_reader.dart';
import 'user_model.dart';

class StoryModel {
  const StoryModel({
    required this.id,
    required this.userId,
    this.media = '',
    this.seen = false,
    this.isLocalFile = false,
    this.text,
    this.music,
    this.backgroundColors = const <int>[0xFF1E40AF, 0xFF2BB0A1],
    this.textColorValue = 0xFFFFFFFF,
    this.createdAt,
    this.author,
    this.sticker,
    this.effectName,
    this.mentionUsername,
    this.linkLabel,
    this.linkUrl,
    this.privacy = 'Everyone',
  });

  final String id;
  final String userId;
  final String media;
  final bool seen;
  final bool isLocalFile;
  final String? text;
  final String? music;
  final List<int> backgroundColors;
  final int textColorValue;
  final DateTime? createdAt;
  final UserModel? author;
  final String? sticker;
  final String? effectName;
  final String? mentionUsername;
  final String? linkLabel;
  final String? linkUrl;
  final String privacy;

  bool get hasMedia => media.trim().isNotEmpty;
  bool get hasText => (text ?? '').trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'media': media,
      'seen': seen,
      'isLocalFile': isLocalFile,
      'text': text,
      'music': music,
      'backgroundColors': backgroundColors,
      'textColorValue': textColorValue,
      'createdAt': createdAt?.toIso8601String(),
      if (author != null) 'author': author!.toJson(),
      'sticker': sticker,
      'effectName': effectName,
      'mentionUsername': mentionUsername,
      'linkLabel': linkLabel,
      'linkUrl': linkUrl,
      'privacy': privacy,
    };
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? author = ApiPayloadReader.readMap(
      json['author'],
    );
    return StoryModel(
      id: ApiPayloadReader.readString(json['id']),
      userId: ApiPayloadReader.readString(
        json['userId'] ?? author?['id'],
      ),
      media: ApiPayloadReader.readString(json['media']),
      seen: ApiPayloadReader.readBool(json['seen']) ?? false,
      isLocalFile: ApiPayloadReader.readBool(json['isLocalFile']) ?? false,
      text: ApiPayloadReader.readString(json['text']),
      music: ApiPayloadReader.readString(json['music']),
      backgroundColors: _readColorList(json['backgroundColors']),
      textColorValue: ApiPayloadReader.readInt(
        json['textColorValue'],
      ),
      createdAt: ApiPayloadReader.readDateTime(json['createdAt']),
      author: author == null ? null : UserModel.fromApiJson(author),
      sticker: ApiPayloadReader.readString(json['sticker']),
      effectName: ApiPayloadReader.readString(json['effectName']),
      mentionUsername: ApiPayloadReader.readString(json['mentionUsername']),
      linkLabel: ApiPayloadReader.readString(json['linkLabel']),
      linkUrl: ApiPayloadReader.readString(json['linkUrl']),
      privacy: ApiPayloadReader.readString(
        json['privacy'],
        fallback: 'Everyone',
      ),
    );
  }

  StoryModel copyWith({
    String? id,
    String? userId,
    String? media,
    bool? seen,
    bool? isLocalFile,
    String? text,
    String? music,
    List<int>? backgroundColors,
    int? textColorValue,
    DateTime? createdAt,
    UserModel? author,
    String? sticker,
    String? effectName,
    String? mentionUsername,
    String? linkLabel,
    String? linkUrl,
    String? privacy,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      media: media ?? this.media,
      seen: seen ?? this.seen,
      isLocalFile: isLocalFile ?? this.isLocalFile,
      text: text ?? this.text,
      music: music ?? this.music,
      backgroundColors: backgroundColors ?? this.backgroundColors,
      textColorValue: textColorValue ?? this.textColorValue,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
      sticker: sticker ?? this.sticker,
      effectName: effectName ?? this.effectName,
      mentionUsername: mentionUsername ?? this.mentionUsername,
      linkLabel: linkLabel ?? this.linkLabel,
      linkUrl: linkUrl ?? this.linkUrl,
      privacy: privacy ?? this.privacy,
    );
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
}
