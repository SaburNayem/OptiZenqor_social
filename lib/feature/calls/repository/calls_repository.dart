import '../model/call_item_model.dart';

class CallsRepository {
  final List<CallItemModel> _history = <CallItemModel>[
    CallItemModel(
      id: 'call_1',
      user: 'mayaquinn',
      type: CallType.voice,
      state: CallState.missed,
      time: DateTime(2026, 3, 23, 9, 30),
    ),
    CallItemModel(
      id: 'call_2',
      user: 'raymondlee',
      type: CallType.video,
      state: CallState.completed,
      time: DateTime(2026, 3, 22, 20, 15),
    ),
  ];

  List<CallItemModel> load() {
    return List<CallItemModel>.from(_history);
  }

  void startCall({required String user, required CallType type}) {
    _history.insert(
      0,
      CallItemModel(
        id: 'call_${DateTime.now().millisecondsSinceEpoch}',
        user: user,
        type: type,
        state: CallState.outgoing,
        time: DateTime.now(),
      ),
    );
  }
}
