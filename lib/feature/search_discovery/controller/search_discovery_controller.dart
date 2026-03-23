import 'package:flutter/foundation.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/post_model.dart';
import '../../../core/common_models/user_model.dart';
import '../../../core/utils/debouncer.dart';

enum SearchEntityFilter {
  newest,
  top,
  people,
  media,
  groups,
  products,
  jobs,
}

class SearchDiscoveryController extends ChangeNotifier {
  SearchDiscoveryController() : _debouncer = Debouncer(milliseconds: 350);

  final Debouncer _debouncer;

  List<UserModel> userResults = <UserModel>[];
  List<PostModel> mediaResults = <PostModel>[];
  SearchEntityFilter activeFilter = SearchEntityFilter.top;

  final List<String> trendingTerms = <String>[
    'creator economy',
    'flutter jobs',
    'workspace reels',
    'design systems',
  ];

  final Map<String, List<String>> suggestionsByType =
      const <String, List<String>>{
        'people': <String>['mayaquinn', 'rafiahmed', 'nexa.studio'],
        'media': <String>['workspace setup', 'creator meetup'],
        'groups': <String>['Flutter Scale Circle', 'Creator Club'],
        'products': <String>['handmade lamp', 'creator kit'],
        'jobs': <String>['flutter engineer', 'product designer'],
      };

  void search(String query) {
    _debouncer.run(() {
      final term = query.trim().toLowerCase();
      if (term.isEmpty) {
        userResults = <UserModel>[];
        mediaResults = <PostModel>[];
      } else {
        userResults = MockData.users
            .where(
              (user) =>
                  user.name.toLowerCase().contains(term) ||
                  user.username.toLowerCase().contains(term),
            )
            .toList();
        mediaResults = MockData.posts
            .where(
              (post) =>
                  post.caption.toLowerCase().contains(term) ||
                  post.tags.any((tag) => tag.toLowerCase().contains(term)),
            )
            .toList();
        if (activeFilter == SearchEntityFilter.newest) {
          mediaResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
        if (activeFilter == SearchEntityFilter.top) {
          mediaResults.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        }
      }
      notifyListeners();
    });
  }

  void setFilter(SearchEntityFilter filter, {String currentQuery = ''}) {
    activeFilter = filter;
    search(currentQuery);
    notifyListeners();
  }

  List<String> suggestionsForActiveFilter() {
    switch (activeFilter) {
      case SearchEntityFilter.people:
        return suggestionsByType['people'] ?? const <String>[];
      case SearchEntityFilter.media:
        return suggestionsByType['media'] ?? const <String>[];
      case SearchEntityFilter.groups:
        return suggestionsByType['groups'] ?? const <String>[];
      case SearchEntityFilter.products:
        return suggestionsByType['products'] ?? const <String>[];
      case SearchEntityFilter.jobs:
        return suggestionsByType['jobs'] ?? const <String>[];
      case SearchEntityFilter.newest:
      case SearchEntityFilter.top:
        return trendingTerms;
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}
