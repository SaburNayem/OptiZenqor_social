import 'package:flutter/foundation.dart';

import '../model/call_item_model.dart';
import '../repository/calls_repository.dart';

class CallsController extends ChangeNotifier {
  CallsController({CallsRepository? repository})
      : _repository = repository ?? CallsRepository();

  final CallsRepository _repository;
  List<CallItemModel> callHistory = <CallItemModel>[];

  void load() {
    callHistory = _repository.load();
    notifyListeners();
  }

  void startCall({required String user, required CallType type}) {
    _repository.startCall(user: user, type: type);
    load();
  }
}
