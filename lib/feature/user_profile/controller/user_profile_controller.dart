import 'package:flutter/foundation.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/user_model.dart';

class UserProfileController extends ChangeNotifier {
  UserModel? user;

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    user = MockData.users.first;
    notifyListeners();
  }
}
