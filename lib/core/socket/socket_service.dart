import 'dart:async';

import 'package:flutter/foundation.dart';
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
  Future<bool>? _pendingConnection;
  bool _manualDisconnect = false;
  int _reconnectAttempts = 0;
  DateTime? _nextConnectAttemptAt;
  String _socketPath = AppConfig.socketPath;

  static const Duration _connectFailureCooldown = Duration(seconds: 30);

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
    final io.Socket? activeSocket = _socket;
    if (activeSocket != null &&
        activeSocket.connected &&
        _state == SocketConnectionState.connected) {
      return true;
    }
    final DateTime? nextAttemptAt = _nextConnectAttemptAt;
    if (nextAttemptAt != null && DateTime.now().isBefore(nextAttemptAt)) {
      return false;
    }
    final Future<bool>? pendingConnection = _pendingConnection;
    if (pendingConnection != null) {
      return pendingConnection;
    }

    final Future<bool> connection = _connectInternal();
    _pendingConnection = connection;
    try {
      return await connection;
    } finally {
      if (identical(_pendingConnection, connection)) {
        _pendingConnection = null;
      }
    }
  }

  Future<bool> _connectInternal() async {
    if (_state == SocketConnectionState.connecting ||
        _state == SocketConnectionState.reconnecting) {
      return _socket?.connected ?? false;
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
    final String socketEndpoint = target.uri
        .replace(path: _joinSocketPaths(target.uri.path, target.namespace))
        .toString();

    _log(
      'connect.start endpoint=$socketEndpoint path=${target.path} hasToken=${accessToken.isNotEmpty} userId=$currentUserId',
    );

    try {
      await _closeTransport();

      final io.OptionBuilder options = io.OptionBuilder()
          .setTransports(
            kIsWeb ? <String>['polling', 'websocket'] : <String>['websocket'],
          )
          .disableAutoConnect()
          .disableReconnection()
          .setTimeout(AppConfig.socketConnectTimeoutMs)
          .setPath(target.path)
          .setQuery(<String, dynamic>{
            if (accessToken.isNotEmpty) 'token': accessToken,
          })
          .setAuth(<String, dynamic>{
            if (accessToken.isNotEmpty) 'token': accessToken,
            if (currentUserId.isNotEmpty) 'userId': currentUserId,
          })
          .setExtraHeaders(<String, dynamic>{
            if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
          });

      final io.Socket socket = io.io(socketEndpoint, options.build());
      _socket = socket;
      _socketPath = target.path;
      socket.onConnect((_) {
        if (!identical(_socket, socket)) {
          return;
        }
        _reconnectAttempts = 0;
        _setState(SocketConnectionState.connected);
        _log('connect.success endpoint=$socketEndpoint path=$_socketPath');
        _eventsController.add(
          SocketEnvelope(
            event: SocketEvent.connected,
            data: <String, dynamic>{'uri': socketEndpoint, 'path': _socketPath},
            receivedAt: DateTime.now(),
          ),
        );
      });

      socket.onDisconnect((dynamic reason) {
        if (!identical(_socket, socket)) {
          return;
        }
        _log(
          'disconnect reason=${reason?.toString() ?? 'unknown'} manual=$_manualDisconnect',
        );
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
        if (!identical(_socket, socket)) {
          return;
        }
        final String message = _socketErrorMessage(error);
        _log('connect.error endpoint=$socketEndpoint error=$message');
        _rememberConnectFailure(message);
        _setState(SocketConnectionState.error);
        _eventsController.add(
          SocketEnvelope(
            event: SocketEvent.error,
            data: <String, dynamic>{'message': message},
            receivedAt: DateTime.now(),
          ),
        );
      });

      socket.onError((dynamic error) {
        if (!identical(_socket, socket)) {
          return;
        }
        final String message = _socketErrorMessage(error);
        _log('socket.error endpoint=$socketEndpoint error=$message');
        _rememberConnectFailure(message);
        _setState(SocketConnectionState.error);
        _eventsController.add(
          SocketEnvelope(
            event: SocketEvent.error,
            data: <String, dynamic>{'message': message},
            receivedAt: DateTime.now(),
          ),
        );
      });

      socket.onAny((String event, dynamic payload) {
        if (!identical(_socket, socket)) {
          return;
        }
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
      _nextConnectAttemptAt = null;
      _log('connect.completed connected=${socket.connected} state=$_state');
      return isConnected;
    } on Object catch (error) {
      final String message = _socketErrorMessage(error);
      _log('connect.failed endpoint=$socketEndpoint error=$message');
      _rememberConnectFailure(message);
      await _closeTransport();
      _setState(SocketConnectionState.error);
      _eventsController.add(
        SocketEnvelope(
          event: SocketEvent.error,
          data: <String, dynamic>{'message': message},
          receivedAt: DateTime.now(),
        ),
      );
      return false;
    }
  }

  Future<void> disconnect({bool manual = true}) async {
    _manualDisconnect = manual;
    _reconnectAttempts = 0;
    _pendingConnection = null;
    _nextConnectAttemptAt = null;
    await _closeTransport();
    _setState(SocketConnectionState.disconnected);
  }

  Future<void> send(String event, {Map<String, dynamic>? data}) async {
    io.Socket? socket = _socket;
    if (socket == null || !socket.connected || !isConnected) {
      _log(
        'send.wait event=$event connected=${socket?.connected ?? false} state=$_state',
      );
      final bool connected = await connect();
      socket = _socket;
      if (!connected || socket == null || !socket.connected || !isConnected) {
        _log('send.failed event=$event state=$_state');
        throw StateError('Socket is not connected.');
      }
    }
    if (!identical(socket, _socket)) {
      socket = _socket;
    }
    if (socket == null || !socket.connected) {
      _log('send.failed event=$event socketMissing=true state=$_state');
      throw StateError('Socket is not connected.');
    }
    _log(
      'send.emit event=$event keys=${(data ?? const <String, dynamic>{}).keys.join(',')}',
    );
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

  Future<({Uri uri, String path, String namespace})>
  _resolveSocketTarget() async {
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
      queryParameters: null,
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

  String _joinSocketPaths(String basePath, String nextPath) {
    final String normalizedBase = basePath.trim();
    final String normalizedNext = nextPath.trim();
    if (normalizedBase.isEmpty || normalizedBase == '/') {
      return normalizedNext.startsWith('/')
          ? normalizedNext
          : '/$normalizedNext';
    }
    if (normalizedNext.isEmpty || normalizedNext == '/') {
      return normalizedBase.startsWith('/')
          ? normalizedBase
          : '/$normalizedBase';
    }
    final String left = normalizedBase.endsWith('/')
        ? normalizedBase.substring(0, normalizedBase.length - 1)
        : normalizedBase;
    final String right = normalizedNext.startsWith('/')
        ? normalizedNext
        : '/$normalizedNext';
    return '$left$right';
  }

  void _setState(SocketConnectionState next) {
    if (_state == next) {
      return;
    }
    _state = next;
    _log('state=$next');
    _stateController.add(next);
  }

  void _log(String message) {
    debugPrint('[SocketService] $message');
  }

  void _rememberConnectFailure(String _) {
    _nextConnectAttemptAt = DateTime.now().add(_connectFailureCooldown);
  }

  String _socketErrorMessage(Object? error) {
    final String raw = (error ?? '').toString();
    final String withoutToken = raw.replaceAll(
      RegExp(r"""token=[^&#\s'"]+"""),
      'token=[redacted]',
    );
    final String withoutAuthorization = withoutToken.replaceAll(
      RegExp(
        r"""Authorization(?:%3A|:)\s*Bearer\s+[^,}\s'"]+""",
        caseSensitive: false,
      ),
      'Authorization: Bearer [redacted]',
    );
    return withoutAuthorization;
  }
}
