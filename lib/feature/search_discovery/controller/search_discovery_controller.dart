import 'package:flutter/foundation.dart';

import '../../../core/common_models/user_model.dart';
import '../../../core/common_data/mock_data.dart';
import '../../../core/utils/debouncer.dart';

class SearchDiscoveryController extends ChangeNotifier {
  SearchDiscoveryController() : _debouncer = Debouncer(milliseconds: 350);

  final Debouncer _debouncer;
  List<UserModel> results = <UserModel>[];

  void search(String query) {
    _debouncer.run(() {
      final term = query.trim().toLowerCase();
      if (term.isEmpty) {
        results = <UserModel>[];
      } else {
        results = MockData.users
            .where(
              (user) => user.name.toLowerCase().contains(term) ||
                  user.username.toLowerCase().contains(term),
            )
            .toList();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}
