import '../model/community_group_model.dart';
import '../repository/communities_repository.dart';
import '../service/community_local_data_source.dart';
import '../service/community_mock_data_source.dart';

class CommunitiesRepositoryImpl implements CommunitiesRepository {
  CommunitiesRepositoryImpl({
    CommunityMockDataSource? remoteDataSource,
    CommunityLocalDataSource? localDataSource,
  }) : _remoteDataSource = remoteDataSource ?? CommunityMockDataSource(),
       _localDataSource = localDataSource ?? CommunityLocalDataSource();

  final CommunityMockDataSource _remoteDataSource;
  final CommunityLocalDataSource _localDataSource;

  @override
  Future<List<CommunityGroupModel>> loadGroups() async {
    final cachedGroups = await _localDataSource.readGroups();
    if (cachedGroups.isNotEmpty) {
      return cachedGroups;
    }

    final groups = await _remoteDataSource.loadGroups();
    await _localDataSource.saveGroups(groups);
    return groups;
  }
}


