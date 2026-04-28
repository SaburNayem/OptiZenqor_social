class SocketProperty {
  const SocketProperty._();

  static const endpointQueryKeys = <String>[
    'token',
    'accessToken',
    'authorization',
  ];
  static const reconnectDelayMs = 3000;
  static const maxReconnectAttempts = 8;
  static const pingIntervalMs = 25000;
}
