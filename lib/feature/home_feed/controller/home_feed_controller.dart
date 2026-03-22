import 'package:flutter/foundation.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/post_model.dart';
import '../../../core/common_models/story_model.dart';
import '../../../core/enums/view_state.dart';

class HomeFeedController extends ChangeNotifier {
  HomeFeedController();

  ViewState state = ViewState.idle;
  List<PostModel> posts = <PostModel>[];
  List<StoryModel> stories = <StoryModel>[];
  int page = 1;

  Future<void> loadInitial() async {
    state = ViewState.loading;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      posts = MockData.posts;
      stories = MockData.stories;
      state = posts.isEmpty ? ViewState.empty : ViewState.success;
      notifyListeners();
    } catch (_) {
      state = ViewState.error;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadNextPage() async {
    page++;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final nextPosts = MockData.posts;
    posts = <PostModel>[...posts, ...nextPosts];
    notifyListeners();
  }
}
