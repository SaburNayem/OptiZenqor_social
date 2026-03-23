import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/post_model.dart';
import '../../../core/common_models/story_model.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';

enum FeedSegment { forYou, following, trending }

class HomeFeedRepository {
  HomeFeedRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  Future<List<PostModel>> fetchFeed({
    required FeedSegment segment,
    required int page,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final list = MockData.posts;
    await _storage.writeJsonList(
      StorageKeys.cachedFeed,
      list
          .map(
            (p) => {
              'id': p.id,
              'authorId': p.authorId,
              'caption': p.caption,
              'tags': p.tags,
              'media': p.media,
              'likes': p.likes,
              'comments': p.comments,
              'createdAt': p.createdAt.toIso8601String(),
              'viewCount': p.viewCount,
              'shareCount': p.shareCount,
              'taggedUserIds': p.taggedUserIds,
              'mentionUsernames': p.mentionUsernames,
              'location': p.location,
              'audience': p.audience,
              'altText': p.altText,
              'editHistory': p.editHistory,
              'isSponsored': p.isSponsored,
              'brandCollaborationLabel': p.brandCollaborationLabel,
              'repostHistory': p.repostHistory,
            },
          )
          .toList(),
    );
    segment;
    page;
    return list;
  }

  Future<List<PostModel>> readCachedFeed() async {
    final cached = await _storage.readJsonList(StorageKeys.cachedFeed);
    if (cached.isEmpty) {
      return <PostModel>[];
    }
    return cached
        .map(
          (item) => PostModel(
            id: item['id'] as String,
            authorId: item['authorId'] as String,
            caption: item['caption'] as String,
            tags: List<String>.from(item['tags'] as List<dynamic>),
            media: List<String>.from(item['media'] as List<dynamic>),
            likes: item['likes'] as int,
            comments: item['comments'] as int,
            createdAt: DateTime.parse(item['createdAt'] as String),
            viewCount: item['viewCount'] as int? ?? 0,
            shareCount: item['shareCount'] as int? ?? 0,
            taggedUserIds: List<String>.from(item['taggedUserIds'] as List<dynamic>? ?? const <dynamic>[]),
            mentionUsernames: List<String>.from(item['mentionUsernames'] as List<dynamic>? ?? const <dynamic>[]),
            location: item['location'] as String?,
            audience: item['audience'] as String? ?? 'Everyone',
            altText: item['altText'] as String?,
            editHistory: List<String>.from(item['editHistory'] as List<dynamic>? ?? const <dynamic>[]),
            isSponsored: item['isSponsored'] as bool? ?? false,
            brandCollaborationLabel: item['brandCollaborationLabel'] as String?,
            repostHistory: List<String>.from(item['repostHistory'] as List<dynamic>? ?? const <dynamic>[]),
          ),
        )
        .toList();
  }

  Future<List<StoryModel>> fetchStories() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return MockData.stories;
  }

  Future<Map<String, List<String>>> readRecommendationPreferences() async {
    final raw = await _storage.readJson(StorageKeys.recommendationPreferences);
    if (raw == null) {
      return <String, List<String>>{
        'lessLikeThis': <String>[],
        'hiddenCreators': <String>[],
        'hiddenTopics': <String>[],
      };
    }
    return <String, List<String>>{
      'lessLikeThis': List<String>.from(raw['lessLikeThis'] as List<dynamic>? ?? const <dynamic>[]),
      'hiddenCreators': List<String>.from(raw['hiddenCreators'] as List<dynamic>? ?? const <dynamic>[]),
      'hiddenTopics': List<String>.from(raw['hiddenTopics'] as List<dynamic>? ?? const <dynamic>[]),
    };
  }

  Future<void> writeRecommendationPreferences(Map<String, List<String>> prefs) {
    return _storage.writeJson(StorageKeys.recommendationPreferences, prefs);
  }
}
