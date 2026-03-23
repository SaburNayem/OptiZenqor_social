import '../model/trending_item_model.dart';

class TrendingRepository {
  List<TrendingItemModel> load() {
    return const <TrendingItemModel>[
      TrendingItemModel(title: 'Creator speedrun reel', type: 'reel', score: 92),
      TrendingItemModel(title: '#flutter', type: 'hashtag', score: 90),
      TrendingItemModel(title: 'Design sprint recap', type: 'post', score: 88),
    ];
  }
}
