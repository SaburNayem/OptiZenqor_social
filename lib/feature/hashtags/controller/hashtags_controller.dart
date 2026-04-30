import 'package:flutter/foundation.dart';

import '../model/hashtag_model.dart';
import '../repository/hashtags_repository.dart';

class HashtagsController extends ChangeNotifier {
  HashtagsController({HashtagsRepository? repository})
    : _repository = repository ?? HashtagsRepository();

  final HashtagsRepository _repository;
  List<HashtagModel> _all = <HashtagModel>[];
  List<HashtagModel> visible = <HashtagModel>[];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      _all = await _repository.trending();
      visible = List<HashtagModel>.from(_all);
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      _all = <HashtagModel>[];
      visible = <HashtagModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
