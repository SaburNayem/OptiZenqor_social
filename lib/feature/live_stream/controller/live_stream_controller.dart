import 'package:flutter/foundation.dart';

import '../model/live_stream_model.dart';
import '../repository/live_stream_repository.dart';

class LiveStreamController extends ChangeNotifier {
  LiveStreamController({LiveStreamRepository? repository})
      : _repository = repository ?? LiveStreamRepository();

  final LiveStreamRepository _repository;
  LiveStreamModel? live;

  void load() {
    live = _repository.load();
    notifyListeners();
  }
}
