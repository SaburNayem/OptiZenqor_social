import 'package:flutter/foundation.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/utils/debouncer.dart';
import '../service/search_discovery_service.dart';

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
  SearchDiscoveryController({SearchDiscoveryService? service})
    : _debouncer = Debouncer(milliseconds: 350),
      _service = service ?? SearchDiscoveryService();

  final Debouncer _debouncer;
  final SearchDiscoveryService _service;

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
      _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    final String term = query.trim().toLowerCase();
    if (term.isEmpty) {
      userResults = <UserModel>[];
      mediaResults = <PostModel>[];
      notifyListeners();
      return;
    }

    try {
      final response = await _service.getEndpoint(
        'search',
        queryParameters: <String, dynamic>{'q': term},
      );
      if (response.isSuccess && response.data['success'] != false) {
        userResults = ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['users', 'people'],
        ).map(UserModel.fromApiJson).where((UserModel item) => item.id.isNotEmpty).toList(growable: false);
        mediaResults = ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['posts', 'media', 'items', 'results'],
        ).map(PostModel.fromApiJson).where((PostModel item) => item.id.isNotEmpty).toList(growable: false);
      } else {
        userResults = <UserModel>[];
        mediaResults = <PostModel>[];
      }
    } catch (_) {
      userResults = <UserModel>[];
      mediaResults = <PostModel>[];
    }

    if (activeFilter == SearchEntityFilter.newest) {
      mediaResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    if (activeFilter == SearchEntityFilter.top) {
      mediaResults.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    }
    notifyListeners();
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
