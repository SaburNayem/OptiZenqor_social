import 'package:flutter/foundation.dart';

import '../model/group_chat_model.dart';
import '../repository/group_chat_repository.dart';

class GroupChatController extends ChangeNotifier {
  GroupChatController({GroupChatRepository? repository})
      : _repository = repository ?? GroupChatRepository();

  final GroupChatRepository _repository;
  List<GroupChatModel> groups = <GroupChatModel>[];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      groups = await _repository.all();
    } catch (error) {
      errorMessage = error.toString();
      groups = const <GroupChatModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void createGroup(String name) {
    errorMessage =
        'Creating group chats is not exposed by the backend group-chat route yet.';
    notifyListeners();
  }

  void addMember(String groupId, String username) {
    errorMessage =
        'Member management is not exposed by the backend group-chat route yet.';
    notifyListeners();
  }

  void removeMember(String groupId, String username) {
    errorMessage =
        'Member management is not exposed by the backend group-chat route yet.';
    notifyListeners();
  }
}
