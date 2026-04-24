class StoryPreviewModel {
  const StoryPreviewModel({
    this.mediaPath = '',
    this.mediaPaths = const <String>[],
    this.isLocalFile = false,
    this.isVideo = false,
    this.initialText = '',
    this.initialMusic = 'Late Night Drive',
    this.initialCollageLayout = 'grid',
  });

  final String mediaPath;
  final List<String> mediaPaths;
  final bool isLocalFile;
  final bool isVideo;
  final String initialText;
  final String initialMusic;
  final String initialCollageLayout;

  List<String> get resolvedMediaPaths {
    if (mediaPaths.isNotEmpty) {
      return mediaPaths;
    }
    if (mediaPath.trim().isNotEmpty) {
      return <String>[mediaPath];
    }
    return const <String>[];
  }

  bool get hasMultipleMedia => resolvedMediaPaths.length > 1;
}
