import 'package:flutter/material.dart';

import '../../../core/data/models/story_model.dart';
import '../model/story_view_state_model.dart';

class StoriesController extends ChangeNotifier {
  StoriesController({
    required List<StoryModel> stories,
    required int startIndex,
  }) : _stories = stories,
       _state = StoryViewStateModel(currentIndex: startIndex),
       pageController = PageController(initialPage: startIndex);

  final List<StoryModel> _stories;
  final PageController pageController;
  StoryViewStateModel _state;

  int get currentIndex => _state.currentIndex;
  List<StoryModel> get stories => _stories;

  void onPageChanged(int index) {
    _state = _state.copyWith(currentIndex: index);
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
