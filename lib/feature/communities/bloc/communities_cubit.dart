import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/architecture/use_case.dart';
import '../model/community_group_model.dart';
import '../usecase/get_communities_use_case.dart';
import 'communities_state.dart';

class CommunitiesCubit extends Cubit<CommunitiesState> {
  CommunitiesCubit({
    required GetCommunitiesUseCase getCommunitiesUseCase,
    bool showJoinedFirst = false,
  }) : _getCommunitiesUseCase = getCommunitiesUseCase,
       super(CommunitiesState(showJoinedOnly: showJoinedFirst));

  final GetCommunitiesUseCase _getCommunitiesUseCase;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final groups = await _getCommunitiesUseCase(const NoParams());
    emit(state.copyWith(groups: groups, isLoading: false));
  }

  void updateQuery(String value) {
    emit(state.copyWith(query: value));
  }

  void showJoinedOnly(bool value) {
    emit(state.copyWith(showJoinedOnly: value));
  }

  void toggleJoin(String id) {
    final groups = state.groups
        .map(
          (group) =>
              group.id == id ? group.copyWith(joined: !group.joined) : group,
        )
        .toList(growable: false);
    emit(state.copyWith(groups: groups));
  }

  void applyUpdatedGroup(CommunityGroupModel updatedGroup) {
    final groups = state.groups
        .map((group) => group.id == updatedGroup.id ? updatedGroup : group)
        .toList(growable: false);
    emit(state.copyWith(groups: groups));
  }

  void createCommunity({required String name, required String description}) {
    if (name.trim().isEmpty) {
      return;
    }

    final nextGroup = CommunityGroupModel(
      id: 'created_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      description: description.trim().isEmpty
          ? 'A new local community created from the app drawer.'
          : description.trim(),
      privacy: CommunityPrivacy.private,
      memberCount: 12,
      coverColors: const <int>[0xFF2444FF, 0xFF59C3C3],
      avatarColor: 0xFF2444FF,
      tags: const <String>['New', 'Local', 'Social'],
      rules: const <String>[
        'Be respectful',
        'Keep posts relevant',
        'Use clear titles',
      ],
      createdLabel: 'Created today',
      category: 'Custom',
      location: 'Online',
      links: const <String>['https://community.local'],
      contactInfo: 'hello@community.local',
      posts: const <CommunityPostModel>[],
      events: const <CommunityEventModel>[],
      members: const <CommunityMemberModel>[],
      recentActivity: const <String>['Community created locally'],
      pinnedPosts: const <CommunityPostModel>[],
      announcements: const <CommunityPostModel>[],
      trendingPosts: const <CommunityPostModel>[],
      joined: true,
    );

    emit(
      state.copyWith(groups: <CommunityGroupModel>[nextGroup, ...state.groups]),
    );
  }
}


