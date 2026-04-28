import 'socket_transport_stub.dart'
    if (dart.library.io) 'socket_transport_io.dart'
    if (dart.library.html) 'socket_transport_web.dart';

abstract class PlatformSocketTransport {
  Stream<dynamic> get messages;

  Future<void> send(Map<String, dynamic> payload);

  Future<void> close();
}

Future<PlatformSocketTransport> openPlatformSocket(
  Uri uri, {
  Map<String, String>? headers,
}) {
  return openSocketTransport(uri, headers: headers);
}
