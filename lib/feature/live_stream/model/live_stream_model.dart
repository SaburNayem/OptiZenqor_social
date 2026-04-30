import 'package:flutter/widgets.dart';

enum LiveAudienceVisibility { public, friends, onlyMe }

enum LiveReactionType { like, love, wow }

class LiveCommentModel {
  const LiveCommentModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.message,
    this.verified = false,
  });

  final String id;
  final String username;
  final String avatarUrl;
  final String message;
  final bool verified;
}

class LiveQuickOptionModel {
  const LiveQuickOptionModel({
    required this.id,
    required this.label,
    required this.icon,
    this.selected = false,
  });

  final String id;
  final String label;
  final IconData icon;
  final bool selected;

  LiveQuickOptionModel copyWith({bool? selected}) {
    return LiveQuickOptionModel(
      id: id,
      label: label,
      icon: icon,
      selected: selected ?? this.selected,
    );
  }
}

class LiveReactionModel {
  const LiveReactionModel({required this.id, required this.type});

  final String id;
  final LiveReactionType type;
}

class LiveStreamModel {
  const LiveStreamModel({
    this.streamId = '',
    required this.creatorName,
    required this.username,
    required this.avatarUrl,
    required this.previewLabel,
    required this.liveTitle,
    required this.description,
    required this.audience,
    required this.viewerCount,
    required this.category,
    required this.location,
    required this.quickOptions,
    required this.comments,
    this.previewPhotoPath,
    this.allowComments = true,
    this.allowReactions = true,
    this.saveReplay = true,
    this.notifyFollowers = true,
    this.noiseReduction = true,
    this.beautyMode = 0.45,
    this.brightness = 0.5,
    this.contrast = 0.52,
    this.mirrorPreview = false,
    this.enableLiveChat = true,
    this.slowMode = false,
    this.pinnedComment = 'Be kind and keep the chat welcoming.',
    this.allowViewerQuestions = true,
    this.showViewerCount = true,
    this.showReactionOverlay = true,
    this.moderatorMode = false,
    this.enableStars = true,
    this.raiseMoney = false,
    this.productLinks = false,
    this.donationBanner = false,
    this.subscriberOnlyChat = false,
    this.hideOffensiveComments = true,
    this.ageRestriction = false,
    this.regionRestriction = 'None',
    this.themeColor = 0xFF26C6DA,
    this.badgeStyle = 'Pulse',
    this.commentBubbleStyle = 'Glass',
    this.reactionStyle = 'Classic',
    this.fontScale = 1.0,
    this.overlayOpacity = 0.82,
    this.cameraSource = 'Front camera',
    this.micSource = 'Built-in microphone',
    this.liveStatusText = 'Ready to go live',
  });

  final String streamId;
  final String creatorName;
  final String username;
  final String avatarUrl;
  final String previewLabel;
  final String liveTitle;
  final String description;
  final LiveAudienceVisibility audience;
  final int viewerCount;
  final String category;
  final String location;
  final String? previewPhotoPath;
  final List<LiveQuickOptionModel> quickOptions;
  final List<LiveCommentModel> comments;
  final bool allowComments;
  final bool allowReactions;
  final bool saveReplay;
  final bool notifyFollowers;
  final bool noiseReduction;
  final double beautyMode;
  final double brightness;
  final double contrast;
  final bool mirrorPreview;
  final bool enableLiveChat;
  final bool slowMode;
  final String pinnedComment;
  final bool allowViewerQuestions;
  final bool showViewerCount;
  final bool showReactionOverlay;
  final bool moderatorMode;
  final bool enableStars;
  final bool raiseMoney;
  final bool productLinks;
  final bool donationBanner;
  final bool subscriberOnlyChat;
  final bool hideOffensiveComments;
  final bool ageRestriction;
  final String regionRestriction;
  final int themeColor;
  final String badgeStyle;
  final String commentBubbleStyle;
  final String reactionStyle;
  final double fontScale;
  final double overlayOpacity;
  final String cameraSource;
  final String micSource;
  final String liveStatusText;
}
