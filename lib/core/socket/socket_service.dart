import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../data/service/auth_session_service.dart';
import '../data/service/api_client_service.dart';
import 'socket_event.dart';
import 'socket_handler.dart';
import 'socket_property.dart';
import 'socket_transport.dart';

enum SocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class SocketService {
  SocketService._internal({
    AuthSessionService? sessionService,
    ApiClientService? apiClient,
    SocketHandler? handler,
  }) : _sessionService = sessionService ?? AuthSessionService(),
       _apiClient = apiClient ?? ApiClientService(),
       _handler = handler ?? const SocketHandler();

  static final SocketService instance = SocketService._internal();
  factory SocketService() => instance;

  final AuthSessionService _sessionService;
  final ApiClientService _apiClient;
  final SocketHandler _handler;

  PlatformSocketTransport? _transport;
  StreamSubscription<dynamic>? _messageSubscription;
  Timer? _reconnectTimer;
  Uri? _connectedUri;
  bool _manualDisconnect = false;
  int _reconnectAttempts = 0;

  final StreamController<SocketConnectionState> _stateController =
      StreamController<SocketConnectionState>.broadcast();
  final StreamController<SocketEnvelope> _eventsController =
      StreamController<SocketEnvelope>.broadcast();

  SocketConnectionState _state = SocketConnectionState.disconnected;

  SocketConnectionState get state => _state;
  bool get isConnected => _state == SocketConnectionState.connected;
  Stream<SocketConnectionState> get states => _stateController.stream;
  Stream<SocketEnvelope> get events => _eventsController.stream;
  Stream<SocketEnvelope> get chatEvents => events.where(
    (SocketEnvelope item) =>
        item.event == SocketEvent.chatMessage ||
        item.event == SocketEvent.chatThreadUpdated ||
        item.event == SocketEvent.chatPresence,
  );
  Stream<SocketEnvelope> get notificationEvents => events.where(
    (SocketEnvelope item) =>
        item.event == SocketEvent.notificationCreated ||
        item.event == SocketEvent.notificationUpdated,
  );

  Future<bool> connect() async {
    if (isConnected || _state == SocketConnectionState.connecting) {
      return isConnected;
    }

    _manualDisconnect = false;
    _setState(
      _reconnectAttempts > 0
          ? SocketConnectionState.reconnecting
          : SocketConnectionState.connecting,
    );

    final Uri uri = await _resolveSocketUri();
    final Map<String, String> headers = await _buildSocketHeaders();
    try {
      await _closeTransport();
      _transport = await openPlatformSocket(uri, headers: headers);
      _connectedUri = uri;
      _messageSubscription = _transport!.messages.listen(
        _handleIncomingMessage,
        onError: _handleTransportError,
        onDone: _handleTransportDone,
        cancelOnError: false,
      );
      _reconnectAttempts = 0;
      _setState(SocketConnectionState.connected);
      _eventsController.add(
        SocketEnvelope(
          event: SocketEvent.connected,
          data: <String, dynamic>{'uri': uri.toString()},
          receivedAt: DateTime.now(),
        ),
      );
      return true;
    } on Object catch (error) {
      _setState(SocketConnectionState.error);
      _eventsController.add(
        SocketEnvelope(
          event: SocketEvent.error,
          data: <String, dynamic>{'message': error.toString()},
          receivedAt: DateTime.now(),
        ),
      );
      _scheduleReconnect();
      return false;
    }
  }

  Future<void> disconnect({bool manual = true}) async {
    _manualDisconnect = manual;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    await _closeTransport();
    _setState(SocketConnectionState.disconnected);
    _eventsController.add(
      SocketEnvelope(
        event: SocketEvent.disconnect,
        data: const <String, dynamic>{},
        receivedAt: DateTime.now(),
      ),
    );
  }

  Future<void> send(String event, {Map<String, dynamic>? data}) async {
    final PlatformSocketTransport? transport = _transport;
    if (transport == null || !isConnected) {
      throw StateError('Socket is not connected.');
    }
    await transport.send(<String, dynamic>{
      'event': SocketEvent.normalize(event),
      'data': data ?? const <String, dynamic>{},
    });
  }

  Future<Uri> _resolveSocketUri() async {
    final session = await _sessionService.readSession();
    final String accessToken = session?.accessToken ?? '';
    try {
      final response = await _apiClient.get(AppConfig.socketContractPath);
      final Map<String, dynamic> payload =
          _readMap(response.data['data']) ??
          _readMap(response.data['result']) ??
          response.data;
      final String? url = _firstString(
        payload,
        const <String>['url', 'socketUrl', 'endpoint', 'socketEndpoint'],
      );
      final String? path = _firstString(
        payload,
        const <String>['path', 'socketPath'],
      );
      if (url != null && url.isNotEmpty) {
        final Uri base = Uri.parse(url);
        return _appendAuthQuery(base, accessToken: accessToken);
      }
      return _appendAuthQuery(
        AppConfig.defaultSocketUri(path: path ?? AppConfig.socketPath),
        accessToken: accessToken,
      );
    } catch (_) {
      return _appendAuthQuery(
        AppConfig.defaultSocketUri(),
        accessToken: accessToken,
      );
    }
  }

  Future<Map<String, String>> _buildSocketHeaders() async {
    final session = await _sessionService.readSession();
    final String accessToken = session?.accessToken ?? '';
    final String tokenType = session?.tokenType.isNotEmpty == true
        ? session!.tokenType
        : 'Bearer';
    return <String, String>{
      if (accessToken.isNotEmpty) 'Authorization': '$tokenType $accessToken',
    };
  }

  Future<void> _closeTransport() async {
    await _messageSubscription?.cancel();
    _messageSubscription = null;
    await _transport?.close();
    _transport = null;
  }

  void _handleIncomingMessage(dynamic raw) {
    final SocketEnvelope? envelope = _handler.parse(raw);
    if (envelope == null) {
      return;
    }
    _eventsController.add(envelope);
  }

  void _handleTransportError(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[SocketService] error uri=${_connectedUri ?? ''} $error');
      debugPrint('$stackTrace');
    }
    _setState(SocketConnectionState.error);
    _scheduleReconnect();
  }

  void _handleTransportDone() {
    if (_manualDisconnect) {
      _setState(SocketConnectionState.disconnected);
      return;
    }
    _setState(SocketConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_manualDisconnect ||
        _reconnectAttempts >= SocketProperty.maxReconnectAttempts) {
      return;
    }
    _reconnectTimer?.cancel();
    _reconnectAttempts += 1;
    _reconnectTimer = Timer(
      Duration(milliseconds: SocketProperty.reconnectDelayMs),
      () {
        connect();
      },
    );
  }

  void _setState(SocketConnectionState next) {
    if (_state == next) {
      return;
    }
    _state = next;
    _stateController.add(next);
  }

  Uri _appendAuthQuery(Uri uri, {required String accessToken}) {
    final Map<String, String> mergedQuery = <String, String>{
      ...uri.queryParameters,
    };
    if (accessToken.isNotEmpty) {
      for (final String key in SocketProperty.endpointQueryKeys) {
        mergedQuery.putIfAbsent(key, () => accessToken);
      }
    }
    return uri.replace(queryParameters: mergedQuery);
  }

  Map<String, dynamic>? _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  String? _firstString(Map<String, dynamic> payload, List<String> keys) {
    for (final String key in keys) {
      final String value = (payload[key] as String? ?? '').trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}
