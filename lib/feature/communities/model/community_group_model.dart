enum CommunityPrivacy { public, private, hidden }

enum CommunityRole { admin, moderator, member }

enum CommunityPostType { text, image, video, poll, event }

enum CommunityNotificationLevel { all, highlights, off }

enum CommunityMediaFilter { all, photos, videos }

class CommunityGroupModel {
  const CommunityGroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.privacy,
    required this.memberCount,
    required this.coverColors,
    required this.avatarColor,
    required this.tags,
    required this.rules,
    required this.createdLabel,
    required this.category,
    required this.location,
    required this.links,
    required this.contactInfo,
    required this.posts,
    required this.events,
    required this.members,
    required this.recentActivity,
    required this.pinnedPosts,
    required this.announcements,
    required this.trendingPosts,
    this.joined = false,
    this.approvalRequired = true,
    this.allowEvents = true,
    this.allowLive = true,
    this.allowPolls = true,
    this.allowMarketplace = false,
    this.allowChatRoom = true,
    this.notificationLevel = CommunityNotificationLevel.all,
  });

  final String id;
  final String name;
  final String description;
  final CommunityPrivacy privacy;
  final int memberCount;
  final List<int> coverColors;
  final int avatarColor;
  final List<String> tags;
  final List<String> rules;
  final String createdLabel;
  final String category;
  final String location;
  final List<String> links;
  final String contactInfo;
  final List<CommunityPostModel> posts;
  final List<CommunityEventModel> events;
  final List<CommunityMemberModel> members;
  final List<String> recentActivity;
  final List<CommunityPostModel> pinnedPosts;
  final List<CommunityPostModel> announcements;
  final List<CommunityPostModel> trendingPosts;
  final bool joined;
  final bool approvalRequired;
  final bool allowEvents;
  final bool allowLive;
  final bool allowPolls;
  final bool allowMarketplace;
  final bool allowChatRoom;
  final CommunityNotificationLevel notificationLevel;

  CommunityGroupModel copyWith({
    bool? joined,
    bool? approvalRequired,
    bool? allowEvents,
    bool? allowLive,
    bool? allowPolls,
    bool? allowMarketplace,
    bool? allowChatRoom,
    CommunityNotificationLevel? notificationLevel,
    String? name,
    String? description,
    String? category,
    CommunityPrivacy? privacy,
  }) {
    return CommunityGroupModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      privacy: privacy ?? this.privacy,
      memberCount: memberCount,
      coverColors: coverColors,
      avatarColor: avatarColor,
      tags: tags,
      rules: rules,
      createdLabel: createdLabel,
      category: category ?? this.category,
      location: location,
      links: links,
      contactInfo: contactInfo,
      posts: posts,
      events: events,
      members: members,
      recentActivity: recentActivity,
      pinnedPosts: pinnedPosts,
      announcements: announcements,
      trendingPosts: trendingPosts,
      joined: joined ?? this.joined,
      approvalRequired: approvalRequired ?? this.approvalRequired,
      allowEvents: allowEvents ?? this.allowEvents,
      allowLive: allowLive ?? this.allowLive,
      allowPolls: allowPolls ?? this.allowPolls,
      allowMarketplace: allowMarketplace ?? this.allowMarketplace,
      allowChatRoom: allowChatRoom ?? this.allowChatRoom,
      notificationLevel: notificationLevel ?? this.notificationLevel,
    );
  }
}

class CommunityPostModel {
  const CommunityPostModel({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.authorAccent,
    required this.timeLabel,
    required this.content,
    required this.type,
    required this.likes,
    required this.comments,
    required this.shares,
    this.highlight = false,
    this.saved = false,
    this.pinned = false,
    this.mediaLabel,
    this.pollOptions = const <String>[],
  });

  final String id;
  final String authorName;
  final CommunityRole authorRole;
  final int authorAccent;
  final String timeLabel;
  final String content;
  final CommunityPostType type;
  final int likes;
  final int comments;
  final int shares;
  final bool highlight;
  final bool saved;
  final bool pinned;
  final String? mediaLabel;
  final List<String> pollOptions;

  CommunityPostModel copyWith({bool? saved, bool? pinned}) {
    return CommunityPostModel(
      id: id,
      authorName: authorName,
      authorRole: authorRole,
      authorAccent: authorAccent,
      timeLabel: timeLabel,
      content: content,
      type: type,
      likes: likes,
      comments: comments,
      shares: shares,
      highlight: highlight,
      saved: saved ?? this.saved,
      pinned: pinned ?? this.pinned,
      mediaLabel: mediaLabel,
      pollOptions: pollOptions,
    );
  }
}

class CommunityEventModel {
  const CommunityEventModel({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.locationLabel,
    required this.coverColor,
    required this.status,
    this.going = false,
  });

  final String id;
  final String title;
  final String dateLabel;
  final String locationLabel;
  final int coverColor;
  final String status;
  final bool going;

  CommunityEventModel copyWith({bool? going}) {
    return CommunityEventModel(
      id: id,
      title: title,
      dateLabel: dateLabel,
      locationLabel: locationLabel,
      coverColor: coverColor,
      status: status,
      going: going ?? this.going,
    );
  }
}

class CommunityMemberModel {
  const CommunityMemberModel({
    required this.id,
    required this.name,
    required this.role,
    required this.accentColor,
    this.topContributor = false,
    this.following = false,
  });

  final String id;
  final String name;
  final CommunityRole role;
  final int accentColor;
  final bool topContributor;
  final bool following;

  CommunityMemberModel copyWith({bool? following}) {
    return CommunityMemberModel(
      id: id,
      name: name,
      role: role,
      accentColor: accentColor,
      topContributor: topContributor,
      following: following ?? this.following,
    );
  }
}

class CommunityMediaItem {
  const CommunityMediaItem({
    required this.id,
    required this.label,
    required this.isVideo,
    required this.color,
  });

  final String id;
  final String label;
  final bool isVideo;
  final int color;
}
