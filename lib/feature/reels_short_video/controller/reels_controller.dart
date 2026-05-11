import 'package:flutter/foundation.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/models/reel_model.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/reel_filter_model.dart';
import '../service/reels_short_video_service.dart';

class ReelsController extends ChangeNotifier {
  ReelsController({ReelsShortVideoService? service})
    : _service = service ?? ReelsShortVideoService();

  final ReelsShortVideoService _service;
  List<ReelModel> reels = <ReelModel>[];
  ReelFilterModel filter = const ReelFilterModel(filter: ReelFeedFilter.forYou);
  Future<void>? _loadFuture;
  bool _hasLoaded = false;
  bool _isLoading = false;
  bool _hasError = false;
  final Set<String> _likedReelIds = <String>{};
  final Set<String> _savedDraftIds = <String>{};
  final Map<String, int> _extraCommentCount = <String, int>{};
  final Map<String, int> _extraShareCount = <String, int>{};

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  bool get hasError => _hasError;

  Future<void> load({bool force = false}) {
    if (!force) {
      final Future<void>? inFlight = _loadFuture;
      if (inFlight != null) {
        return inFlight;
      }
      if (_hasLoaded) {
        return Future<void>.value();
      }
    }

    final Future<void> future = _performLoad();
    _loadFuture = future;
    return future.whenComplete(() {
      if (identical(_loadFuture, future)) {
        _loadFuture = null;
      }
    });
  }

  Future<void> _performLoad() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .getEndpoint('reels');
      if (response.isSuccess && response.data['success'] != false) {
        final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['reels', 'items'],
        );
        reels = items
            .map(ReelModel.fromApiJson)
            .where((ReelModel item) => item.id.isNotEmpty)
            .toList(growable: false);
        _hasLoaded = true;
        _isLoading = false;
        _hasError = false;
        notifyListeners();
        return;
      }
    } catch (_) {}
    reels = const <ReelModel>[];
    _hasLoaded = true;
    _isLoading = false;
    _hasError = true;
    notifyListeners();
  }

  bool isLiked(String reelId) => _likedReelIds.contains(reelId);

  int likeCount(ReelModel reel) =>
      reel.likes + (_likedReelIds.contains(reel.id) ? 1 : 0);

  int commentCount(ReelModel reel) =>
      reel.comments + (_extraCommentCount[reel.id] ?? 0);

  int shareCount(ReelModel reel) =>
      reel.shares + (_extraShareCount[reel.id] ?? 0);
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
