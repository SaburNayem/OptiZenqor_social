import '../../../core/data/models/post_model.dart';

class HomeFeedPostFactory {
  HomeFeedPostFactory._();

  static PostModel buildLocalPost({
    required String caption,
    required List<String> mediaPaths,
    required String audience,
    String? location,
    List<String> taggedPeople = const <String>[],
    List<String> coAuthors = const <String>[],
    String? altText,
    List<String> editHistory = const <String>[],
  }) {
    final String trimmedCaption = caption.trim();
    final List<String> media = mediaPaths
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    return PostModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      authorId: 'u1',
      caption: trimmedCaption,
      tags: const <String>['#local'],
      media: media,
      likes: 0,
      comments: 0,
      createdAt: DateTime.now(),
      viewCount: 1,
      shareCount: 0,
      taggedUserIds: taggedPeople
          .map((item) => item.replaceFirst('@', ''))
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      mentionUsernames: coAuthors
          .map((item) => item.replaceFirst('@', ''))
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      location: location,
      audience: audience,
      altText: altText,
      editHistory: editHistory,
    );
  }

  static Map<String, List<String>> buildRecommendationPreferences({
    required Set<String> lessLikeThisPostIds,
    required Set<String> hiddenCreatorIds,
    required Set<String> hiddenTopics,
  }) {
    return <String, List<String>>{
      'lessLikeThis': lessLikeThisPostIds.toList(),
      'hiddenCreators': hiddenCreatorIds.toList(),
      'hiddenTopics': hiddenTopics.toList(),
    };
  }
}
