import '../model/community_group_model.dart';

abstract class CommunitiesRepository {
  Future<List<CommunityGroupModel>> loadGroups();
  Future<CommunityGroupModel?> createCommunity({
    required String name,
    required String description,
  });
  Future<CommunityGroupModel?> updateCommunity(CommunityGroupModel group);
  Future<CommunityGroupModel?> setJoined({
    required String communityId,
    required bool joined,
  });
}

