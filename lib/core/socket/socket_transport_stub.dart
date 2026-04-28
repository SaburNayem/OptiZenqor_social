import 'socket_transport.dart';

class UnsupportedPlatformSocketTransport implements PlatformSocketTransport {
  UnsupportedPlatformSocketTransport(this.uri);

  final Uri uri;

  @override
  Stream<dynamic> get messages => const Stream<dynamic>.empty();

  @override
  Future<void> close() async {}

  @override
  Future<void> send(Map<String, dynamic> payload) async {
    throw UnsupportedError(
      'WebSocket transport is not supported on this platform for $uri',
    );
  }
}

Future<PlatformSocketTransport> openSocketTransport(
  Uri uri, {
  Map<String, String>? headers,
}) async {
  return UnsupportedPlatformSocketTransport(uri);
}
