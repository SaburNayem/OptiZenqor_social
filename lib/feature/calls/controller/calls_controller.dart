import 'package:flutter/foundation.dart';

import '../model/call_item_model.dart';
import '../repository/calls_repository.dart';

class CallsController extends ChangeNotifier {
  CallsController({CallsRepository? repository})
    : _repository = repository ?? CallsRepository();

  final CallsRepository _repository;
  List<CallItemModel> callHistory = <CallItemModel>[];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      callHistory = await _repository.load();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startCall({required String user, required CallType type}) async {
    try {
      await _repository.startCall(user: user, type: type);
      await load();
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }
}
