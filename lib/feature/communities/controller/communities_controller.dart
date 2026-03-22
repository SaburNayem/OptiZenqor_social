import 'package:flutter/foundation.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/group_model.dart';

class CommunitiesController extends ChangeNotifier {
  List<GroupModel> groups = <GroupModel>[];
  final Set<String> _joinedGroupIds = <String>{};

  bool isJoined(String groupId) => _joinedGroupIds.contains(groupId);

  void toggleJoin(String groupId) {
    if (_joinedGroupIds.contains(groupId)) {
      _joinedGroupIds.remove(groupId);
    } else {
      _joinedGroupIds.add(groupId);
    }
    notifyListeners();
  }

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    groups = MockData.groups;
    notifyListeners();
  }
}
