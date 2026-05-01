import 'package:flutter/foundation.dart';

import '../model/page_model.dart';
import '../repository/pages_repository.dart';

enum PagesViewFilter { discover, following, managed }

class PagesController extends ChangeNotifier {
  PagesController({PagesRepository? repository})
    : _repository = repository ?? PagesRepository();

  final PagesRepository _repository;
  String currentUserId = '';
  List<PageModel> pages = <PageModel>[];
  String query = '';
  PagesViewFilter selectedFilter = PagesViewFilter.discover;

  Future<void> load() async {
    currentUserId = await _repository.currentUserId();
    pages = await _repository.load();
    notifyListeners();
  }

  List<PageModel> get managedPages => pages
      .where((page) => page.ownerId == currentUserId)
      .toList(growable: false);

  List<PageModel> get followingPages =>
      pages.where((page) => page.following).toList(growable: false);

  List<PageModel> get featuredPages => pages.take(4).toList(growable: false);

  List<PageModel> get visiblePages {
    Iterable<PageModel> results = pages;
    switch (selectedFilter) {
      case PagesViewFilter.discover:
        break;
      case PagesViewFilter.following:
        results = results.where((page) => page.following);
      case PagesViewFilter.managed:
        results = results.where((page) => page.ownerId == currentUserId);
    }

    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isNotEmpty) {
      results = results.where(
        (page) =>
            page.name.toLowerCase().contains(trimmedQuery) ||
            page.about.toLowerCase().contains(trimmedQuery) ||
            page.category.toLowerCase().contains(trimmedQuery),
      );
    }
    return results.toList(growable: false);
  }

  int get totalPosts =>
      pages.fold<int>(0, (sum, page) => sum + page.posts.length);

  void updateQuery(String value) {
    query = value;
    notifyListeners();
  }

  void selectFilter(PagesViewFilter filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  PageModel pageById(String id) =>
      pages.firstWhere((page) => page.id == id, orElse: () => pages.first);

  bool isManagedPage(PageModel page) => page.ownerId == currentUserId;

  Future<void> createPage({
    required String name,
    required String about,
    required String category,
  }) async {
    if (name.trim().isEmpty) {
      return;
    }
    final PageModel? created = await _repository.createPage(
      name: name,
      about: about,
      category: category,
    );
    if (created == null) {
      return;
    }
    pages = <PageModel>[created, ...pages];
    selectedFilter = PagesViewFilter.managed;
    query = '';
    notifyListeners();
  }

  Future<void> toggleFollow(String id) async {
    final PageModel? updated = await _repository.toggleFollow(id);
    if (updated == null) {
      return;
    }
    pages = pages
        .map((page) => page.id == id ? updated : page)
        .toList(growable: false);
    notifyListeners();
  }
}
