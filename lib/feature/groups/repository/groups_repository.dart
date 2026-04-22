import '../model/group_model.dart';

class GroupsRepository {
  List<GroupModel> load() => const <GroupModel>[
        GroupModel(id: 'g_1', name: 'Flutter Bangladesh', members: 3200),
        GroupModel(id: 'g_2', name: 'Startup Builders', members: 1200),
      ];
}
