import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/architecture/use_case.dart';
import '../model/community_group_model.dart';
import '../repository/communities_repository.dart';
import '../usecase/get_communities_use_case.dart';
import 'communities_state.dart';

class CommunitiesCubit extends Cubit<CommunitiesState> {
  CommunitiesCubit({
    required GetCommunitiesUseCase getCommunitiesUseCase,
    required CommunitiesRepository repository,
    bool showJoinedFirst = false,
  }) : _getCommunitiesUseCase = getCommunitiesUseCase,
       _repository = repository,
       super(CommunitiesState(showJoinedOnly: showJoinedFirst));

  final GetCommunitiesUseCase _getCommunitiesUseCase;
  final CommunitiesRepository _repository;

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

  Future<void> toggleJoin(String id) async {
    final CommunityGroupModel? current = state.groups
        .where((CommunityGroupModel group) => group.id == id)
        .firstOrNull;
    if (current == null) {
      return;
    }
    final bool targetJoined = !current.joined;
    final CommunityGroupModel optimistic = current.copyWith(joined: targetJoined);
    emit(
      state.copyWith(
        groups: state.groups
            .map((CommunityGroupModel group) => group.id == id ? optimistic : group)
            .toList(growable: false),
      ),
    );
    final CommunityGroupModel? remote = await _repository.setJoined(
      communityId: id,
      joined: targetJoined,
    );
    if (remote == null) {
      emit(
        state.copyWith(
          groups: state.groups
              .map((CommunityGroupModel group) => group.id == id ? current : group)
              .toList(growable: false),
        ),
      );
      return;
    }
    applyUpdatedGroup(remote);
  }

  void applyUpdatedGroup(CommunityGroupModel updatedGroup) {
    final groups = state.groups
        .map((group) => group.id == updatedGroup.id ? updatedGroup : group)
        .toList(growable: false);
    emit(state.copyWith(groups: groups));
  }

  Future<void> createCommunity({
    required String name,
    required String description,
  }) async {
    if (name.trim().isEmpty) {
      return;
    }

    final CommunityGroupModel? created = await _repository.createCommunity(
      name: name,
      description: description,
    );
    if (created == null) {
      return;
    }
    emit(state.copyWith(groups: <CommunityGroupModel>[created, ...state.groups]));
  }
}


