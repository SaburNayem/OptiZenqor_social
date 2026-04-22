import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

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
    final Uri uri = Uri.parse(resolvedEndpoint);

    try {
      final http.Request request = http.Request(method, uri)
        ..headers.addAll(
          await _buildHeaders(includeJsonContentType: method != 'GET'),
        );

      if (payload != null && payload.isNotEmpty) {
        request.body = jsonEncode(payload);
      }

      final http.StreamedResponse streamedResponse = await _client
          .send(request)
          .timeout(Duration(milliseconds: AppConfig.receiveTimeoutMs));
      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );
      final Map<String, dynamic> responseBody = _decodeResponseBody(
        response.bodyBytes,
      );

      return ServiceResponseModel<Map<String, dynamic>>(
        endpoint: resolvedEndpoint,
        statusCode: response.statusCode,
        data: responseBody,
        message: _extractMessage(responseBody, response.reasonPhrase),
      );
    } on TimeoutException {
      return ServiceResponseModel<Map<String, dynamic>>(
        endpoint: resolvedEndpoint,
        statusCode: 408,
        data: <String, dynamic>{
          'success': false,
          'message': 'Request timed out.',
        },
        message: 'Request timed out.',
      );
    } on http.ClientException catch (error) {
      return ServiceResponseModel<Map<String, dynamic>>(
        endpoint: resolvedEndpoint,
        statusCode: 503,
        data: <String, dynamic>{'success': false, 'message': error.message},
        message: error.message,
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
