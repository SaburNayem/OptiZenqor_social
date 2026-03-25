import '../api/api_end_points.dart';
import '../service_model/service_response_model.dart';

class ApiClientService {
  const ApiClientService();

  Future<ServiceResponseModel<Map<String, dynamic>>> get(String endpoint) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return ServiceResponseModel<Map<String, dynamic>>(
      endpoint: _resolveEndpoint(endpoint),
      statusCode: 200,
      data: <String, dynamic>{
        'status': 'stubbed',
        'method': 'GET',
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

  String _resolveEndpoint(String endpoint) {
    switch (endpoint) {
      case 'feed':
        return ApiEndPoints.homeFeed;
      case 'settings':
        return ApiEndPoints.settings;
      case 'messages':
        return ApiEndPoints.messages;
      default:
        return endpoint;
    }
  }
}
