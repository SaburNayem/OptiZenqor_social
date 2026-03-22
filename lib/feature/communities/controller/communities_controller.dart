import 'package:flutter/foundation.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/group_model.dart';

class CommunitiesController extends ChangeNotifier {
  List<GroupModel> groups = <GroupModel>[];

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    groups = MockData.groups;
    notifyListeners();
  }
}
