import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../model/live_stream_model.dart';
import '../repository/live_stream_repository.dart';

class LiveStreamController extends ChangeNotifier {
  LiveStreamController({LiveStreamRepository? repository})
      : _repository = repository ?? LiveStreamRepository();

  final LiveStreamRepository _repository;
  final Random _random = Random();

  LiveStreamModel? live;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController pinnedCommentController = TextEditingController();
  final TextEditingController moderationReplyController = TextEditingController();

  Timer? _durationTimer;
  Timer? _commentTimer;
  Duration liveDuration = Duration.zero;
  bool isLive = false;
  bool micEnabled = true;
  bool commentsVisible = true;
  bool frontCamera = true;
  bool flashEnabled = false;
  bool beautyEnabled = true;
  bool settingsHighlighted = false;
  List<LiveCommentModel> visibleComments = <LiveCommentModel>[];

  void load({
    String? initialTitle,
    String? initialPhotoPath,
    LiveAudienceVisibility? initialAudience,
  }) {
    live = _repository.load(
      initialTitle: initialTitle,
      initialPhotoPath: initialPhotoPath,
      initialAudience: initialAudience,
    );
    final model = live!;
    titleController.text = model.liveTitle;
    descriptionController.text = model.description;
    pinnedCommentController.text = model.pinnedComment;
    visibleComments = model.comments.take(3).toList();
    notifyListeners();
  }

  String get creatorName => live?.creatorName ?? '';
  String get username => live?.username ?? '';
  String get avatarUrl => live?.avatarUrl ?? '';
  String? get previewPhotoPath => live?.previewPhotoPath;
  int get viewerCount => live?.viewerCount ?? 0;
  String get category => live?.category ?? 'Creative';
  String get location => live?.location ?? 'Unknown';
  String get previewHint => live?.previewLabel ?? '';
  LiveAudienceVisibility get audience =>
      live?.audience ?? LiveAudienceVisibility.public;
  List<LiveQuickOptionModel> get quickOptions =>
      live?.quickOptions ?? const <LiveQuickOptionModel>[];
  bool get allowComments => live?.allowComments ?? true;
  bool get allowReactions => live?.allowReactions ?? true;
  bool get saveReplay => live?.saveReplay ?? true;
  bool get notifyFollowers => live?.notifyFollowers ?? true;
  bool get noiseReduction => live?.noiseReduction ?? true;
  double get beautyMode => live?.beautyMode ?? 0.45;
  double get brightness => live?.brightness ?? 0.5;
  double get contrast => live?.contrast ?? 0.52;
  bool get mirrorPreview => live?.mirrorPreview ?? false;
  bool get enableLiveChat => live?.enableLiveChat ?? true;
  bool get slowMode => live?.slowMode ?? false;
  bool get allowViewerQuestions => live?.allowViewerQuestions ?? true;
  bool get showViewerCount => live?.showViewerCount ?? true;
  bool get showReactionOverlay => live?.showReactionOverlay ?? true;
  bool get moderatorMode => live?.moderatorMode ?? false;
  bool get enableStars => live?.enableStars ?? true;
  bool get raiseMoney => live?.raiseMoney ?? false;
  bool get productLinks => live?.productLinks ?? false;
  bool get donationBanner => live?.donationBanner ?? false;
  bool get subscriberOnlyChat => live?.subscriberOnlyChat ?? false;
  bool get hideOffensiveComments => live?.hideOffensiveComments ?? true;
  bool get ageRestriction => live?.ageRestriction ?? false;
  String get regionRestriction => live?.regionRestriction ?? 'None';
  int get themeColor => live?.themeColor ?? 0xFF26C6DA;
  String get badgeStyle => live?.badgeStyle ?? 'Pulse';
  String get commentBubbleStyle => live?.commentBubbleStyle ?? 'Glass';
  String get reactionStyle => live?.reactionStyle ?? 'Classic';
  double get fontScale => live?.fontScale ?? 1.0;
  double get overlayOpacity => live?.overlayOpacity ?? 0.82;
  String get cameraSource => live?.cameraSource ?? 'Front camera';
  String get micSource => live?.micSource ?? 'Built-in microphone';

