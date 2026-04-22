import '../../../core/architecture/use_case.dart';
import '../model/community_group_model.dart';
import '../repository/communities_repository.dart';

class GetCommunitiesUseCase
    extends UseCase<List<CommunityGroupModel>, NoParams> {
  GetCommunitiesUseCase(this._repository);

  final CommunitiesRepository _repository;

  @override
  Future<List<CommunityGroupModel>> call(NoParams params) {
    return _repository.loadGroups();
  }
}

