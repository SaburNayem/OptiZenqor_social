class CreatePostResult {
  const CreatePostResult({
    required this.caption,
    this.mediaPaths = const <String>[],
    this.isVideo = false,
    this.audience = 'Everyone',
    this.location,
    this.taggedPeople = const <String>[],
    this.taggedUserIds = const <String>[],
    this.coAuthors = const <String>[],
    this.mentionUsernames = const <String>[],
    this.altText,
    this.editHistory = const <String>[],
    this.feeling,
  });

  final String caption;
  final List<String> mediaPaths;
  final bool isVideo;
  final String audience;
  final String? location;
  final List<String> taggedPeople;
  final List<String> taggedUserIds;
  final List<String> coAuthors;
  final List<String> mentionUsernames;
  final String? altText;
  final List<String> editHistory;
  final String? feeling;
}
