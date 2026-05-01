// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import '../config/app_config.dart';
import 'socket_transport.dart';

class WebSocketTransport implements PlatformSocketTransport {
  WebSocketTransport(this._socket) {
    _messageController = StreamController<dynamic>.broadcast(
      onCancel: () {
        if (!_messageController.hasListener) {
          close();
        }
      },
    );
    _socket.onMessage.listen((html.MessageEvent event) {
      _messageController.add(event.data);
    });
    _socket.onError.listen((_) {
      _messageController.addError(
        StateError('WebSocket connection error: ${_socket.url}'),
      );
    });
    _socket.onClose.listen((_) {
      _messageController.close();
    });
  }

  final html.WebSocket _socket;
  late final StreamController<dynamic> _messageController;

  @override
  Stream<dynamic> get messages => _messageController.stream;

  @override
  Future<void> close() async {
    _socket.close();
    if (!_messageController.isClosed) {
      await _messageController.close();
    }
  }

  @override
  Future<void> send(Map<String, dynamic> payload) async {
    _socket.send(jsonEncode(payload));
  }
}

Future<PlatformSocketTransport> openSocketTransport(
  Uri uri, {
  Map<String, String>? headers,
}) async {
  final html.WebSocket socket = html.WebSocket(uri.toString());
  await socket.onOpen.first.timeout(
    Duration(milliseconds: AppConfig.socketConnectTimeoutMs),
  );
  return WebSocketTransport(socket);
}
