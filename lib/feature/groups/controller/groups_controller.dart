import 'package:flutter/foundation.dart';

import '../model/group_model.dart';
import '../repository/groups_repository.dart';

class GroupsController extends ChangeNotifier {
  GroupsController({GroupsRepository? repository})
      : _repository = repository ?? GroupsRepository();

  final GroupsRepository _repository;
  List<GroupModel> groups = <GroupModel>[];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      groups = await _repository.load();
    } catch (error) {
      errorMessage = error.toString();
      groups = const <GroupModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void createGroup(String name) {
    errorMessage =
        'Creating groups is not exposed by the backend groups route yet.';
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
