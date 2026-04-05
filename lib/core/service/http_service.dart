import 'package:get/get.dart';

import 'http_service_model.dart';

class HttpService extends GetConnect {
  HttpService({
    String? baseUrl,
    Duration timeout = const Duration(seconds: 30),
    Map<String, String>? defaultHeaders,
  }) : _defaultHeaders = <String, String>{
         'Content-Type': 'application/json',
         'Accept': 'application/json',
         ...?defaultHeaders,
       } {
    this.baseUrl = baseUrl ?? '';
    httpClient.timeout = timeout;
    httpClient.defaultContentType = 'application/json';
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers.addAll(_defaultHeaders);
      return request;
    });
  }

  final Map<String, String> _defaultHeaders;

  Future<HttpServiceModel<T>> getRequest<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) {
    return _request<T>(
      method: 'GET',
      endpoint: endpoint,
      query: query,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<HttpServiceModel<T>> postRequest<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) {
    return _request<T>(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      query: query,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<HttpServiceModel<T>> putRequest<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) {
    return _request<T>(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      query: query,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<HttpServiceModel<T>> patchRequest<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) {
    return _request<T>(
      method: 'PATCH',
      endpoint: endpoint,
      body: body,
      query: query,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<HttpServiceModel<T>> deleteRequest<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) {
    return _request<T>(
      method: 'DELETE',
      endpoint: endpoint,
      body: body,
      query: query,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<HttpServiceModel<T>> _request<T>({
    required String method,
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) async {
    try {
      final mergedHeaders = <String, String>{..._defaultHeaders, ...?headers};
      late final Response<dynamic> response;

      switch (method) {
        case 'GET':
          response = await get(endpoint, query: query, headers: mergedHeaders);
        case 'POST':
          response = await post(
            endpoint,
            body,
            query: query,
            headers: mergedHeaders,
          );
        case 'PUT':
          response = await put(
            endpoint,
            body,
            query: query,
            headers: mergedHeaders,
          );
        case 'PATCH':
          response = await patch(
            endpoint,
            body,
            query: query,
            headers: mergedHeaders,
          );
        case 'DELETE':
          response = await delete(
            endpoint,
            query: query,
            headers: mergedHeaders,
          );
        default:
          return HttpServiceModel<T>(
            endpoint: endpoint,
            method: method,
            statusCode: 400,
            message: 'Unsupported HTTP method: $method',
          );
      }

      return _mapResponse(
        response,
        method: method,
        endpoint: endpoint,
        decoder: decoder,
      );
    } catch (error) {
      return HttpServiceModel<T>(
        endpoint: endpoint,
        method: method,
        statusCode: 500,
        message: error.toString(),
      );
    }
  }

  HttpServiceModel<T> _mapResponse<T>(
    Response<dynamic> response, {
    required String method,
    required String endpoint,
    HttpDataDecoder<T>? decoder,
  }) {
    final rawData = response.body;
    final parsedData = decoder != null ? decoder(rawData) : rawData as T?;

    return HttpServiceModel<T>(
      endpoint: endpoint,
      method: method,
      statusCode: response.statusCode ?? 0,
      message: _resolveMessage(response),
      data: parsedData,
      rawData: rawData,
      headers: _flattenHeaders(response.headers),
    );
  }

  String _resolveMessage(Response<dynamic> response) {
    final body = response.body;
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    final statusText = response.statusText;
    if (statusText != null && statusText.isNotEmpty) {
      return statusText;
    }

    return response.isOk ? 'Request completed successfully' : 'Request failed';
  }

  Map<String, String> _flattenHeaders(dynamic headers) {
    if (headers == null) {
      return <String, String>{};
    }

    if (headers is Map<String, String>) {
      return headers;
    }

    if (headers is Map) {
      return headers.map<String, String>(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    final flat = <String, String>{};
    for (final entry in headers.entries) {
      final value = entry.value;
      if (value is Iterable) {
        flat[entry.key.toString()] = value.join(', ');
      } else {
        flat[entry.key.toString()] = value.toString();
      }
    }
    return flat;
  }
}
