import 'package:flutter/foundation.dart';

import '../model/page_model.dart';
import '../repository/pages_repository.dart';

class PagesController extends ChangeNotifier {
  PagesController({PagesRepository? repository})
      : _repository = repository ?? PagesRepository();

  final PagesRepository _repository;
  List<PageModel> pages = <PageModel>[];

  void load() {
    pages = _repository.load();
    notifyListeners();
  }

  void createPage(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    pages = <PageModel>[
      PageModel(
        id: 'page_${DateTime.now().millisecondsSinceEpoch}',
        name: trimmed,
        about: 'New community page',
        posts: const <String>[],
      ),
      ...pages,
    ];
    notifyListeners();
  }

  void toggleFollow(String id) {
    pages = pages
        .map(
          (page) => page.id == id
              ? page.copyWith(following: !page.following)
              : page,
        )
        .toList();
    notifyListeners();
  }
}
