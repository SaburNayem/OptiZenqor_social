import '../model/live_stream_model.dart';

class LiveStreamRepository {
  LiveStreamModel load() => const LiveStreamModel(roomName: 'Creator Live Room', viewerCount: 120, comments: <String>['Great session', 'Nice insights']);
}
