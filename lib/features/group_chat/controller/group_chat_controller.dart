import 'package:flutter/foundation.dart';

import '../model/group_chat_model.dart';
import '../repository/group_chat_repository.dart';

class GroupChatController extends ChangeNotifier {
  GroupChatController({GroupChatRepository? repository})
      : _repository = repository ?? GroupChatRepository();

  final GroupChatRepository _repository;
  List<GroupChatModel> groups = <GroupChatModel>[];

  void load() {
    groups = _repository.all();
    notifyListeners();
  }

  void createGroup(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _repository.create(trimmed, 'you');
    load();
  }

  void addMember(String groupId, String username) {
    _repository.addMember(groupId, username);
    load();
  }

  void removeMember(String groupId, String username) {
    _repository.removeMember(groupId, username);
    load();
  }
}
