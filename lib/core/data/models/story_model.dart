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
    };
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      media: json['media'] as String? ?? '',
      seen: json['seen'] as bool? ?? false,
      isLocalFile: json['isLocalFile'] as bool? ?? false,
      text: json['text'] as String?,
      music: json['music'] as String?,
      backgroundColors: List<int>.from(
        json['backgroundColors'] as List<dynamic>? ??
            const <dynamic>[0xFF1E40AF, 0xFF2BB0A1],
      ),
      textColorValue: json['textColorValue'] as int? ?? 0xFFFFFFFF,
    );
  }
}
