import '../../model/community_group_model.dart';
import '../../domain/repositories/communities_repository.dart';
import '../datasources/community_local_data_source.dart';
import '../datasources/community_mock_data_source.dart';

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
