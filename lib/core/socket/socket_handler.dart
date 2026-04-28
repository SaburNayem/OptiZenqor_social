import 'dart:convert';

import 'socket_event.dart';

class SocketEnvelope {
  const SocketEnvelope({
    required this.event,
    required this.data,
    required this.receivedAt,
  });

  final String event;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
}

class SocketHandler {
  const SocketHandler();

  SocketEnvelope? parse(dynamic raw) {
    final Map<String, dynamic>? payload = _readMap(raw);
    if (payload == null || payload.isEmpty) {
      return null;
    }
    final String event = SocketEvent.normalize(
      (payload['event'] ?? payload['type'] ?? payload['name'] ?? '').toString(),
    );
    final Map<String, dynamic> data =
        _readMap(payload['data']) ??
        _readMap(payload['payload']) ??
        payload;
    return SocketEnvelope(
      event: event,
      data: data,
      receivedAt: DateTime.now(),
    );
  }

  Map<String, dynamic>? _readMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } on FormatException {
        return <String, dynamic>{'event': SocketEvent.message, 'data': raw};
      }
    }
    return null;
  }
}
