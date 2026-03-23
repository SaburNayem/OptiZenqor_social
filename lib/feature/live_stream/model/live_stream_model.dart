class LiveStreamModel {
  const LiveStreamModel({required this.roomName, required this.viewerCount, required this.comments});
  final String roomName;
  final int viewerCount;
  final List<String> comments;
}
