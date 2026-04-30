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
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final List<TrendingItemModel> all = await _repository.load();
      posts = all
          .where((TrendingItemModel item) => item.type == 'post')
          .toList();
      hashtags = all
          .where((TrendingItemModel item) => item.type == 'hashtag')
          .toList();
      reels = all
          .where((TrendingItemModel item) => item.type == 'reel')
          .toList();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      posts = <TrendingItemModel>[];
      hashtags = <TrendingItemModel>[];
      reels = <TrendingItemModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
