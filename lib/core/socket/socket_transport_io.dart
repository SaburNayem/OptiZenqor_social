import 'dart:convert';
import 'dart:io';

import '../config/app_config.dart';
import 'socket_property.dart';
import 'socket_transport.dart';

class IoSocketTransport implements PlatformSocketTransport {
  IoSocketTransport(this._socket);

  final WebSocket _socket;

  @override
  Stream<dynamic> get messages => _socket;

  @override
  Future<void> close() => _socket.close();

  @override
  Future<void> send(Map<String, dynamic> payload) async {
    _socket.add(jsonEncode(payload));
  }
}

Future<PlatformSocketTransport> openSocketTransport(
  Uri uri, {
  Map<String, String>? headers,
}) async {
  final WebSocket socket = await WebSocket.connect(
    uri.toString(),
    headers: headers,
  ).timeout(Duration(milliseconds: AppConfig.socketConnectTimeoutMs));
  socket.pingInterval = Duration(milliseconds: SocketProperty.pingIntervalMs);
  return IoSocketTransport(socket);
}
