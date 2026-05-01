class MediaViewerItemModel {
  const MediaViewerItemModel({required this.source, required this.type});

  final String source;
  final String type;

  bool get isVideo => type == videoType;

  bool get isNetworkSource =>
      source.startsWith('http://') || source.startsWith('https://');

  static const String imageType = 'image';
  static const String videoType = 'video';

  factory MediaViewerItemModel.fromSource(String source) {
    return MediaViewerItemModel(source: source, type: detectType(source));
  }

  static String detectType(String source) {
    final String normalized =
        Uri.tryParse(source)?.path.toLowerCase() ?? source.toLowerCase();
    const List<String> videoExtensions = <String>[
      '.mp4',
      '.mov',
      '.m4v',
      '.webm',
      '.mkv',
      '.avi',
    ];
    final bool isVideo = videoExtensions.any(normalized.endsWith);
    return isVideo ? videoType : imageType;
  }
}
