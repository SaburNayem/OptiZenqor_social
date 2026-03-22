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
          ),
        )
        .toList();
  }

  Future<List<StoryModel>> fetchStories() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return MockData.stories;
  }
}
