import '../../config/app_config.dart';
import '../service_model/service_response_model.dart';

class ApiClientService {
  const ApiClientService({this.baseUrl = AppConfig.apiBaseUrl});

  final String baseUrl;

  Future<ServiceResponseModel<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return ServiceResponseModel<Map<String, dynamic>>(
      endpoint: _resolveEndpoint(endpoint, queryParameters: queryParameters),
      statusCode: 200,
      data: <String, dynamic>{
        'status': 'stubbed',
        'method': 'GET',
        'queryParameters': queryParameters ?? const <String, dynamic>{},
      },
    );
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return ServiceResponseModel<Map<String, dynamic>>(
      endpoint: _resolveEndpoint(endpoint),
      statusCode: 200,
      data: <String, dynamic>{
        'status': 'stubbed',
        'method': 'POST',
        'payload': payload,
      },
    );
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> patch(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return ServiceResponseModel<Map<String, dynamic>>(
      endpoint: _resolveEndpoint(endpoint),
      statusCode: 200,
      data: <String, dynamic>{
        'status': 'stubbed',
        'method': 'PATCH',
        'payload': payload,
      },
    );
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> delete(
    String endpoint, {
    Map<String, dynamic>? payload,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return ServiceResponseModel<Map<String, dynamic>>(
      endpoint: _resolveEndpoint(endpoint),
      statusCode: 200,
      data: <String, dynamic>{
        'status': 'stubbed',
        'method': 'DELETE',
        'payload': payload ?? const <String, dynamic>{},
      },
    );
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
