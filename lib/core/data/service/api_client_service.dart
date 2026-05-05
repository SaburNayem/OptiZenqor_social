import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../../config/app_config.dart';
import '../api/api_end_points.dart';
import '../shared_preference/app_shared_preferences.dart';
import '../service_model/service_response_model.dart';
import 'auth_session_service.dart';

class ApiClientService {
  ApiClientService({
    String? baseUrl,
    Dio? client,
    AppSharedPreferences? storage,
    AuthSessionService? sessionService,
  }) : baseUrl = baseUrl ?? AppConfig.currentApiBaseUrl,
       _baseUrlCandidates = baseUrl != null
           ? <String>[baseUrl.trim().replaceFirst(RegExp(r'/+$'), '')]
           : AppConfig.apiBaseUrlCandidates,
       _client = client ?? Dio(),
       _sessionService =
           sessionService ??
           AuthSessionService(storage: storage ?? AppSharedPreferences());

  static const Duration _transportFailureCooldown = Duration(seconds: 3);
  static final Map<String, DateTime> _recentTransportFailures =
      <String, DateTime>{};

  final String baseUrl;
  final List<String> _baseUrlCandidates;
  final Dio _client;
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
      final FormData formData = FormData.fromMap(<String, Object>{
        ...?fields,
        fileField: await MultipartFile.fromFile(
          filePath,
          filename: filename ?? path.basename(filePath),
        ),
      });
      final Response<dynamic> response = await _client.post<dynamic>(
        resolvedEndpoint,
        data: formData,
        options: Options(
          headers: requestHeaders,
          connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
          sendTimeout: Duration(milliseconds: AppConfig.uploadTimeoutMs),
          receiveTimeout: Duration(milliseconds: AppConfig.uploadTimeoutMs),
          validateStatus: (_) => true,
        ),
      );
      final Map<String, dynamic> responseBody = _decodeResponseBody(
        response.data,
      );
      _clearRecentTransportFailure();
      stopwatch.stop();
      _logResponse(
        method: 'POST',
        endpoint: resolvedEndpoint,
        statusCode: response.statusCode ?? 0,
        elapsedMs: stopwatch.elapsedMilliseconds,
        responseBody: responseBody,
      );

