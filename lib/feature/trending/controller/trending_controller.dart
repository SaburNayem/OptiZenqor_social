import 'package:flutter/foundation.dart';

import '../model/trending_item_model.dart';
import '../repository/trending_repository.dart';

class TrendingController extends ChangeNotifier {
  TrendingController({TrendingRepository? repository})
      : _repository = repository ?? TrendingRepository();

  final TrendingRepository _repository;
  List<TrendingItemModel> posts = <TrendingItemModel>[];
  List<TrendingItemModel> hashtags = <TrendingItemModel>[];
  List<TrendingItemModel> reels = <TrendingItemModel>[];

  void load() {
    final all = _repository.load();
    posts = all.where((item) => item.type == 'post').toList();
    hashtags = all.where((item) => item.type == 'hashtag').toList();
    reels = all.where((item) => item.type == 'reel').toList();
    notifyListeners();
  }
}
