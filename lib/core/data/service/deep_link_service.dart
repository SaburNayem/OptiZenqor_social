import '../api/api_end_points.dart';
import '../api/api_payload_reader.dart';
import '../service_model/service_response_model.dart';
import 'api_client_service.dart';

class DeepLinkService {
  DeepLinkService({ApiClientService? apiClient})
    : _apiClient = apiClient ?? ApiClientService();

  final ApiClientService _apiClient;

  Future<String?> handleIncomingLink(String url) async {
    final String normalized = url.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .post(ApiEndPoints.deepLinkHandlerResolve, <String, dynamic>{
          'url': normalized,
        });
    if (!response.isSuccess || response.data['success'] == false) {
      return null;
    }

    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response.data['data']) ?? response.data;
    final String resolvedRoute = ApiPayloadReader.readString(
      payload['resolvedRoute'] ?? payload['path'] ?? payload['route'],
    );
    return resolvedRoute.isEmpty ? null : resolvedRoute;
  }

  Future<String?> open(String route) async {
    final String normalized = route.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
