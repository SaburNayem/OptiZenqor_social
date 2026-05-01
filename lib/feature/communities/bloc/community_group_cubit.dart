import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/community_group_model.dart';
import '../repository/communities_repository.dart';
import 'community_group_state.dart';

class CommunityGroupCubit extends Cubit<CommunityGroupState> {
  CommunityGroupCubit({
    required CommunityGroupModel group,
    required CommunitiesRepository repository,
  }) : _repository = repository,
       super(
         CommunityGroupState(
           group: group,
           posts: group.posts,
           members: group.members,
           events: group.events,
         ),
       );

  final CommunitiesRepository _repository;

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

  Future<void> toggleJoin() async {
    final CommunityGroupModel previous = state.group;
    final CommunityGroupModel optimistic = previous.copyWith(
      joined: !previous.joined,
    );
    emit(state.copyWith(group: optimistic));
    final CommunityGroupModel? remote = await _repository.setJoined(
      communityId: previous.id,
      joined: optimistic.joined,
    );
    emit(state.copyWith(group: remote ?? previous));
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

  Future<void> updateGeneral({
    required String name,
    required String description,
    required String category,
  }) async {
    final CommunityGroupModel previous = state.group;
    final CommunityGroupModel optimistic = state.group.copyWith(
      name: name.trim().isEmpty ? state.group.name : name.trim(),
      description: description.trim().isEmpty
          ? state.group.description
          : description.trim(),
      category: category.trim().isEmpty
          ? state.group.category
          : category.trim(),
    );
    emit(state.copyWith(group: optimistic));
    final CommunityGroupModel? remote = await _repository.updateCommunity(
      optimistic,
    );
    emit(state.copyWith(group: remote ?? previous));
  }

  Future<void> updatePrivacy({
    required CommunityPrivacy privacy,
    required bool approvalRequired,
  }) async {
    final CommunityGroupModel previous = state.group;
    final CommunityGroupModel optimistic = state.group.copyWith(
      privacy: privacy,
      approvalRequired: approvalRequired,
    );
    emit(state.copyWith(group: optimistic));
    final CommunityGroupModel? remote = await _repository.updateCommunity(
      optimistic,
    );
    emit(state.copyWith(group: remote ?? previous));
  }

  Future<void> updateFeatures({
    bool? events,
    bool? live,
    bool? polls,
    bool? marketplace,
    bool? chatRoom,
  }) async {
    final CommunityGroupModel previous = state.group;
    final CommunityGroupModel optimistic = state.group.copyWith(
      allowEvents: events,
      allowLive: live,
      allowPolls: polls,
      allowMarketplace: marketplace,
      allowChatRoom: chatRoom,
    );
    emit(state.copyWith(group: optimistic));
    final CommunityGroupModel? remote = await _repository.updateCommunity(
      optimistic,
    );
    emit(state.copyWith(group: remote ?? previous));
  }

  void loadMorePosts() {
    emit(state.copyWith(posts: state.posts));
  }
}
