import 'package:flutter/foundation.dart';

import '../../../core/data/mock/mock_data.dart';
import '../model/page_model.dart';
import '../repository/pages_repository.dart';

enum PagesViewFilter { discover, following, managed }

class PagesController extends ChangeNotifier {
  PagesController({PagesRepository? repository})
      : _repository = repository ?? PagesRepository();

  final PagesRepository _repository;
  String currentUserId = MockData.users.first.id;
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

  List<PageModel> get followingPages => pages
      .where((page) => page.following)
      .toList(growable: false);

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

  int get totalPosts => pages.fold<int>(0, (sum, page) => sum + page.posts.length);

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

  void createPage({
    required String name,
    required String about,
    required String category,
  }) {
    final trimmedName = name.trim();
    final trimmedAbout = about.trim();
    final trimmedCategory = category.trim();
    if (trimmedName.isEmpty) {
      return;
    }
    pages = <PageModel>[
      PageModel(
        id: 'page_${DateTime.now().millisecondsSinceEpoch}',
        name: trimmedName,
        about: trimmedAbout.isEmpty
            ? 'New page ready for updates, announcements, and audience growth.'
            : trimmedAbout,
        posts: const <String>[
          'Welcome post created. Add your first update to introduce this page.'
        ],
        category: trimmedCategory.isEmpty ? 'General' : trimmedCategory,
        following: true,
        actionButtonLabel: 'Manage',
        reviewSummary: 'Page reviews will appear once your audience starts engaging.',
        visitorPostsSummary: 'Visitor posts are currently moderated by page admins.',
        followersInsight: 'New page created. Publish regularly to build reach.',
        avatarUrl: MockData.users.first.avatar,
        coverUrl:
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200',
        followersCount: 0,
        likesCount: 0,
        verified: false,
        ownerId: currentUserId,
        location: 'Creator Studio',
        contactLabel: 'Manage',
        highlights: const <String>['Welcome', 'Updates', 'Community'],
      ),
      ...pages,
    ];
    selectedFilter = PagesViewFilter.managed;
    query = '';
    notifyListeners();
  }

  void toggleFollow(String id) {
    pages = pages
        .map(
          (page) {
            if (page.id != id) {
              return page;
            }
            final nextFollowing = !page.following;
            final nextFollowersCount = nextFollowing
                ? page.followersCount + 1
                : (page.followersCount > 0 ? page.followersCount - 1 : 0);
            return page.copyWith(
              following: nextFollowing,
              followersCount: nextFollowersCount,
            );
          },
        )
        .toList();
    notifyListeners();
  }
}
