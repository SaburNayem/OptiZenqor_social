import 'http_service_model.dart';

class HttpService {
  HttpService({
    String? baseUrl,
    Duration timeout = const Duration(seconds: 30),
    Map<String, String>? defaultHeaders,
  }) : _baseUrl = baseUrl ?? '',
       _timeout = timeout,
       _defaultHeaders = <String, String>{
         'Content-Type': 'application/json',
         'Accept': 'application/json',
         ...?defaultHeaders,
       };

  final String _baseUrl;
  final Duration _timeout;
  final Map<String, String> _defaultHeaders;

  Future<HttpServiceModel<T>> getRequest<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) {
    return _unsupported<T>('GET', endpoint, headers: headers);
  }

  Future<HttpServiceModel<T>> postRequest<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) {
    return _unsupported<T>('POST', endpoint, headers: headers);
  }

  Future<HttpServiceModel<T>> putRequest<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) {
    return _unsupported<T>('PUT', endpoint, headers: headers);
  }

  Future<HttpServiceModel<T>> patchRequest<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) {
    return _unsupported<T>('PATCH', endpoint, headers: headers);
  }

  Future<HttpServiceModel<T>> deleteRequest<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    HttpDataDecoder<T>? decoder,
  }) {
    return _unsupported<T>('DELETE', endpoint, headers: headers);
  }

  Future<HttpServiceModel<T>> _unsupported<T>(
    String method,
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return HttpServiceModel<T>(
      endpoint: endpoint,
      method: method,
      statusCode: 501,
      message:
          'HTTP service is not configured yet after the GetX migration. baseUrl=$_baseUrl timeout=${_timeout.inSeconds}s',
      headers: <String, String>{..._defaultHeaders, ...?headers},
    );
  }
}