      return ServiceResponseModel<Map<String, dynamic>>(
        endpoint: resolvedEndpoint,
        statusCode: response.statusCode ?? 0,
        data: responseBody,
        message: _extractMessage(responseBody, response.statusMessage),
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
    } on DioException catch (error) {
      final int? timeoutStatus = _timeoutStatusCode(error);
      if (timeoutStatus != null) {
        final String timeoutMessage = _buildTimeoutMessage();
        _rememberRecentTransportFailure();
        _logNetworkIssue('timeout', resolvedEndpoint, timeoutMessage);
        return ServiceResponseModel<Map<String, dynamic>>(
          endpoint: resolvedEndpoint,
          statusCode: timeoutStatus,
          data: <String, dynamic>{'success': false, 'message': timeoutMessage},
          message: timeoutMessage,
        );
      }

      final String clientErrorMessage = _buildClientErrorMessage(
        error.message ?? error.toString(),
      );
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
    final List<String> candidateBaseUrls = _candidateBaseUrlsForRequest();
    final String resolvedEndpoint = _resolveEndpointForBaseUrl(
      candidateBaseUrls.first,
      endpoint,
      queryParameters: queryParameters,
    );
    final ServiceResponseModel<Map<String, dynamic>>? cooldownResponse =
        _buildCooldownResponse(resolvedEndpoint);
    if (cooldownResponse != null) {
      return cooldownResponse;
    }
    ServiceResponseModel<Map<String, dynamic>>? lastTransportFailure;

    for (int index = 0; index < candidateBaseUrls.length; index++) {
      final String candidateBaseUrl = candidateBaseUrls[index];
      final String candidateEndpoint = _resolveEndpointForBaseUrl(
        candidateBaseUrl,
        endpoint,
        queryParameters: queryParameters,
      );

      try {
        final Map<String, String> requestHeaders = await _buildHeaders(
          includeJsonContentType: method != 'GET',
          overrides: headers,
        );
        final Stopwatch stopwatch = Stopwatch()..start();

        _logRequest(
          method: method,
          endpoint: candidateEndpoint,
          headers: requestHeaders,
          payload: payload,
        );

        final Response<dynamic> response = await _client.request<dynamic>(
          candidateEndpoint,
          data: payload != null && payload.isNotEmpty ? payload : null,
          options: Options(
            method: method,
            headers: requestHeaders,
            connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
            receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeoutMs),
            sendTimeout: Duration(milliseconds: AppConfig.receiveTimeoutMs),
            validateStatus: (_) => true,
          ),
        );
        final Map<String, dynamic> responseBody = _decodeResponseBody(
          response.data,
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
          endpoint: candidateEndpoint,
          statusCode: response.statusCode ?? 0,
          elapsedMs: stopwatch.elapsedMilliseconds,
          responseBody: responseBody,
        );

        return ServiceResponseModel<Map<String, dynamic>>(
          endpoint: candidateEndpoint,
          statusCode: response.statusCode ?? 0,
          data: responseBody,
          message: _extractMessage(responseBody, response.statusMessage),
        );
      } on TimeoutException {
        final String timeoutMessage = _buildTimeoutMessage(
          attemptedBaseUrl: candidateBaseUrl,
        );
        _logNetworkIssue('timeout', candidateEndpoint, timeoutMessage);
        lastTransportFailure = ServiceResponseModel<Map<String, dynamic>>(
          endpoint: candidateEndpoint,
          statusCode: 408,
          data: <String, dynamic>{'success': false, 'message': timeoutMessage},
          message: timeoutMessage,
        );
      } on DioException catch (error) {
        final int? timeoutStatus = _timeoutStatusCode(error);
        if (timeoutStatus != null) {
          final String timeoutMessage = _buildTimeoutMessage(
            attemptedBaseUrl: candidateBaseUrl,
          );
          _logNetworkIssue('timeout', candidateEndpoint, timeoutMessage);
          lastTransportFailure = ServiceResponseModel<Map<String, dynamic>>(
            endpoint: candidateEndpoint,
            statusCode: timeoutStatus,
            data: <String, dynamic>{
              'success': false,
              'message': timeoutMessage,
            },
            message: timeoutMessage,
          );
        } else {
          final String clientErrorMessage = _buildClientErrorMessage(
            error.message ?? error.toString(),
            attemptedBaseUrl: candidateBaseUrl,
          );
          _logNetworkIssue(
            'client_error',
            candidateEndpoint,
            clientErrorMessage,
          );
          lastTransportFailure = ServiceResponseModel<Map<String, dynamic>>(
            endpoint: candidateEndpoint,
            statusCode: 503,
            data: <String, dynamic>{
              'success': false,
              'message': clientErrorMessage,
            },
            message: clientErrorMessage,
          );
        }
      } on Exception catch (error) {
        final String fallbackMessage = _buildClientErrorMessage(
          error.toString(),
          attemptedBaseUrl: candidateBaseUrl,
        );
        _logNetworkIssue(
          'unexpected_error',
          candidateEndpoint,
          fallbackMessage,
        );
        lastTransportFailure = ServiceResponseModel<Map<String, dynamic>>(
          endpoint: candidateEndpoint,
          statusCode: 503,
          data: <String, dynamic>{'success': false, 'message': fallbackMessage},
          message: fallbackMessage,
        );
      }

      if (index < candidateBaseUrls.length - 1) {
        _logFallbackAttempt(candidateBaseUrl, candidateBaseUrls[index + 1]);
      }
    }

    _rememberRecentTransportFailure();
    return lastTransportFailure ??
        ServiceResponseModel<Map<String, dynamic>>(
          endpoint: resolvedEndpoint,
          statusCode: 503,
          data: <String, dynamic>{
            'success': false,
            'message': _buildClientErrorMessage(
              'Unable to reach the server. Check your connection and try again.',
            ),
          },
          message: _buildClientErrorMessage(
            'Unable to reach the server. Check your connection and try again.',
          ),
        );
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
    try {
      final Response<dynamic> response = await _client.post<dynamic>(
        endpoint,
        data: <String, dynamic>{'refreshToken': refreshToken},
        options: Options(
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
          receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeoutMs),
          sendTimeout: Duration(milliseconds: AppConfig.receiveTimeoutMs),
          validateStatus: (_) => true,
        ),
      );
      if ((response.statusCode ?? 0) < 200 || (response.statusCode ?? 0) >= 300) {
        await _clearExpiredSession();
        return false;
      }

