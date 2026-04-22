import '../service_model/service_response_model.dart';
import 'api_client_service.dart';

abstract class FeatureServiceBase {
  FeatureServiceBase({ApiClientService? apiClient})
    : apiClient = apiClient ?? ApiClientService();

  final ApiClientService apiClient;

  String get featureName;

  Map<String, String> get endpoints => const <String, String>{};

  Iterable<String> get registeredEndpoints => endpoints.values.toSet();

  Future<ServiceResponseModel<Map<String, dynamic>>> getEndpoint(
    String key, {
    Map<String, dynamic>? queryParameters,
  }) {
    return apiClient.get(
      endpoints[key] ?? key,
      queryParameters: queryParameters,
    );
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> postEndpoint(
    String key, {
    Map<String, dynamic> payload = const <String, dynamic>{},
  }) {
    return apiClient.post(endpoints[key] ?? key, payload);
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> patchEndpoint(
    String key, {
    Map<String, dynamic> payload = const <String, dynamic>{},
  }) {
    return apiClient.patch(endpoints[key] ?? key, payload);
  }

  Future<ServiceResponseModel<Map<String, dynamic>>> deleteEndpoint(
    String key, {
    Map<String, dynamic>? payload,
  }) {
    return apiClient.delete(endpoints[key] ?? key, payload: payload);
  }
}
