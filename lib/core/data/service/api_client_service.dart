import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../../config/app_config.dart';
import '../api/api_end_points.dart';
import '../shared_preference/app_shared_preferences.dart';
import '../service_model/service_response_model.dart';
import 'auth_session_service.dart';

class ApiClientService {
  ApiClientService({
    String? baseUrl,
    http.Client? client,
    AppSharedPreferences? storage,
    AuthSessionService? sessionService,
  }) : baseUrl = baseUrl ?? AppConfig.currentApiBaseUrl,
       _client = client ?? http.Client(),
       _sessionService =
           sessionService ??
           AuthSessionService(storage: storage ?? AppSharedPreferences());

  static const Duration _transportFailureCooldown = Duration(seconds: 3);
  static final Map<String, DateTime> _recentTransportFailures =
      <String, DateTime>{};

  final String baseUrl;
  final http.Client _client;
  final AuthSessionService _sessionService;
  Future<bool>? _refreshInFlight;

  Future<ServiceResponseModel<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _send(
      method: 'GET',
      endpoint: endpoint,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> payload, {
    Map<String, String>? headers,
  }) async {
    return _send(
      method: 'POST',
      endpoint: endpoint,
      payload: payload,
      headers: headers,
    );
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> postMultipart(
    String endpoint, {
    required String fileField,
    required String filePath,
    Map<String, String>? fields,
    String? filename,
    Map<String, String>? headers,
  }) async {
    final String resolvedEndpoint = _resolveEndpoint(endpoint);
    final ServiceResponseModel<Map<String, dynamic>>? cooldownResponse =
        _buildCooldownResponse(resolvedEndpoint);
    if (cooldownResponse != null) {
      return cooldownResponse;
    }
    final Uri uri = Uri.parse(resolvedEndpoint);
    final Stopwatch stopwatch = Stopwatch()..start();
    final Map<String, String> requestHeaders = await _buildHeaders(
      includeJsonContentType: false,
      overrides: headers,
    );
    _logRequest(
      method: 'POST',
      endpoint: resolvedEndpoint,
      headers: requestHeaders,
      payload: <String, dynamic>{
        'multipart': true,
        'fileField': fileField,
        'fileName': filename ?? path.basename(filePath),
        'fields': fields ?? const <String, String>{},
      },
    );

    try {
      final http.MultipartRequest request = http.MultipartRequest('POST', uri)
        ..headers.addAll(requestHeaders)
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
    Map<String, dynamic> payload, {
    Map<String, String>? headers,
  }) async {
    return _send(
      method: 'PATCH',
      endpoint: endpoint,
      payload: payload,
      headers: headers,
    );
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> put(
    String endpoint,
    Map<String, dynamic> payload, {
    Map<String, String>? headers,
  }) async {
    return _send(
      method: 'PUT',
      endpoint: endpoint,
      payload: payload,
      headers: headers,
    );
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> delete(
    String endpoint, {
    Map<String, dynamic>? payload,
    Map<String, String>? headers,
  }) async {
    return _send(
      method: 'DELETE',
      endpoint: endpoint,
      payload: payload,
      headers: headers,
    );
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> _send({
    required String method,
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? payload,
    Map<String, String>? headers,
    bool retryOnUnauthorized = true,
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
          await _buildHeaders(
            includeJsonContentType: method != 'GET',
            overrides: headers,
          ),
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
      if (response.statusCode == 401) {
        if (retryOnUnauthorized && await _refreshAccessToken()) {
          return _send(
            method: method,
            endpoint: endpoint,
            queryParameters: queryParameters,
            payload: payload,
            headers: headers,
            retryOnUnauthorized: false,
          );
        }
        await _clearExpiredSession();
      }
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
    } on Exception catch (error) {
      final String fallbackMessage = _buildClientErrorMessage(error.toString());
      _rememberRecentTransportFailure();
      _logNetworkIssue('unexpected_error', resolvedEndpoint, fallbackMessage);
      return ServiceResponseModel<Map<String, dynamic>>(
        endpoint: resolvedEndpoint,
        statusCode: 503,
        data: <String, dynamic>{'success': false, 'message': fallbackMessage},
        message: fallbackMessage,
      );
    }
  }

  Future<Map<String, String>> _buildHeaders({
    required bool includeJsonContentType,
    Map<String, String>? overrides,
  }) async {
    final session = await _sessionService.readSession();
    final String accessToken = session?.accessToken ?? '';
    final String tokenType = session?.tokenType.isNotEmpty == true
        ? session!.tokenType
        : 'Bearer';

    return <String, String>{
      'Accept': 'application/json',
      if (includeJsonContentType) 'Content-Type': 'application/json',
      if (accessToken.isNotEmpty) 'Authorization': '$tokenType $accessToken',
      ...?overrides,
    };
  }

  Future<bool> _refreshAccessToken() async {
    final Future<bool> pendingRefresh = _refreshInFlight ?? _performRefresh();
    _refreshInFlight = pendingRefresh;
    try {
      return await pendingRefresh;
    } finally {
      if (identical(_refreshInFlight, pendingRefresh)) {
        _refreshInFlight = null;
      }
    }
  }

  Future<bool> _performRefresh() async {
    final session = await _sessionService.readSession();
    final String refreshToken = session?.refreshToken ?? '';
    if (refreshToken.isEmpty) {
      await _clearExpiredSession();
      return false;
    }

    final String endpoint = _resolveEndpoint(ApiEndPoints.authRefreshToken);
    final Uri uri = Uri.parse(endpoint);
    try {
      final http.Request request = http.Request('POST', uri)
        ..headers.addAll(<String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode(<String, dynamic>{'refreshToken': refreshToken});
      final http.StreamedResponse streamedResponse = await _client
          .send(request)
          .timeout(Duration(milliseconds: AppConfig.receiveTimeoutMs));
      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        await _clearExpiredSession();
        return false;
      }

      final Map<String, dynamic> payload = _decodeResponseBody(
        response.bodyBytes,
      );
      final Map<String, dynamic>? sessionPayload = _readMap(
        payload['data'] ?? payload['session'] ?? payload['result'] ?? payload,
      );
      final Map<String, dynamic>? tokenMap = _readMap(
        sessionPayload?['tokens'],
      );
      final String newAccessToken =
          (sessionPayload?['accessToken'] ??
                  sessionPayload?['token'] ??
                  tokenMap?['accessToken'] ??
                  '')
              .toString()
              .trim();
      if (newAccessToken.isEmpty) {
        await _clearExpiredSession();
        return false;
      }

      final String newRefreshToken =
          (sessionPayload?['refreshToken'] ??
                  tokenMap?['refreshToken'] ??
                  refreshToken)
              .toString()
              .trim();
      final String tokenType =
          (sessionPayload?['tokenType'] as String? ??
                  session?.tokenType ??
                  'Bearer')
              .trim();
      await _sessionService.updateTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        tokenType: tokenType,
      );
      return true;
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[ApiClientService] refresh failed endpoint=$endpoint $error',
        );
      }
      await _clearExpiredSession();
      return false;
    }
  }

  Future<void> _clearExpiredSession() async {
    await _sessionService.clear();
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
    if (kIsWeb && trimmedMessage.toLowerCase() == 'failed to fetch') {
      return _appendDebugHint(
        'Browser blocked the request before it reached the API. This usually means the backend CORS policy does not allow this web origin yet.',
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

  Map<String, dynamic>? _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
