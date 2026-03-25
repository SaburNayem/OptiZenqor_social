import 'package:flutter/foundation.dart';

import '../../../core/data/mock/mock_data.dart';
import '../../../core/data/models/reel_model.dart';
import '../model/reel_filter_model.dart';

class ReelsController extends ChangeNotifier {
  List<ReelModel> reels = <ReelModel>[];
  ReelFilterModel filter = const ReelFilterModel(filter: ReelFeedFilter.forYou);
  final Set<String> _likedReelIds = <String>{};
  final Set<String> _savedDraftIds = <String>{};
  final Map<String, int> _extraCommentCount = <String, int>{};
  final Map<String, int> _extraShareCount = <String, int>{};

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    reels = MockData.reels;
    notifyListeners();
  }

  bool isLiked(String reelId) => _likedReelIds.contains(reelId);

  int likeCount(ReelModel reel) =>
      reel.likes + (_likedReelIds.contains(reel.id) ? 1 : 0);

  int commentCount(ReelModel reel) =>
      reel.comments + (_extraCommentCount[reel.id] ?? 0);

  int shareCount(ReelModel reel) => reel.shares + (_extraShareCount[reel.id] ?? 0);
  bool isSavedDraft(String reelId) => _savedDraftIds.contains(reelId);

  void toggleLike(String reelId) {
    if (_likedReelIds.contains(reelId)) {
      _likedReelIds.remove(reelId);
    } else {
      _likedReelIds.add(reelId);
    }
    notifyListeners();
  }

  void addComment(String reelId) {
    _extraCommentCount[reelId] = (_extraCommentCount[reelId] ?? 0) + 1;
    notifyListeners();
  }

  void addShare(String reelId) {
    _extraShareCount[reelId] = (_extraShareCount[reelId] ?? 0) + 1;
    notifyListeners();
  }

  void toggleSavedDraft(String reelId) {
    if (_savedDraftIds.contains(reelId)) {
      _savedDraftIds.remove(reelId);
    } else {
      _savedDraftIds.add(reelId);
    }
    notifyListeners();
  }

  void setFilter(ReelFeedFilter next) {
    filter = ReelFilterModel(filter: next);
    notifyListeners();
  }
}
