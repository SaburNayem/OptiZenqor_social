class TrendingItemModel {
  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const TrendingItemModel({  const Trey}) : _repository = repository ?? TrendingRepository();
  final TrendingRepository _repository;

  List<TrendingItemModel> posts = <TrendingItemModel>[];
  List<TrendingItemModel> hashtags = <TrendingItemModel>[];
  List<TrendingItemModel> reels = <TrendingItemModel>[];

  void load() {
    final all = _repository.load();
    posts = all.where((i) => i.type == 'post').toList();
    hashtags = all.where((i) => i.type == 'hashtag').toList();
    reels = all.where((i) => i.type == 'reel').toList();
    notifyListeners();
  }
}
