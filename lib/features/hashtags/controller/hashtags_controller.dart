import 'package:flutter/foundation.dart';

import '../model/hashtag_model.dart';
import '../repository/hashtags_repository.dart';

class HashtagsController extends ChangeNotifier {
  HashtagsController({HashtagsRepository? repository})
      : _repository = repository ?? HashtagsRepository();

  final HashtagsRepository _repository;
  List<HashtagModel> _all = <HashtagModel>[];
  List<HashtagModel> visible = <HashtagModel>[];

  void load() {
    _all = _repository.trending();
    visible = List<HashtagModel>.from(_all);
    notifyListeners();
  }

  void search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      visible = List<HashtagModel>.from(_all);
    } else {
      visible = _all
          .where((tag) => tag.tag.toLowerCase().contains(normalized))
          .toList();
    }
    notifyListeners();
  }
}
