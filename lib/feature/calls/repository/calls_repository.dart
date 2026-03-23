import '../model/call_item_model.dart';

class CallsRepository {
  final List<CallItemModel> _history = <CallItemModel>[
    CallItemModel(
      id: 'call_1',
                                                                                                                                                                                                                                                                                                                                                                       .da                                                                                                                                                                                                                                                                                                                                                                       .da                                                                         tory();
    notifyListeners();
  }

  void startCall({required String user, required CallType type}) {
    _repository.add(
      CallItemModel(
        id: 'call_${DateTime.now().millisecondsSinceEpoch}',
        user: user,
        type: type,
        state: CallState.outgoing,
        time: DateTime.now(),
      ),
    );
    load();
  }
}
