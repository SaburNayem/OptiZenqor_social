import 'package:flutter/foundation.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/reel_model.dart';

class ReelsController extends ChangeNotifier {
  List<ReelModel> reels = <ReelModel>[];

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    reels = MockData.reels;
    notifyListeners();
  }
}
