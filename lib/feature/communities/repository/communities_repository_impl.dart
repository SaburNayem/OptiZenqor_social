import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/community_group_model.dart';
import '../repository/communities_repository.dart';
import '../service/community_local_data_source.dart';
import '../service/communities_service.dart';

class CommunitiesRepositoryImpl implements CommunitiesRepository {
  CommunitiesRepositoryImpl({
    CommunitiesService? service,
    CommunityLocalDataSource? localDataSource,
  }) : _service = service ?? CommunitiesService(),
       _localDataSource = localDataSource ?? CommunityLocalDataSource();

  final CommunitiesService _service;
  final CommunityLocalDataSource _localDataSource;

  @override
  Future<List<CommunityGroupModel>> loadGroups() async {
    final cachedGroups = await _localDataSource.readGroups();

    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.apiClient.get(ApiEndPoints.communities);
      if (response.isSuccess) {
        final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['communities', 'data', 'items'],
        );
        if (items.isNotEmpty) {
          final List<CommunityGroupModel> groups = items
              .map(_groupFromApiJson)
              .where((CommunityGroupModel item) => item.id.isNotEmpty)
              .toList(growable: false);
          if (groups.isNotEmpty) {
            await _localDataSource.saveGroups(groups);
            return groups;
          }
        }
      }
    } catch (_) {}

    return cachedGroups;
  }

  CommunityGroupModel _groupFromApiJson(Map<String, dynamic> json) {
    return CommunityGroupModel(
      id: ApiPayloadReader.readString(json['id']),
      name: ApiPayloadReader.readString(json['name'], fallback: 'Community'),
      description: ApiPayloadReader.readString(json['description']),
      privacy: _privacyFromValue(json['privacy']),
      memberCount: ApiPayloadReader.readInt(json['memberCount']),
      coverColors: _colorListFromValue(json['coverColors']),
      avatarColor: ApiPayloadReader.readInt(json['avatarColor']),
      tags: ApiPayloadReader.readStringList(json['tags']),
      rules: ApiPayloadReader.readStringList(json['rules']),
      createdLabel: ApiPayloadReader.readString(json['createdLabel']),
      category: ApiPayloadReader.readString(json['category']),
      location: ApiPayloadReader.readString(json['location']),
      links: ApiPayloadReader.readStringList(json['links']),
      contactInfo: ApiPayloadReader.readString(json['contactInfo']),
      posts: _readPostList(json['posts']),
      events: _readEventList(json['events']),
      members: _readMemberList(json['members']),
      recentActivity: ApiPayloadReader.readStringList(json['recentActivity']),
      pinnedPosts: _readPostList(json['pinnedPosts']),
      announcements: _readPostList(json['announcements']),
      trendingPosts: _readPostList(json['trendingPosts']),
      joined: ApiPayloadReader.readBool(json['joined']) ?? false,
      approvalRequired:
          ApiPayloadReader.readBool(json['approvalRequired']) ?? true,
      allowEvents: ApiPayloadReader.readBool(json['allowEvents']) ?? true,
      allowLive: ApiPayloadReader.readBool(json['allowLive']) ?? true,
      allowPolls: ApiPayloadReader.readBool(json['allowPolls']) ?? true,
      allowMarketplace:
          ApiPayloadReader.readBool(json['allowMarketplace']) ?? false,
      allowChatRoom: ApiPayloadReader.readBool(json['allowChatRoom']) ?? true,
      notificationLevel: _notificationLevelFromValue(json['notificationLevel']),
    );
  }

  List<CommunityPostModel> _readPostList(Object? value) {
    return ApiPayloadReader.readMapListFromAny(value)
        .map(_postFromApiJson)
        .where((CommunityPostModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  List<CommunityEventModel> _readEventList(Object? value) {
    return ApiPayloadReader.readMapListFromAny(value)
        .map(_eventFromApiJson)
        .where((CommunityEventModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  List<CommunityMemberModel> _readMemberList(Object? value) {
    return ApiPayloadReader.readMapListFromAny(value)
        .map(_memberFromApiJson)
        .where((CommunityMemberModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  CommunityPostModel _postFromApiJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: ApiPayloadReader.readString(json['id']),
      authorName: ApiPayloadReader.readString(
        json['authorName'],
        fallback: 'Community member',
      ),
      authorRole: _roleFromValue(json['authorRole']),
      authorAccent: ApiPayloadReader.readInt(json['authorAccent']),
      timeLabel: ApiPayloadReader.readString(json['timeLabel']),
      content: ApiPayloadReader.readString(json['content']),
      type: _postTypeFromValue(json['type']),
      likes: ApiPayloadReader.readInt(json['likes']),
      comments: ApiPayloadReader.readInt(json['comments']),
      shares: ApiPayloadReader.readInt(json['shares']),
      highlight: ApiPayloadReader.readBool(json['highlight']) ?? false,
      saved: ApiPayloadReader.readBool(json['saved']) ?? false,
      pinned: ApiPayloadReader.readBool(json['pinned']) ?? false,
      mediaLabel: ApiPayloadReader.readString(json['mediaLabel']),
      pollOptions: ApiPayloadReader.readStringList(json['pollOptions']),
    );
  }

  CommunityEventModel _eventFromApiJson(Map<String, dynamic> json) {
    return CommunityEventModel(
      id: ApiPayloadReader.readString(json['id']),
      title: ApiPayloadReader.readString(json['title']),
      dateLabel: ApiPayloadReader.readString(json['dateLabel']),
      locationLabel: ApiPayloadReader.readString(json['locationLabel']),
      coverColor: ApiPayloadReader.readInt(json['coverColor']),
      status: ApiPayloadReader.readString(json['status']),
      going: ApiPayloadReader.readBool(json['going']) ?? false,
    );
  }

  CommunityMemberModel _memberFromApiJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      id: ApiPayloadReader.readString(json['id']),
      name: ApiPayloadReader.readString(json['name']),
      role: _roleFromValue(json['role']),
      accentColor: ApiPayloadReader.readInt(json['accentColor']),
      topContributor:
          ApiPayloadReader.readBool(json['topContributor']) ?? false,
      following: ApiPayloadReader.readBool(json['following']) ?? false,
    );
  }

  List<int> _colorListFromValue(Object? value) {
    if (value is List) {
      final List<int> colors = value
          .map((Object? item) => ApiPayloadReader.readInt(item))
          .where((int item) => item != 0)
          .toList(growable: false);
      if (colors.isNotEmpty) {
        return colors;
      }
    }
    return const <int>[0xFF0F172A, 0xFF2563EB];
  }

  CommunityPrivacy _privacyFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'private':
        return CommunityPrivacy.private;
      case 'hidden':
        return CommunityPrivacy.hidden;
      case 'public':
      default:
        return CommunityPrivacy.public;
    }
  }

  CommunityRole _roleFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'admin':
        return CommunityRole.admin;
      case 'moderator':
        return CommunityRole.moderator;
      case 'member':
      default:
        return CommunityRole.member;
    }
  }

  CommunityPostType _postTypeFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'image':
        return CommunityPostType.image;
      case 'video':
        return CommunityPostType.video;
      case 'poll':
        return CommunityPostType.poll;
      case 'event':
        return CommunityPostType.event;
      case 'text':
      default:
        return CommunityPostType.text;
    }
  }

  CommunityNotificationLevel _notificationLevelFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'highlights':
        return CommunityNotificationLevel.highlights;
      case 'off':
        return CommunityNotificationLevel.off;
      case 'all':
      default:
        return CommunityNotificationLevel.all;
    }
  }
}
