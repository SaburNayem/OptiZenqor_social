import '../../model/community_group_model.dart';

class CommunityGroupState {
  const CommunityGroupState({
    required this.group,
    required this.posts,
    required this.members,
    required this.events,
    this.postFilter = 'Recent',
    this.mediaFilter = CommunityMediaFilter.all,
    this.memberQuery = '',
    this.notificationsEnabled = true,
  });

  final CommunityGroupModel group;
  final List<CommunityPostModel> posts;
  final List<CommunityMemberModel> members;
  final List<CommunityEventModel> events;
  final String postFilter;
  final CommunityMediaFilter mediaFilter;
  final String memberQuery;
  final bool notificationsEnabled;

  List<CommunityPostModel> get filteredPosts {
    if (postFilter == 'Popular') {
      final items = <CommunityPostModel>[...posts];
      items.sort((a, b) => b.likes.compareTo(a.likes));
      return items;
    }
    if (postFilter == 'Media only') {
      return posts
          .where(
            (item) =>
                item.type == CommunityPostType.image ||
                item.type == CommunityPostType.video,
          )
          .toList(growable: false);
    }
    return posts;
  }

  List<CommunityMediaItem> get mediaItems {
    final base = posts
        .where((post) => post.mediaLabel != null)
        .map(
          (post) => CommunityMediaItem(
            id: post.id,
            label: post.mediaLabel!,
            isVideo: post.type == CommunityPostType.video,
            color: post.authorAccent,
          ),
        )
        .toList(growable: false);
    switch (mediaFilter) {
      case CommunityMediaFilter.photos:
        return base.where((item) => !item.isVideo).toList(growable: false);
      case CommunityMediaFilter.videos:
        return base.where((item) => item.isVideo).toList(growable: false);
      case CommunityMediaFilter.all:
        return base;
    }
  }

  List<CommunityEventModel> get upcomingEvents => events
      .where((event) => event.status == 'Upcoming')
      .toList(growable: false);
  List<CommunityEventModel> get ongoingEvents => events
      .where((event) => event.status == 'Ongoing')
      .toList(growable: false);
  List<CommunityEventModel> get pastEvents =>
      events.where((event) => event.status == 'Past').toList(growable: false);

  List<CommunityMemberModel> get admins => members
      .where((member) => member.role == CommunityRole.admin)
      .toList(growable: false);
  List<CommunityMemberModel> get moderators => members
      .where((member) => member.role == CommunityRole.moderator)
      .toList(growable: false);
  List<CommunityMemberModel> get topContributors =>
      members.where((member) => member.topContributor).toList(growable: false);
  List<CommunityMemberModel> get visibleMembers {
    final query = memberQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return members;
    }
    return members
        .where((member) => member.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  CommunityGroupState copyWith({
    CommunityGroupModel? group,
    List<CommunityPostModel>? posts,
    List<CommunityMemberModel>? members,
    List<CommunityEventModel>? events,
    String? postFilter,
    CommunityMediaFilter? mediaFilter,
    String? memberQuery,
    bool? notificationsEnabled,
  }) {
    return CommunityGroupState(
      group: group ?? this.group,
      posts: posts ?? this.posts,
      members: members ?? this.members,
      events: events ?? this.events,
      postFilter: postFilter ?? this.postFilter,
      mediaFilter: mediaFilter ?? this.mediaFilter,
      memberQuery: memberQuery ?? this.memberQuery,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
