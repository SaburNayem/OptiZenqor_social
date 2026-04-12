import '../../model/community_group_model.dart';

abstract class CommunitiesRepository {
  Future<List<CommunityGroupModel>> loadGroups();
}
