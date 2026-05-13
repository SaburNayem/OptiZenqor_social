import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/app_config.dart';
import '../data/service/api_client_service.dart';
import '../data/service/auth_session_service.dart';
import 'socket_event.dart';
import 'socket_handler.dart';

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

  io.Socket? _socket;
  bool _manualDisconnect = false;
  int _reconnectAttempts = 0;
  String _socketPath = AppConfig.socketPath;

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
  Stream<SocketEnvelope> get callEvents => events.where(
    (SocketEnvelope item) =>
        item.event == 'call.session.created' ||
        item.event == 'call.participant.joined' ||
        item.event == 'call.participant.left' ||
        item.event == 'call.signal' ||
        item.event == 'call.ended',
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

    final ({Uri uri, String path, String namespace}) target =
        await _resolveSocketTarget();
    final session = await _sessionService.readSession();
    final String accessToken = session?.accessToken ?? '';
    final String currentUserId = session?.user?.id ?? '';

    try {
      await _closeTransport();

      final io.OptionBuilder options = io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .disableAutoConnect()
          .setPath(target.path)
          .setAuth(<String, dynamic>{
            if (accessToken.isNotEmpty) 'token': accessToken,
            if (currentUserId.isNotEmpty) 'userId': currentUserId,
          })
          .setExtraHeaders(<String, dynamic>{
            if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
          });

      final io.Socket socket = io.io(
        '${target.uri.toString()}${target.namespace}',
        options.build(),
      );
      _socket = socket;
      _socketPath = target.path;
      socket.onConnect((_) {
        _reconnectAttempts = 0;
        _setState(SocketConnectionState.connected);
        _eventsController.add(
          SocketEnvelope(
            event: SocketEvent.connected,
            data: <String, dynamic>{
              'uri': '${target.uri}${target.namespace}',
              'path': _socketPath,
            },
            receivedAt: DateTime.now(),
          ),
        );
      });

      socket.onDisconnect((dynamic reason) {
        _eventsController.add(
          SocketEnvelope(
            event: SocketEvent.disconnect,
            data: <String, dynamic>{'reason': reason?.toString() ?? ''},
            receivedAt: DateTime.now(),
          ),
        );
        if (_manualDisconnect) {
          _setState(SocketConnectionState.disconnected);
          return;
        }
        _setState(SocketConnectionState.disconnected);
      });

      socket.onConnectError((dynamic error) {
        _setState(SocketConnectionState.error);
        _eventsController.add(
          SocketEnvelope(
            event: SocketEvent.error,
            data: <String, dynamic>{'message': error.toString()},
            receivedAt: DateTime.now(),
          ),
        );
      });

      socket.onError((dynamic error) {
        _setState(SocketConnectionState.error);
        _eventsController.add(
          SocketEnvelope(
            event: SocketEvent.error,
            data: <String, dynamic>{'message': error.toString()},
            receivedAt: DateTime.now(),
          ),
        );
      });

      socket.onAny((String event, dynamic payload) {
        final Map<String, dynamic> eventPayload = _toEventPayload(
          event,
          payload,
        );
        final SocketEnvelope? envelope = _handler.parse(eventPayload);
        if (envelope != null) {
          _eventsController.add(envelope);
        }
      });

      socket.connect();
      await _waitForConnection(socket);
      return isConnected;
    } on Object catch (error) {
      _setState(SocketConnectionState.error);
      _eventsController.add(
        SocketEnvelope(
          event: SocketEvent.error,
          data: <String, dynamic>{'message': error.toString()},
          receivedAt: DateTime.now(),
        ),
      );
      return false;
    }
  }

  Future<void> disconnect({bool manual = true}) async {
    _manualDisconnect = manual;
    _reconnectAttempts = 0;
    await _closeTransport();
    _setState(SocketConnectionState.disconnected);
  }

  Future<void> send(String event, {Map<String, dynamic>? data}) async {
    final io.Socket? socket = _socket;
    if (socket == null || !isConnected) {
      throw StateError('Socket is not connected.');
    }
    socket.emit(event, data ?? const <String, dynamic>{});
  }

  Future<void> _closeTransport() async {
    final io.Socket? socket = _socket;
    _socket = null;
    if (socket == null) {
      return;
    }
    socket.dispose();
    socket.disconnect();
  }

  Future<void> _waitForConnection(io.Socket socket) async {
    if (socket.connected) {
      return;
    }
    final Completer<void> completer = Completer<void>();
    late void Function(dynamic) onConnect;
    late void Function(dynamic) onError;
    onConnect = (_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    };
    onError = (dynamic error) {
      if (!completer.isCompleted) {
        completer.completeError(StateError(error.toString()));
      }
    };
    socket.once('connect', onConnect);
    socket.once('connect_error', onError);
    await completer.future.timeout(
      Duration(milliseconds: AppConfig.socketConnectTimeoutMs),
    );
  }

  Future<({Uri uri, String path, String namespace})> _resolveSocketTarget() async {
    final session = await _sessionService.readSession();
    final String accessToken = session?.accessToken ?? '';
    String namespace = '/realtime';
    String path = AppConfig.socketPath;
    Uri baseUri = Uri.parse(AppConfig.currentApiBaseUrl);

    try {
      final response = await _apiClient.get(AppConfig.socketContractPath);
      final Map<String, dynamic> payload =
          _readMap(response.data['data']) ??
          _readMap(response.data['result']) ??
          response.data;
      final String contractNamespace = _firstString(payload, <String>[
        'namespace',
      ]);
      if (contractNamespace.isNotEmpty) {
        namespace = contractNamespace;
      }
      final String contractPath = _firstString(payload, <String>[
        'path',
        'socketPath',
      ]);
      if (contractPath.isNotEmpty) {
        path = contractPath;
      }
      final String contractUrl = _firstString(payload, <String>[
        'url',
        'socketUrl',
        'endpoint',
      ]);
      if (contractUrl.isNotEmpty) {
        baseUri = Uri.parse(contractUrl);
      }
    } catch (_) {
      // Fall back to app config defaults.
    }

    final Uri uri = baseUri.replace(
      scheme: baseUri.scheme == 'https' ? 'https' : 'http',
      path: '',
      queryParameters: <String, String>{
        if (accessToken.isNotEmpty) 'token': accessToken,
      },
    );
    return (uri: uri, path: path, namespace: namespace);
  }

  Map<String, dynamic> _toEventPayload(String event, dynamic payload) {
    final Map<String, dynamic>? data = _readMap(payload);
    if (data != null) {
      return <String, dynamic>{'event': event, 'data': data};
    }
    return <String, dynamic>{
      'event': event,
      'data': <String, dynamic>{'value': payload},
    };
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

  String _firstString(Map<String, dynamic> payload, List<String> keys) {
    for (final String key in keys) {
      final String value = (payload[key] as String? ?? '').trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  void _setState(SocketConnectionState next) {
    if (_state == next) {
      return;
    }
    _state = next;
    _stateController.add(next);
  }
}
