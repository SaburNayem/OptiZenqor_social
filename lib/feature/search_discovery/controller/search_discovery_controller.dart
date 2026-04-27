import 'package:flutter/foundation.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/utils/debouncer.dart';
import '../service/search_discovery_service.dart';

enum SearchEntityFilter {
  all,
  posts,
  people,
  pages,
  communities,
  marketplace,
  events,
  jobs,
}

class SearchBucketItem {
  const SearchBucketItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.imageUrl = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final String type;
  final String imageUrl;
}

class SearchDiscoveryController extends ChangeNotifier {
  SearchDiscoveryController({SearchDiscoveryService? service})
    : _debouncer = Debouncer(milliseconds: 350),
      _service = service ?? SearchDiscoveryService();

  final Debouncer _debouncer;
  final SearchDiscoveryService _service;

  SearchEntityFilter activeFilter = SearchEntityFilter.all;
  String currentQuery = '';
  bool isLoading = false;
  String? errorMessage;
  List<SearchBucketItem> allResults = <SearchBucketItem>[];
  List<PostModel> postResults = <PostModel>[];
  List<UserModel> peopleResults = <UserModel>[];
  List<SearchBucketItem> pageResults = <SearchBucketItem>[];
  List<SearchBucketItem> communityResults = <SearchBucketItem>[];
  List<SearchBucketItem> marketplaceResults = <SearchBucketItem>[];
  List<SearchBucketItem> eventResults = <SearchBucketItem>[];
  List<SearchBucketItem> jobResults = <SearchBucketItem>[];

  final List<String> trendingTerms = <String>[
    'creator economy',
    'flutter jobs',
    'workspace reels',
    'design systems',
  ];

  void search(String query) {
    currentQuery = query;
    _debouncer.run(() => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    final String term = query.trim();
    if (term.isEmpty) {
      _clearResults();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getEndpoint(
        'global_search',
        queryParameters: <String, dynamic>{'q': term, 'limit': 20},
      );
      if (!response.isSuccess || response.data['success'] == false) {
        throw Exception(response.message ?? 'Unable to search right now.');
      }

      final Map<String, dynamic> data =
          ApiPayloadReader.readMap(response.data['data']) ?? response.data;
      allResults = _readGenericBucket(data, 'all');
      postResults = _readPostBucket(data, const <String>['posts', 'feed']);
      peopleResults = _readUserBucket(data, const <String>['people', 'users']);
      pageResults = _readGenericBucket(data, 'pages');
      communityResults = _readGenericBucket(data, 'communities');
      marketplaceResults = _readGenericBucket(data, 'marketplace').isNotEmpty
          ? _readGenericBucket(data, 'marketplace')
          : _readGenericBucket(data, 'products');
      eventResults = _readGenericBucket(data, 'events');
      jobResults = _readGenericBucket(data, 'jobs');
      errorMessage = null;
    } catch (error) {
      _clearResultLists();
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(SearchEntityFilter filter) {
    activeFilter = filter;
    notifyListeners();
  }

  List<Object> get visibleResults {
    switch (activeFilter) {
      case SearchEntityFilter.all:
        return allResults.isNotEmpty
            ? allResults
            : <Object>[...peopleResults, ...postResults];
      case SearchEntityFilter.posts:
        return postResults;
      case SearchEntityFilter.people:
        return peopleResults;
      case SearchEntityFilter.pages:
        return pageResults;
      case SearchEntityFilter.communities:
        return communityResults;
      case SearchEntityFilter.marketplace:
        return marketplaceResults;
      case SearchEntityFilter.events:
        return eventResults;
      case SearchEntityFilter.jobs:
        return jobResults;
    }
  }

  String labelFor(SearchEntityFilter filter) {
    switch (filter) {
      case SearchEntityFilter.all:
        return 'All';
      case SearchEntityFilter.posts:
        return 'Posts';
      case SearchEntityFilter.people:
        return 'People';
      case SearchEntityFilter.pages:
        return 'Pages';
      case SearchEntityFilter.communities:
        return 'Communities';
      case SearchEntityFilter.marketplace:
        return 'Marketplace';
      case SearchEntityFilter.events:
        return 'Events';
      case SearchEntityFilter.jobs:
        return 'Jobs';
    }
  }

  void _clearResults() {
    _clearResultLists();
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }

  void _clearResultLists() {
    allResults = <SearchBucketItem>[];
    postResults = <PostModel>[];
    peopleResults = <UserModel>[];
    pageResults = <SearchBucketItem>[];
    communityResults = <SearchBucketItem>[];
    marketplaceResults = <SearchBucketItem>[];
    eventResults = <SearchBucketItem>[];
    jobResults = <SearchBucketItem>[];
  }

  List<PostModel> _readPostBucket(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    return keys
        .expand((String key) => ApiPayloadReader.readMapListFromAny(data[key]))
        .map(PostModel.fromApiJson)
        .where((PostModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  List<UserModel> _readUserBucket(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    return keys
        .expand((String key) => ApiPayloadReader.readMapListFromAny(data[key]))
        .map(UserModel.fromApiJson)
        .where((UserModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  List<SearchBucketItem> _readGenericBucket(
    Map<String, dynamic> data,
    String key,
  ) {
    return ApiPayloadReader.readMapListFromAny(data[key])
        .map((Map<String, dynamic> item) => _toBucketItem(item, key))
        .where((SearchBucketItem item) => item.title.isNotEmpty)
        .toList(growable: false);
  }

  SearchBucketItem _toBucketItem(Map<String, dynamic> item, String type) {
    final String id = ApiPayloadReader.readString(
      item['id'] ?? item['_id'] ?? item['slug'],
    );
    final String title = ApiPayloadReader.readString(
      item['title'] ??
          item['name'] ??
          item['caption'] ??
          item['username'] ??
          item['tag'] ??
          item['label'],
    );
    final String subtitle = ApiPayloadReader.readString(
      item['subtitle'] ??
          item['description'] ??
          item['bio'] ??
          item['category'] ??
          item['company'] ??
          item['location'],
      fallback: type,
    );
    final String imageUrl = ApiPayloadReader.readString(
      item['image'] ??
          item['imageUrl'] ??
          item['thumbnail'] ??
          item['thumbnailUrl'] ??
          item['avatar'] ??
          item['coverImageUrl'],
    );
    return SearchBucketItem(
      id: id,
      title: title,
      subtitle: subtitle,
      type: type,
      imageUrl: imageUrl,
    );
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}
