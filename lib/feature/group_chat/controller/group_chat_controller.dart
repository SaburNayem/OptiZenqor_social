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

  Future<void> createGroup(String name) async {
    if (name.trim().isEmpty) {
      errorMessage = 'Group name is required.';
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.createGroup(name.trim());
      groups = await _repository.all();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMember(String groupId, String username) async {
    if (username.trim().isEmpty) {
      errorMessage = 'Member identifier is required.';
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.addMember(groupId, username.trim());
      groups = await _repository.all();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeMember(String groupId, String username) async {
    if (username.trim().isEmpty) {
      errorMessage = 'Member identifier is required.';
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.removeMember(groupId, username.trim());
      groups = await _repository.all();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
