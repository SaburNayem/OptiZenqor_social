import 'package:flutter/foundation.dart';

import '../model/group_model.dart';
import '../repository/groups_repository.dart';

class GroupsController extends ChangeNotifier {
  GroupsController({GroupsRepository? repository})
      : _repository = repository ?? GroupsRepository();

  final GroupsRepository _repository;
  List<GroupModel> groups = <GroupModel>[];

  void load() {
    groups = _repository.load();
    notifyListeners();
  }

  void createGroup(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    groups = <GroupModel>[
      GroupModel(
        id: 'group_${DateTime.now().millisecondsSinceEpoch}',
        name: trimmed,
        members: 1,
        joined: true,
      ),
      ...groups,
    ];
    notifyListeners();
  }

  void toggleJoin(String id) {
    groups = groups
        .map(
          (group) => group.id == id
              ? group.copyWith(joined: !group.joined)
              : group,
        )
        .toList();
    notifyListeners();
  }
}