      final Map<String, dynamic> payload = _decodeResponseBody(response.data);
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
        debugPrint('[ApiClientService] refresh failed endpoint=$endpoint $error');
      }
      await _clearExpiredSession();
      return false;
    }
  }

  Future<void> _clearExpiredSession() async {
    await _sessionService.clear();
  }

  Map<String, dynamic> _decodeResponseBody(dynamic body) {
    if (body == null) {
      return const <String, dynamic>{};
    }
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is Map) {
      return Map<String, dynamic>.from(body);
    }
    if (body is List) {
      return <String, dynamic>{'data': body};
    }
    if (body is List<int>) {
      return _decodeTextResponse(utf8.decode(body));
    }
    if (body is String) {
      return _decodeTextResponse(body);
    }
    return <String, dynamic>{'data': body};
  }

  Map<String, dynamic> _decodeTextResponse(String rawBody) {
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

  int? _timeoutStatusCode(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 408;
      default:
        return null;
    }
  }

  String _buildTimeoutMessage({String? attemptedBaseUrl}) {
    return _appendDebugHint(
      'Request timed out. Check your connection and try again.',
      attemptedBaseUrl: attemptedBaseUrl,
    );
  }

  String _buildClientErrorMessage(String message, {String? attemptedBaseUrl}) {
    final String trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      return _appendDebugHint(
        'Unable to reach the server. Check your connection and try again.',
        attemptedBaseUrl: attemptedBaseUrl,
      );
    }
    if (kIsWeb &&
        (trimmedMessage.toLowerCase() == 'failed to fetch' ||
            trimmedMessage.toLowerCase().contains('xmlhttprequest error'))) {
      return _appendDebugHint(
        'Browser blocked the request before it reached the API. This usually means the backend CORS policy does not allow this web origin yet.',
        attemptedBaseUrl: attemptedBaseUrl,
      );
    }
    return _appendDebugHint(trimmedMessage, attemptedBaseUrl: attemptedBaseUrl);
  }

  String _buildCooldownMessage() {
    return _appendDebugHint(
      'Skipping repeated request after a recent network failure. '
      'Check your backend connection and try again.',
    );
  }

  String _appendDebugHint(String message, {String? attemptedBaseUrl}) {
    if (!kDebugMode) {
      return message;
    }

    final List<String> fallbackBaseUrls = _candidateBaseUrlsForRequest();
    final String resolvedAttempt = attemptedBaseUrl?.trim().isNotEmpty == true
        ? attemptedBaseUrl!.trim()
        : baseUrl;
    final StringBuffer buffer = StringBuffer(message)
      ..write(' Using API: ')
      ..write(resolvedAttempt)
      ..write('.');
    if (fallbackBaseUrls.length > 1) {
      buffer
        ..write(' Fallback order: ')
        ..write(fallbackBaseUrls.join(' -> '))
        ..write('.');
    }
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

  void _logFallbackAttempt(String failedBaseUrl, String nextBaseUrl) {
    if (!kDebugMode || failedBaseUrl == nextBaseUrl) {
      return;
    }

    debugPrint(
      '[ApiClientService] transport fallback failedBaseUrl=$failedBaseUrl '
      'nextBaseUrl=$nextBaseUrl',
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

  List<String> _candidateBaseUrlsForRequest() {
    final List<String> uniqueCandidates = <String>[];

    void addCandidate(String value) {
      final String normalized = value.trim().replaceFirst(RegExp(r'/+$'), '');
      if (normalized.isEmpty || uniqueCandidates.contains(normalized)) {
        return;
      }
      uniqueCandidates.add(normalized);
    }

    addCandidate(baseUrl);
    for (final String candidate in _baseUrlCandidates) {
      addCandidate(candidate);
    }
    return uniqueCandidates;
  }

  String _resolveEndpoint(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _resolveEndpointForBaseUrl(
      baseUrl,
      endpoint,
      queryParameters: queryParameters,
    );
  }

  String _resolveEndpointForBaseUrl(
    String resolvedBaseUrl,
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    final String normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';
    final Uri baseUri = Uri.parse(resolvedBaseUrl);
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
