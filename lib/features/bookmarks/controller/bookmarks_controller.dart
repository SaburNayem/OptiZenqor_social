import 'package:flutter/foundation.dart';

import '../model/bookmark_item_model.dart';
import '../repository/bookmarks_repository.dart';

class BookmarksController extends ChangeNotifier {
  BookmarksController({BookmarksRepository? repository})
      : _repository = repository ?? BookmarksRepository();

  final BookmarksRepository _repository;
  List<BookmarkItemModel> items = <BookmarkItemModel>[];

  Future<void> load() async {
    items = await _repository.read();
    notifyListeners();
  }

  Future<void> save(BookmarkItemModel item) async {
    items.removeWhere((i) => i.id == item.id);
    items.insert(0, item);
    await _repository.write(items);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    items.removeWhere((i) => i.id == id);
    await _repository.write(items);
    notifyListeners();
  }
}
