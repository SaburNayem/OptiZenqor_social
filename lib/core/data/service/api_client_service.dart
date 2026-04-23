import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../../config/app_config.dart';
import '../../constants/storage_keys.dart';
import '../shared_preference/app_shared_preferences.dart';
import '../service_model/service_response_model.dart';

class ApiClientService {
  ApiClientService({
    String? baseUrl,
    http.Client? client,
    AppSharedPreferences? storage,
  }) : baseUrl = baseUrl ?? AppConfig.currentApiBaseUrl,
       _client = client ?? http.Client(),
       _storage = storage ?? AppSharedPreferences();

  static const Duration _transportFailureCooldown = Duration(seconds: 3);
  static final Map<String, DateTime> _recentTransportFailures =
      <String, DateTime>{};

  final String baseUrl;
  final http.Client _client;
  final AppSharedPreferences _storage;

  Future<ServiceResponseModel<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _send(
      method: 'GET',
      endpoint: endpoint,
      queryParameters: queryParameters,
    );
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    return _send(method: 'POST', endpoint: endpoint, payload: payload);
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> postMultipart(
    String endpoint, {
    required String fileField,
    required String filePath,
    Map<String, String>? fields,
    String? filename,
  }) async {
    final String resolvedEndpoint = _resolveEndpoint(endpoint);
    final ServiceResponseModel<Map<String, dynamic>>? cooldownResponse =
        _buildCooldownResponse(resolvedEndpoint);
    if (cooldownResponse != null) {
      return cooldownResponse;
    }
    final Uri uri = Uri.parse(resolvedEndpoint);
    final Stopwatch stopwatch = Stopwatch()..start();
    final Map<String, String> headers = await _buildHeaders(
      includeJsonContentType: false,
    );
    _logRequest(
      method: 'POST',
      endpoint: resolvedEndpoint,
      headers: headers,
      payload: <String, dynamic>{
        'multipart': true,
        'fileField': fileField,
        'fileName': filename ?? path.basename(filePath),
        'fields': fields ?? const <String, String>{},
      },
    );

    try {
      final http.MultipartRequest request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..fields.addAll(fields ?? const <String, String>{})
        ..files.add(
          await http.MultipartFile.fromPath(
            fileField,
            filePath,
            filename: filename ?? path.basename(filePath),
          ),
        );

      final http.StreamedResponse streamedResponse = await _client
          .send(request)
          .timeout(Duration(milliseconds: AppConfig.uploadTimeoutMs));
      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );
      final Map<String, dynamic> responseBody = _decodeResponseBody(
        response.bodyBytes,
      );
      _clearRecentTransportFailure();
      stopwatch.stop();
      _logResponse(
        method: 'POST',
        endpoint: resolvedEndpoint,
        statusCode: response.statusCode,
        elapsedMs: stopwatch.elapsedMilliseconds,
        responseBody: responseBody,
      );

      return ServiceResponseModel<Map<String, dynamic>>(
        endpoint: resolvedEndpoint,
        statusCode: response.statusCode,
        data: responseBody,
        message: _extractMessage(responseBody, response.reasonPhrase),
      );
    } on TimeoutException {
      final String timeoutMessage = _buildTimeoutMessage();
      _rememberRecentTransportFailure();
      _logNetworkIssue('timeout', resolvedEndpoint, timeoutMessage);
      return ServiceResponseModel<Map<String, dynamic>>(
        endpoint: resolvedEndpoint,
        statusCode: 408,
        data: <String, dynamic>{'success': false, 'message': timeoutMessage},
        message: timeoutMessage,
      );
    } on http.ClientException catch (error) {
      final String clientErrorMessage = _buildClientErrorMessage(error.message);
      _rememberRecentTransportFailure();
      _logNetworkIssue('client_error', resolvedEndpoint, clientErrorMessage);
      return ServiceResponseModel<Map<String, dynamic>>(
        endpoint: resolvedEndpoint,
        statusCode: 503,
        data: <String, dynamic>{
          'success': false,
          'message': clientErrorMessage,
        },
        message: clientErrorMessage,
      );
    } on Exception catch (error) {
      return ServiceResponseModel<Map<String, dynamic>>(
        endpoint: resolvedEndpoint,
        statusCode: 400,
        data: <String, dynamic>{'success': false, 'message': error.toString()},
        message: error.toString(),
      );
    }
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> patch(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    return _send(method: 'PATCH', endpoint: endpoint, payload: payload);
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> delete(
    String endpoint, {
    Map<String, dynamic>? payload,
  }) async {
    return _send(method: 'DELETE', endpoint: endpoint, payload: payload);
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> _send({
    required String method,
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? payload,
  }) async {
    final String resolvedEndpoint = _resolveEndpoint(
      endpoint,
      queryParameters: queryParameters,
    );
    final ServiceResponseModel<Map<String, dynamic>>? cooldownResponse =
        _buildCooldownResponse(resolvedEndpoint);
    if (cooldownResponse != null) {
      return cooldownResponse;
    }
    final Uri uri = Uri.parse(resolvedEndpoint);

    try {
      final http.Request request = http.Request(method, uri)
        ..headers.addAll(
          await _buildHeaders(includeJsonContentType: method != 'GET'),
        );
      final Stopwatch stopwatch = Stopwatch()..start();

      if (payload != null && payload.isNotEmpty) {
        request.body = jsonEncode(payload);
      }
      _logRequest(
        method: method,
        endpoint: resolvedEndpoint,
        headers: request.headers,
        payload: payload,
      );

      final http.StreamedResponse streamedResponse = await _client
          .send(request)
          .timeout(Duration(milliseconds: AppConfig.receiveTimeoutMs));
      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );
      final Map<String, dynamic> responseBody = _decodeResponseBody(
        response.bodyBytes,
      );
      _clearRecentTransportFailure();
      stopwatch.stop();
      _logResponse(
        method: method,
        endpoint: resolvedEndpoint,
        statusCode: response.statusCode,
        elapsedMs: stopwatch.elapsedMilliseconds,
        responseBody: responseBody,
      );

      return ServiceResponseModel<Map<String, dynamic>>(
        endpoint: resolvedEndpoint,
        statusCode: response.statusCode,
        data: responseBody,
        message: _extractMessage(responseBody, response.reasonPhrase),
      );
    } on TimeoutException {
      final String timeoutMessage = _buildTimeoutMessage();
      _rememberRecentTransportFailure();
      _logNetworkIssue('timeout', resolvedEndpoint, timeoutMessage);
      return ServiceResponseModel<Map<String, dynamic>>(
        endpoint: resolvedEndpoint,
        statusCode: 408,
        data: <String, dynamic>{'success': false, 'message': timeoutMessage},
        message: timeoutMessage,
      );
    } on http.ClientException catch (error) {
      final String clientErrorMessage = _buildClientErrorMessage(error.message);
      _rememberRecentTransportFailure();
      _logNetworkIssue('client_error', resolvedEndpoint, clientErrorMessage);
      return ServiceResponseModel<Map<String, dynamic>>(
        endpoint: resolvedEndpoint,
        statusCode: 503,
        data: <String, dynamic>{
          'success': false,
          'message': clientErrorMessage,
        },
        message: clientErrorMessage,
      );
    }
  }

  Future<Map<String, String>> _buildHeaders({
    required bool includeJsonContentType,
  }) async {
    final Map<String, dynamic>? authSession = await _storage.readJson(
      StorageKeys.authSession,
    );
    final String? accessToken = authSession?['accessToken'] as String?;
    final String tokenType = authSession?['tokenType'] as String? ?? 'Bearer';

    return <String, String>{
      'Accept': 'application/json',
      if (includeJsonContentType) 'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': '$tokenType $accessToken',
    };
  }

  Map<String, dynamic> _decodeResponseBody(List<int> bodyBytes) {
    if (bodyBytes.isEmpty) {
      return const <String, dynamic>{};
    }

    final String rawBody = utf8.decode(bodyBytes);
    if (rawBody.trim().isEmpty) {
      return const <String, dynamic>{};
    }

    try {
      final dynamic decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      if (decoded is List) {
        return <String, dynamic>{'data': decoded};
      }
      return <String, dynamic>{'data': decoded};
    } on FormatException {
      return <String, dynamic>{'raw': rawBody};
    }
  }

  String? _extractMessage(Map<String, dynamic> responseBody, String? fallback) {
    final dynamic message = responseBody['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    return fallback;
  }

  String _buildTimeoutMessage() {
    return _appendDebugHint(
      'Request timed out. Check your connection and try again.',
    );
  }

  String _buildClientErrorMessage(String message) {
    final String trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      return _appendDebugHint(
        'Unable to reach the server. Check your connection and try again.',
      );
    }
    return _appendDebugHint(trimmedMessage);
  }

  String _buildCooldownMessage() {
    return _appendDebugHint(
      'Skipping repeated request after a recent network failure. '
      'Check your backend connection and try again.',
    );
  }

  String _appendDebugHint(String message) {
    if (!kDebugMode) {
      return message;
    }

    final StringBuffer buffer = StringBuffer(message)
      ..write(' Using API: ')
      ..write(baseUrl)
      ..write('.');
    final String? hint = AppConfig.debugLocalNetworkHint;
    if (hint != null) {
      buffer
        ..write(' ')
        ..write(hint);
    }
    return buffer.toString();
  }

  void _logNetworkIssue(String type, String endpoint, String message) {
    if (!kDebugMode) {
      return;
    }

    debugPrint(
      '[ApiClientService] $type baseUrl=$baseUrl endpoint=$endpoint '
      'message=$message',
    );
  }

  ServiceResponseModel<Map<String, dynamic>>? _buildCooldownResponse(
    String endpoint,
  ) {
    final DateTime? lastFailureAt = _recentTransportFailures[_transportKey];
    if (lastFailureAt == null) {
      return null;
    }

    final Duration elapsed = DateTime.now().difference(lastFailureAt);
    if (elapsed >= _transportFailureCooldown) {
      _recentTransportFailures.remove(_transportKey);
      return null;
    }

    final String message = _buildCooldownMessage();
    _logNetworkIssue('cooldown_skip', endpoint, message);
    return ServiceResponseModel<Map<String, dynamic>>(
      endpoint: endpoint,
      statusCode: 503,
      data: <String, dynamic>{'success': false, 'message': message},
      message: message,
    );
  }

  void _rememberRecentTransportFailure() {
    _recentTransportFailures[_transportKey] = DateTime.now();
  }

  void _clearRecentTransportFailure() {
    _recentTransportFailures.remove(_transportKey);
  }

  String get _transportKey => baseUrl.trim();

  void _logRequest({
    required String method,
    required String endpoint,
    required Map<String, String> headers,
    Object? payload,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint(
      '[ApiRequest] method=$method endpoint=$endpoint '
      'headers=${_encodeForLog(_sanitizeValue(headers))} '
      'payload=${_encodeForLog(_sanitizeValue(payload))}',
    );
  }

  void _logResponse({
    required String method,
    required String endpoint,
    required int statusCode,
    required int elapsedMs,
    required Object? responseBody,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint(
      '[ApiResponse] method=$method endpoint=$endpoint '
      'status=$statusCode elapsedMs=$elapsedMs '
      'body=${_encodeForLog(_sanitizeValue(responseBody))}',
    );
  }

  Object? _sanitizeValue(Object? value, {String? keyHint}) {
    if (value == null) {
      return null;
    }
    if (value is Map) {
      return value.map<String, Object?>((dynamic key, dynamic nestedValue) {
        final String keyText = key.toString();
        return MapEntry(keyText, _sanitizeValue(nestedValue, keyHint: keyText));
      });
    }
    if (value is List) {
      return value
          .map<Object?>((Object? item) => _sanitizeValue(item))
          .toList(growable: false);
    }
    if (value is String) {
      final String loweredKey = keyHint?.toLowerCase() ?? '';
      if (_shouldRedact(loweredKey)) {
        return '[redacted]';
      }
      return _truncateForLog(value);
    }
    return value;
  }

  bool _shouldRedact(String key) {
    return key.contains('authorization') ||
        key.contains('token') ||
        key.contains('password') ||
        key.contains('secret') ||
        key == 'code';
  }

  String _encodeForLog(Object? value) {
    try {
      return _truncateForLog(jsonEncode(value));
    } on Object {
      return _truncateForLog(value.toString());
    }
  }

  String _truncateForLog(String value) {
    const int maxLength = 900;
    final String normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= maxLength) {
      return normalized;
    }
    return '${normalized.substring(0, maxLength)}...';
  }

  String _resolveEndpoint(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    final String normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';
    final Uri baseUri = Uri.parse(baseUrl);
    final Uri resolvedUri = baseUri.replace(
      path: _joinPaths(baseUri.path, normalizedEndpoint),
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
    return resolvedUri.toString();
  }

  String _joinPaths(String basePath, String endpoint) {
    final String normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    if (normalizedBase.isEmpty) {
      return endpoint;
    }
    return '$normalizedBase$endpoint';
  }
}
