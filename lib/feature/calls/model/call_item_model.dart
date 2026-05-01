enum CallType { voice, video }

enum CallState { incoming, outgoing, missed, completed }

class CallItemModel {
  const CallItemModel({
    required this.id,
    required this.user,
    required this.type,
    required this.state,
    required this.time,
  });

  final String id;
  final String user;
  final CallType type;
  final CallState state;
  final DateTime time;
}
