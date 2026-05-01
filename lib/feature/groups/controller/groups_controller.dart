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

  Future<void> createGroup(String name) async {
    final GroupModel? created = await _repository.createGroup(name);
    if (created == null) {
      errorMessage = 'Unable to create the group right now.';
      notifyListeners();
      return;
    }
    groups = <GroupModel>[created, ...groups];
    errorMessage = null;
    notifyListeners();
  }

  Future<void> toggleJoin(String id) async {
    final GroupModel? current = groups
        .where((group) => group.id == id)
        .firstOrNull;
    if (current == null) {
      return;
    }
    final GroupModel? remote = await _repository.setJoined(
      id: id,
      joined: !current.joined,
    );
    if (remote == null) {
      errorMessage = 'Unable to update the group membership right now.';
      notifyListeners();
      return;
    }
    groups = groups
        .map((group) => group.id == id ? remote : group)
        .toList(growable: false);
    errorMessage = null;
    notifyListeners();
  }
}
