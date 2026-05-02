import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service/api_client_service.dart';
import '../../../core/data/service_model/service_response_model.dart';

class SettingsPreferencesRepository {
  SettingsPreferencesRepository({ApiClientService? apiClient})
    : _apiClient = apiClient ?? ApiClientService();

  final ApiClientService _apiClient;

  Future<Map<String, dynamic>> readAll() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .get(ApiEndPoints.settingsState);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load account settings.');
    }

    return ApiPayloadReader.readMap(response.data['data']) ??
        ApiPayloadReader.readMap(response.data) ??
        <String, dynamic>{};
  }

  Future<void> writeAll(Map<String, dynamic> value) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _apiClient
        .patch(ApiEndPoints.settingsState, value);
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to save account settings.');
    }
  }
}
