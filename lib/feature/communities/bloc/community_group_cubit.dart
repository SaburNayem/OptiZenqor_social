import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/community_group_model.dart';
import 'community_group_state.dart';

class CommunityGroupCubit extends Cubit<CommunityGroupState> {
  CommunityGroupCubit({required CommunityGroupModel group})
    : super(
        CommunityGroupState(
          group: group,
          posts: group.posts,
          members: group.members,
          events: group.events,
        ),
      );

  CommunityGroupModel get group => state.group;
  List<CommunityPostModel> get posts => state.filteredPosts;
  List<CommunityMemberModel> get members => state.members;
  List<CommunityEventModel> get events => state.events;
  String get postFilter => state.postFilter;
  CommunityMediaFilter get mediaFilter => state.mediaFilter;
  String get memberQuery => state.memberQuery;
  bool get notificationsEnabled => state.notificationsEnabled;
  List<CommunityMediaItem> get mediaItems => state.mediaItems;
  List<CommunityEventModel> get upcomingEvents => state.upcomingEvents;
  List<CommunityEventModel> get ongoingEvents => state.ongoingEvents;
  List<CommunityEventModel> get pastEvents => state.pastEvents;
  List<CommunityMemberModel> get admins => state.admins;
  List<CommunityMemberModel> get moderators => state.moderators;
  List<CommunityMemberModel> get topContributors => state.topContributors;
  List<CommunityMemberModel> get visibleMembers => state.visibleMembers;

  void toggleJoin() {
    emit(
      state.copyWith(group: state.group.copyWith(joined: !state.group.joined)),
    );
  }

  void setPostFilter(String value) {
    emit(state.copyWith(postFilter: value));
  }

  void setMediaFilter(CommunityMediaFilter value) {
    emit(state.copyWith(mediaFilter: value));
  }

  void updateMemberQuery(String value) {
    emit(state.copyWith(memberQuery: value));
  }

  void toggleNotificationBell() {
    emit(state.copyWith(notificationsEnabled: !state.notificationsEnabled));
  }

  void setNotificationLevel(CommunityNotificationLevel value) {
    emit(state.copyWith(group: state.group.copyWith(notificationLevel: value)));
  }

  void toggleSavePost(String id) {
    emit(
      state.copyWith(
        posts: state.posts
            .map(
              (post) =>
                  post.id == id ? post.copyWith(saved: !post.saved) : post,
            )
            .toList(growable: false),
      ),
    );
  }

  void togglePinPost(String id) {
    emit(
      state.copyWith(
        posts: state.posts
            .map(
              (post) =>
                  post.id == id ? post.copyWith(pinned: !post.pinned) : post,
            )
            .toList(growable: false),
      ),
    );
  }

  void toggleFollowMember(String id) {
    emit(
      state.copyWith(
        members: state.members
            .map(
              (member) => member.id == id
                  ? member.copyWith(following: !member.following)
                  : member,
            )
            .toList(growable: false),
      ),
    );
  }

  void toggleGoing(String id) {
    emit(
      state.copyWith(
        events: state.events
            .map(
              (event) =>
                  event.id == id ? event.copyWith(going: !event.going) : event,
            )
            .toList(growable: false),
      ),
    );
  }

  void updateGeneral({
    required String name,
    required String description,
    required String category,
  }) {
    emit(
      state.copyWith(
        group: state.group.copyWith(
          name: name.trim().isEmpty ? state.group.name : name.trim(),
          description: description.trim().isEmpty
              ? state.group.description
              : description.trim(),
          category: category.trim().isEmpty
              ? state.group.category
              : category.trim(),
        ),
      ),
    );
  }

  void updatePrivacy({
    required CommunityPrivacy privacy,
    required bool approvalRequired,
  }) {
    emit(
      state.copyWith(
        group: state.group.copyWith(
          privacy: privacy,
          approvalRequired: approvalRequired,
        ),
      ),
    );
  }

  void updateFeatures({
    bool? events,
    bool? live,
    bool? polls,
    bool? marketplace,
    bool? chatRoom,
  }) {
    emit(
      state.copyWith(
        group: state.group.copyWith(
          allowEvents: events,
          allowLive: live,
          allowPolls: polls,
          allowMarketplace: marketplace,
          allowChatRoom: chatRoom,
        ),
      ),
    );
  }

  void loadMorePosts() {
    final nextIndex = state.posts.length + 1;
    final nextPost = CommunityPostModel(
      id: 'extra_$nextIndex',
      authorName: 'New contributor $nextIndex',
      authorRole: CommunityRole.member,
      authorAccent: 0xFF26C6DA,
      timeLabel: 'Just now',
      content: 'Fresh group update $nextIndex with local mock pagination.',
      type: nextIndex.isEven ? CommunityPostType.image : CommunityPostType.text,
      likes: 18 + nextIndex,
      comments: 6,
      shares: 2,
      mediaLabel: nextIndex.isEven ? 'New upload' : null,
    );
    emit(state.copyWith(posts: <CommunityPostModel>[...state.posts, nextPost]));
  }
}

