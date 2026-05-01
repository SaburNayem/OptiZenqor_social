import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../model/community_group_model.dart';

class CommunityLocalDataSource {
  CommunityLocalDataSource({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  static const String _table = 'communities_cache';
  static const String _cacheKey = 'communities_groups';

  Future<List<CommunityGroupModel>> readGroups() async {
    final payload = await _database.readJsonRecord(
      table: _table,
      key: _cacheKey,
    );
    if (payload == null || payload.isEmpty) {
      return <CommunityGroupModel>[];
    }

    final raw = jsonDecode(payload) as List<dynamic>;
    return raw
        .map((item) => _groupFromMap(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> saveGroups(List<CommunityGroupModel> groups) async {
    final payload = jsonEncode(
      groups.map((group) => _groupToMap(group)).toList(growable: false),
    );
    await _database.insertJsonRecord(
      table: _table,
      key: _cacheKey,
      payload: payload,
    );
  }
}

Map<String, dynamic> _groupToMap(CommunityGroupModel group) {
  return {
    'id': group.id,
    'name': group.name,
    'description': group.description,
    'privacy': group.privacy.name,
    'memberCount': group.memberCount,
    'coverColors': group.coverColors,
    'avatarColor': group.avatarColor,
    'tags': group.tags,
    'rules': group.rules,
    'createdLabel': group.createdLabel,
    'category': group.category,
    'location': group.location,
    'links': group.links,
    'contactInfo': group.contactInfo,
    'recentActivity': group.recentActivity,
    'joined': group.joined,
    'approvalRequired': group.approvalRequired,
    'allowEvents': group.allowEvents,
    'allowLive': group.allowLive,
    'allowPolls': group.allowPolls,
    'allowMarketplace': group.allowMarketplace,
    'allowChatRoom': group.allowChatRoom,
    'notificationLevel': group.notificationLevel.name,
    'posts': group.posts.map(_postToMap).toList(growable: false),
    'events': group.events.map(_eventToMap).toList(growable: false),
    'members': group.members.map(_memberToMap).toList(growable: false),
    'pinnedPosts': group.pinnedPosts.map(_postToMap).toList(growable: false),
    'announcements': group.announcements
        .map(_postToMap)
        .toList(growable: false),
    'trendingPosts': group.trendingPosts
        .map(_postToMap)
        .toList(growable: false),
  };
}

CommunityGroupModel _groupFromMap(Map<String, dynamic> map) {
  return CommunityGroupModel(
    id: map['id'] as String,
    name: map['name'] as String,
    description: map['description'] as String,
    privacy: CommunityPrivacy.values.byName(map['privacy'] as String),
    memberCount: map['memberCount'] as int,
    coverColors: List<int>.from(map['coverColors'] as List<dynamic>),
    avatarColor: map['avatarColor'] as int,
    tags: List<String>.from(map['tags'] as List<dynamic>),
    rules: List<String>.from(map['rules'] as List<dynamic>),
    createdLabel: map['createdLabel'] as String,
    category: map['category'] as String,
    location: map['location'] as String,
    links: List<String>.from(map['links'] as List<dynamic>),
    contactInfo: map['contactInfo'] as String,
    posts: (map['posts'] as List<dynamic>)
        .map((item) => _postFromMap(item as Map<String, dynamic>))
        .toList(growable: false),
    events: (map['events'] as List<dynamic>)
        .map((item) => _eventFromMap(item as Map<String, dynamic>))
        .toList(growable: false),
    members: (map['members'] as List<dynamic>)
        .map((item) => _memberFromMap(item as Map<String, dynamic>))
        .toList(growable: false),
    recentActivity: List<String>.from(map['recentActivity'] as List<dynamic>),
    pinnedPosts: (map['pinnedPosts'] as List<dynamic>)
        .map((item) => _postFromMap(item as Map<String, dynamic>))
        .toList(growable: false),
    announcements: (map['announcements'] as List<dynamic>)
        .map((item) => _postFromMap(item as Map<String, dynamic>))
        .toList(growable: false),
    trendingPosts: (map['trendingPosts'] as List<dynamic>)
        .map((item) => _postFromMap(item as Map<String, dynamic>))
        .toList(growable: false),
    joined: map['joined'] as bool? ?? false,
    approvalRequired: map['approvalRequired'] as bool? ?? true,
    allowEvents: map['allowEvents'] as bool? ?? true,
    allowLive: map['allowLive'] as bool? ?? true,
    allowPolls: map['allowPolls'] as bool? ?? true,
    allowMarketplace: map['allowMarketplace'] as bool? ?? false,
    allowChatRoom: map['allowChatRoom'] as bool? ?? true,
    notificationLevel: CommunityNotificationLevel.values.byName(
      map['notificationLevel'] as String,
    ),
  );
}

Map<String, dynamic> _postToMap(CommunityPostModel post) {
  return {
    'id': post.id,
    'authorName': post.authorName,
    'authorRole': post.authorRole.name,
    'authorAccent': post.authorAccent,
    'timeLabel': post.timeLabel,
    'content': post.content,
    'type': post.type.name,
    'likes': post.likes,
    'comments': post.comments,
    'shares': post.shares,
    'highlight': post.highlight,
    'saved': post.saved,
    'pinned': post.pinned,
    'mediaLabel': post.mediaLabel,
    'pollOptions': post.pollOptions,
  };
}

CommunityPostModel _postFromMap(Map<String, dynamic> map) {
  return CommunityPostModel(
    id: map['id'] as String,
    authorName: map['authorName'] as String,
    authorRole: CommunityRole.values.byName(map['authorRole'] as String),
    authorAccent: map['authorAccent'] as int,
    timeLabel: map['timeLabel'] as String,
    content: map['content'] as String,
    type: CommunityPostType.values.byName(map['type'] as String),
    likes: map['likes'] as int,
    comments: map['comments'] as int,
    shares: map['shares'] as int,
    highlight: map['highlight'] as bool? ?? false,
    saved: map['saved'] as bool? ?? false,
    pinned: map['pinned'] as bool? ?? false,
    mediaLabel: map['mediaLabel'] as String?,
    pollOptions: List<String>.from(
      map['pollOptions'] as List<dynamic>? ?? const <dynamic>[],
    ),
  );
}

Map<String, dynamic> _eventToMap(CommunityEventModel event) {
  return {
    'id': event.id,
    'title': event.title,
    'dateLabel': event.dateLabel,
    'locationLabel': event.locationLabel,
    'coverColor': event.coverColor,
    'status': event.status,
    'going': event.going,
  };
}

CommunityEventModel _eventFromMap(Map<String, dynamic> map) {
  return CommunityEventModel(
    id: map['id'] as String,
    title: map['title'] as String,
    dateLabel: map['dateLabel'] as String,
    locationLabel: map['locationLabel'] as String,
    coverColor: map['coverColor'] as int,
    status: map['status'] as String,
    going: map['going'] as bool? ?? false,
  );
}

Map<String, dynamic> _memberToMap(CommunityMemberModel member) {
  return {
    'id': member.id,
    'name': member.name,
    'role': member.role.name,
    'accentColor': member.accentColor,
    'topContributor': member.topContributor,
    'following': member.following,
  };
}

CommunityMemberModel _memberFromMap(Map<String, dynamic> map) {
  return CommunityMemberModel(
    id: map['id'] as String,
    name: map['name'] as String,
    role: CommunityRole.values.byName(map['role'] as String),
    accentColor: map['accentColor'] as int,
    topContributor: map['topContributor'] as bool? ?? false,
    following: map['following'] as bool? ?? false,
  );
}