  Color get accentColor => Color(themeColor);

  String get formattedDuration {
    final minutes = liveDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = liveDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void toggleQuickOption(String id) {
    final model = live;
    if (model == null) {
      return;
    }
    live = LiveStreamModel(
      creatorName: model.creatorName,
      username: model.username,
      avatarUrl: model.avatarUrl,
      previewLabel: model.previewLabel,
      liveTitle: model.liveTitle,
      description: model.description,
      audience: model.audience,
      viewerCount: model.viewerCount,
      category: model.category,
      location: model.location,
      previewPhotoPath: model.previewPhotoPath,
      quickOptions: model.quickOptions
          .map((item) => item.copyWith(selected: item.id == id))
          .toList(growable: false),
      comments: model.comments,
      allowComments: model.allowComments,
      allowReactions: model.allowReactions,
      saveReplay: model.saveReplay,
      notifyFollowers: model.notifyFollowers,
      noiseReduction: model.noiseReduction,
      beautyMode: model.beautyMode,
      brightness: model.brightness,
      contrast: model.contrast,
      mirrorPreview: model.mirrorPreview,
      enableLiveChat: model.enableLiveChat,
      slowMode: model.slowMode,
      pinnedComment: model.pinnedComment,
      allowViewerQuestions: model.allowViewerQuestions,
      showViewerCount: model.showViewerCount,
      showReactionOverlay: model.showReactionOverlay,
      moderatorMode: model.moderatorMode,
      enableStars: model.enableStars,
      raiseMoney: model.raiseMoney,
      productLinks: model.productLinks,
      donationBanner: model.donationBanner,
      subscriberOnlyChat: model.subscriberOnlyChat,
      hideOffensiveComments: model.hideOffensiveComments,
      ageRestriction: model.ageRestriction,
      regionRestriction: model.regionRestriction,
      themeColor: model.themeColor,
      badgeStyle: model.badgeStyle,
      commentBubbleStyle: model.commentBubbleStyle,
      reactionStyle: model.reactionStyle,
      fontScale: model.fontScale,
      overlayOpacity: model.overlayOpacity,
      cameraSource: model.cameraSource,
      micSource: model.micSource,
      liveStatusText: model.liveStatusText,
    );
    notifyListeners();
  }

  void setAudience(LiveAudienceVisibility value) => _rebuild(audience: value);
  void setAllowComments(bool value) => _rebuild(allowComments: value);
  void setAllowReactions(bool value) => _rebuild(allowReactions: value);
  void setSaveReplay(bool value) => _rebuild(saveReplay: value);
  void setNotifyFollowers(bool value) => _rebuild(notifyFollowers: value);
  void setNoiseReduction(bool value) => _rebuild(noiseReduction: value);
  void setBeautyMode(double value) => _rebuild(beautyMode: value);
  void setBrightness(double value) => _rebuild(brightness: value);
  void setContrast(double value) => _rebuild(contrast: value);
  void setMirrorPreview(bool value) => _rebuild(mirrorPreview: value);
  void setEnableLiveChat(bool value) => _rebuild(enableLiveChat: value);
  void setSlowMode(bool value) => _rebuild(slowMode: value);
  void setAllowViewerQuestions(bool value) => _rebuild(allowViewerQuestions: value);
  void setShowViewerCount(bool value) => _rebuild(showViewerCount: value);
  void setShowReactionOverlay(bool value) => _rebuild(showReactionOverlay: value);
  void setModeratorMode(bool value) => _rebuild(moderatorMode: value);
  void setEnableStars(bool value) => _rebuild(enableStars: value);
  void setRaiseMoney(bool value) => _rebuild(raiseMoney: value);
  void setProductLinks(bool value) => _rebuild(productLinks: value);
  void setDonationBanner(bool value) => _rebuild(donationBanner: value);
  void setSubscriberOnlyChat(bool value) => _rebuild(subscriberOnlyChat: value);
  void setHideOffensiveComments(bool value) => _rebuild(hideOffensiveComments: value);
  void setAgeRestriction(bool value) => _rebuild(ageRestriction: value);
  void setThemeColor(int value) => _rebuild(themeColor: value);
  void setFontScale(double value) => _rebuild(fontScale: value);
  void setOverlayOpacity(double value) => _rebuild(overlayOpacity: value);
  void setCategory(String value) => _rebuild(category: value);
  void setLocation(String value) => _rebuild(location: value);
  void setCameraSource(String value) => _rebuild(cameraSource: value);
  void setMicSource(String value) => _rebuild(micSource: value);
  void setRegionRestriction(String value) => _rebuild(regionRestriction: value);
  void setBadgeStyle(String value) => _rebuild(badgeStyle: value);
  void setCommentBubbleStyle(String value) => _rebuild(commentBubbleStyle: value);
  void setReactionStyle(String value) => _rebuild(reactionStyle: value);

  void updatePinnedComment(String value) {
    pinnedCommentController.text = value;
    _rebuild(pinnedComment: value);
  }

  void applyTitle(String value) {
    titleController.text = value;
    _rebuild(liveTitle: value);
  }

  void applyDescription(String value) {
    descriptionController.text = value;
    _rebuild(description: value);
  }

  void toggleMic() {
    micEnabled = !micEnabled;
    notifyListeners();
  }

  void toggleComments() {
    commentsVisible = !commentsVisible;
    notifyListeners();
  }

  void toggleCamera() {
    frontCamera = !frontCamera;
    notifyListeners();
  }

  void toggleFlash() {
    flashEnabled = !flashEnabled;
    notifyListeners();
  }

  void toggleBeauty() {
    beautyEnabled = !beautyEnabled;
    notifyListeners();
  }

  void pulseSettings() {
    settingsHighlighted = true;
    notifyListeners();
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      settingsHighlighted = false;
      notifyListeners();
    });
  }

  void startLive() {
    if (isLive) {
      return;
    }
    isLive = true;
    liveDuration = const Duration(seconds: 3);
    _durationTimer?.cancel();
    _commentTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      liveDuration += const Duration(seconds: 1);
      notifyListeners();
    });
    _commentTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final model = live;
      if (model == null || model.comments.isEmpty) {
        return;
      }
      final next = model.comments[_random.nextInt(model.comments.length)];
      visibleComments = <LiveCommentModel>[
        next,
        ...visibleComments,
      ].take(5).toList(growable: false);
      notifyListeners();
    });
    notifyListeners();
  }

  void endLive() {
    isLive = false;
    _durationTimer?.cancel();
    _commentTimer?.cancel();
    notifyListeners();
  }

  void sendModeratorReply() {
    final text = moderationReplyController.text.trim();
    if (text.isEmpty) {
      return;
    }
    visibleComments = <LiveCommentModel>[
      LiveCommentModel(
        id: 'host_${DateTime.now().microsecondsSinceEpoch}',
        username: 'host',
        avatarUrl: avatarUrl,
        message: text,
        verified: true,
      ),
      ...visibleComments,
    ].take(5).toList(growable: false);
    moderationReplyController.clear();
    notifyListeners();
  }

  List<LiveReactionModel> buildReactionBatch() {
    return List<LiveReactionModel>.generate(3 + _random.nextInt(3), (index) {
      final types = LiveReactionType.values;
      return LiveReactionModel(
        id: 'r_${DateTime.now().microsecondsSinceEpoch}_$index',
        type: types[_random.nextInt(types.length)],
      );
    });
  }

  void resetSetup() {
    final previewPhotoPath = live?.previewPhotoPath;
    load(
      initialTitle: 'Studio Check-in',
      initialPhotoPath: previewPhotoPath,
      initialAudience: LiveAudienceVisibility.public,
    );
  }

  void _rebuild({
    LiveAudienceVisibility? audience,
    bool? allowComments,
    bool? allowReactions,
    bool? saveReplay,
    bool? notifyFollowers,
    bool? noiseReduction,
    double? beautyMode,
    double? brightness,
    double? contrast,
    bool? mirrorPreview,
    bool? enableLiveChat,
    bool? slowMode,
    String? pinnedComment,
    bool? allowViewerQuestions,
    bool? showViewerCount,
    bool? showReactionOverlay,
    bool? moderatorMode,
    bool? enableStars,
    bool? raiseMoney,
    bool? productLinks,
    bool? donationBanner,
    bool? subscriberOnlyChat,
    bool? hideOffensiveComments,
    bool? ageRestriction,
    String? regionRestriction,
    int? themeColor,
    String? badgeStyle,
    String? commentBubbleStyle,
    String? reactionStyle,
    double? fontScale,
    double? overlayOpacity,
    String? cameraSource,
    String? micSource,
    String? liveTitle,
    String? description,
    String? category,
    String? location,
  }) {
    final model = live;
    if (model == null) {
      return;
    }
    live = LiveStreamModel(
      creatorName: model.creatorName,
      username: model.username,
      avatarUrl: model.avatarUrl,
      previewLabel: model.previewLabel,
      liveTitle: liveTitle ?? model.liveTitle,
      description: description ?? model.description,
      audience: audience ?? model.audience,
      viewerCount: model.viewerCount,
      category: category ?? model.category,
      location: location ?? model.location,
      previewPhotoPath: model.previewPhotoPath,
      quickOptions: model.quickOptions,
      comments: model.comments,
      allowComments: allowComments ?? model.allowComments,
      allowReactions: allowReactions ?? model.allowReactions,
      saveReplay: saveReplay ?? model.saveReplay,
      notifyFollowers: notifyFollowers ?? model.notifyFollowers,
      noiseReduction: noiseReduction ?? model.noiseReduction,
      beautyMode: beautyMode ?? model.beautyMode,
      brightness: brightness ?? model.brightness,
      contrast: contrast ?? model.contrast,
      mirrorPreview: mirrorPreview ?? model.mirrorPreview,
      enableLiveChat: enableLiveChat ?? model.enableLiveChat,
      slowMode: slowMode ?? model.slowMode,
      pinnedComment: pinnedComment ?? model.pinnedComment,
      allowViewerQuestions: allowViewerQuestions ?? model.allowViewerQuestions,
      showViewerCount: showViewerCount ?? model.showViewerCount,
      showReactionOverlay: showReactionOverlay ?? model.showReactionOverlay,
      moderatorMode: moderatorMode ?? model.moderatorMode,
      enableStars: enableStars ?? model.enableStars,
      raiseMoney: raiseMoney ?? model.raiseMoney,
      productLinks: productLinks ?? model.productLinks,
      donationBanner: donationBanner ?? model.donationBanner,
      subscriberOnlyChat: subscriberOnlyChat ?? model.subscriberOnlyChat,
      hideOffensiveComments:
          hideOffensiveComments ?? model.hideOffensiveComments,
      ageRestriction: ageRestriction ?? model.ageRestriction,
      regionRestriction: regionRestriction ?? model.regionRestriction,
      themeColor: themeColor ?? model.themeColor,
      badgeStyle: badgeStyle ?? model.badgeStyle,
      commentBubbleStyle: commentBubbleStyle ?? model.commentBubbleStyle,
      reactionStyle: reactionStyle ?? model.reactionStyle,
      fontScale: fontScale ?? model.fontScale,
      overlayOpacity: overlayOpacity ?? model.overlayOpacity,
      cameraSource: cameraSource ?? model.cameraSource,
      micSource: micSource ?? model.micSource,
      liveStatusText: model.liveStatusText,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _commentTimer?.cancel();
    titleController.dispose();
    descriptionController.dispose();
    pinnedCommentController.dispose();
    moderationReplyController.dispose();
    super.dispose();
  }
}
