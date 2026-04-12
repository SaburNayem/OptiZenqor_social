class StoryPreviewModel {
  const StoryPreviewModel({
    required this.mediaPath,
    this.isLocalFile = false,
    this.isVideo = false,
    this.initialText = '',
    this.initialMusic = 'Late Night Drive',
  });

  final String mediaPath;
  final bool isLocalFile;
  final bool isVideo;
  final String initialText;
  final String initialMusic;
}
