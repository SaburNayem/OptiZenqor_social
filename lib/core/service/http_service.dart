import '../data/service/api_client_service.dart';
import '../data/service_model/service_response_model.dart';
import 'http_service_model.dart';

class HttpService {
  HttpService({
    String? baseUrl,
    Duration timeout = const Duration(seconds: 30),
    Map<String, String>? defaultHeaders,
    ApiClientService? apiClient,
  }) : _apiClient = apiClient ?? ApiClientService(baseUrl: baseUrl) {
    _defaultHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?defaultHeaders,
      'X-Request-Timeout': '${timeout.inMilliseconds}',
    };
  }

  final ApiClientService _apiClient;
  late final Map<String, String> _defaultHeaders;

  Future<HttpServiceModel<T>> getRequest<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) async {
    final response = await _apiClient.get(
      endpoint,
      queryParameters: query,
      headers: _mergeHeaders(headers),
    );
    return _mapResponse('GET', response, decoder: decoder);
  }

  Future<HttpServiceModel<T>> postRequest<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) async {
    final response = await _apiClient.post(
      endpoint,
      _normalizePayload(body),
      headers: _mergeHeaders(headers),
    );
    return _mapResponse('POST', response, decoder: decoder);
  }

  Future<HttpServiceModel<T>> putRequest<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) async {
    final response = await _apiClient.put(
      endpoint,
      _normalizePayload(body),
      headers: _mergeHeaders(headers),
    );
    return _mapResponse('PUT', response, decoder: decoder);
  }

  Future<HttpServiceModel<T>> patchRequest<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) async {
    final response = await _apiClient.patch(
      endpoint,
      _normalizePayload(body),
      headers: _mergeHeaders(headers),
    );
    return _mapResponse('PATCH', response, decoder: decoder);
  }

  Future<HttpServiceModel<T>> deleteRequest<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) async {
    final response = await _apiClient.delete(
      endpoint,
      payload: _normalizePayload(body),
      headers: _mergeHeaders(headers),
    );
    return _mapResponse('DELETE', response, decoder: decoder);
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return <String, String>{..._defaultHeaders, ...?headers};
  }

  Map<String, dynamic> _normalizePayload(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is Map) {
      return Map<String, dynamic>.from(body);
    }
    return body == null
        ? const <String, dynamic>{}
        : <String, dynamic>{'data': body};
  }

  HttpServiceModel<T> _mapResponse<T>(
    String method,
    ServiceResponseModel<Map<String, dynamic>> response, {
    HttpDataDecoder<T>? decoder,
  }) {
    final dynamic payload = response.data;
    T? decoded;
    if (decoder != null) {
      try {
        decoded = decoder(payload);
      } on Object {
        decoded = null;
      }
    } else if (payload is T) {
      decoded = payload;
    }

    return HttpServiceModel<T>(
      endpoint: response.endpoint,
      method: method,
      statusCode: response.statusCode,
      message: response.message ?? '',
      data: decoded,
      rawData: payload,
      headers: _defaultHeaders,
    );
  }
}
